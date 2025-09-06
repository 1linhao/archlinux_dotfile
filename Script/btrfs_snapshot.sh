#!/bin/bash

# ==== 配置区 ====
DISK_UUID="d2efc181-3137-4404-a70a-8b4f6da2b40b" # 使用lsblk -f 找到目标分区的uuid
MOUNT_POINT="/mnt/script" # 设置挂载点
SUBVOL_SNAPSHOT=("@" "@boot") # 需要管理快照的子卷
SNAPSHOT_DIR="$MOUNT_POINT/@snapshots" # 快照子卷的路径
SNAPSHOT_JSON="$SNAPSHOT_DIR/snapshot.json" # 脚本数据文件路径
MOUNTED=0 # 0: 目标卷未挂载，1: 目标卷已挂载

# ==== 自动卸载 ====
unmount_disk() {
    if [ "$MOUNTED" -eq 1 ]; then
        cd - > /dev/null
        sudo umount "$MOUNT_POINT"
    fi
}
trap unmount_disk EXIT

# ==== 检查依赖 ====
check_dependencies() {
    if ! command -v jq >/dev/null; then
        echo "❌ 缺少 jq 命令，请先安装它（如 sudo pacman -S jq）"
        exit 1
    fi
}

# ==== 挂载磁盘 ====
mount_disk() {
    if mountpoint -q "$MOUNT_POINT"; then
        echo "⚠️ 挂载点 $MOUNT_POINT 已被使用，尝试卸载..."
        if ! sudo umount "$MOUNT_POINT"; then
            echo "❌ 卸载失败，终止操作"
            exit 1
        fi
    fi

    if ! sudo mount /dev/disk/by-uuid/"$DISK_UUID" "$MOUNT_POINT" --mkdir 2>/dev/null; then
        echo "❌ 无法挂载磁盘，UUID 检查：$DISK_UUID"
        exit 1
    fi
    MOUNTED=1
    cd "$MOUNT_POINT" || {
        echo "❌ 无法进入挂载目录 $MOUNT_POINT"
        exit 1
    }
}

# ==== 初始化 JSON ====
init_snapshot_json() {
    sudo mkdir -p "$SNAPSHOT_DIR"

    if [ ! -f "$SNAPSHOT_JSON" ]; then
        echo '{"snapshots": []}' | sudo tee "$SNAPSHOT_JSON" > /dev/null
    else
        if ! jq -e '.snapshots | arrays' "$SNAPSHOT_JSON" >/dev/null 2>&1; then
            echo "⚠️ 修复无效的 snapshot.json..."
            echo '{"snapshots": []}' | sudo tee "$SNAPSHOT_JSON" > /dev/null
        fi
    fi
}

# ==== 创建快照 ====
create_snapshot() {
    local snap_name commit_content id tmp new_entry subvol
    snap_name=$(date +"%Y-%m-%d--%H:%M:%S")
    commit_content="${1:-}"

    for subvol in "${SUBVOL_SNAPSHOT[@]}"; do
        if [ ! -d "$MOUNT_POINT/$subvol" ]; then
            echo "❌ 子卷 $subvol 不存在"
            exit 1
        fi
    done

    for subvol in "${SUBVOL_SNAPSHOT[@]}"; do
        sudo mkdir -p "$SNAPSHOT_DIR/$subvol"
        sudo btrfs subvolume snapshot -r "$MOUNT_POINT/$subvol" "$SNAPSHOT_DIR/$subvol/$snap_name"
    done

    id=$(jq '.snapshots | length' "$SNAPSHOT_JSON")
    id=$((id + 1))

    new_entry="{\"id\": $id, \"name\": \"$snap_name\", \"commit\": \"$commit_content\"}"
    tmp=$(mktemp)
    jq ".snapshots += [$new_entry]" "$SNAPSHOT_JSON" > "$tmp"
    sudo mv "$tmp" "$SNAPSHOT_JSON"

    echo "✅ 已创建快照 $snap_name（ID=$id，备注：$commit_content）"
}

# ==== 显示快照 ====
list_snapshots() {
    local tmp
    tmp=$(mktemp)
    jq '{snapshots: (.snapshots | sort_by(.id))}' "$SNAPSHOT_JSON" > "$tmp"
    sudo mv "$tmp" "$SNAPSHOT_JSON"

    echo -e "ID\t| Name\t\t\t| Commit"
    echo    "---------------------------------|--------"
    jq -r '.snapshots[] | "\(.id)\t| \(.name)\t| \(.commit)"' "$SNAPSHOT_JSON"
}

# ==== 删除快照 ====
delete_snapshots() {
    shift
    local id snap_name tmp subvol

    if ! jq -e '.snapshots | arrays' "$SNAPSHOT_JSON" >/dev/null 2>&1; then
        echo "❌ snapshot.json 无效或格式错误"
        return 1
    fi

    for id in "$@"; do
        snap_name=$(jq -r ".snapshots[] | select(.id == $id) | .name" "$SNAPSHOT_JSON")
        if [ -n "$snap_name" ] && [ "$snap_name" != "null" ]; then
            echo "🗑️ 正在删除快照 ID=$id [$snap_name]"
            for subvol in "${SUBVOL_SNAPSHOT[@]}"; do
                [ -d "$SNAPSHOT_DIR/$subvol/$snap_name" ] && sudo btrfs subvolume delete "$SNAPSHOT_DIR/$subvol/$snap_name"
            done

            tmp=$(mktemp)
            jq '{snapshots: (.snapshots | map(select(.id != '"$id"')))}' "$SNAPSHOT_JSON" > "$tmp"
            sudo mv "$tmp" "$SNAPSHOT_JSON"
        else
            echo "⚠️ 快照 ID $id 不存在"
        fi
    done

    if [ "$(jq '.snapshots | length' "$SNAPSHOT_JSON")" -eq 0 ]; then
        echo '{"snapshots": []}' | sudo tee "$SNAPSHOT_JSON" > /dev/null
        echo "✅ 所有快照已删除，JSON 已重置为空结构"
        return
    fi

    tmp=$(mktemp)
    jq '{snapshots: (.snapshots | sort_by(.id) | to_entries | map(.value.id = (.key+1) | .value))}' "$SNAPSHOT_JSON" > "$tmp"
    sudo mv "$tmp" "$SNAPSHOT_JSON"
}

# ==== 检查是否在 Arch Live 环境 ====
check_arch_live() {
    if [ ! -f /etc/arch-release ] || ! grep -q "Arch Linux" /etc/os-release || [ ! -d /run/archiso ]; then
        echo "❌ 必须在 Arch Linux Live 环境中执行恢复操作"
        exit 1
    fi
}

# ==== 恢复快照 ====
restore_snapshot() {
    local id snap_name subvol
    id="$1"

    check_arch_live

    if ! jq -e '.snapshots | arrays' "$SNAPSHOT_JSON" >/dev/null 2>&1; then
        echo "❌ snapshot.json 无效或格式错误"
        exit 1
    fi

    snap_name=$(jq -r ".snapshots[] | select(.id == $id) | .name" "$SNAPSHOT_JSON")
    if [ -z "$snap_name" ] || [ "$snap_name" = "null" ]; then
        echo "⚠️ 快照 ID $id 不存在"
        exit 1
    fi

    for subvol in "${SUBVOL_SNAPSHOT[@]}"; do
        if [ ! -d "$SNAPSHOT_DIR/$subvol/$snap_name" ]; then
            echo "❌ 快照子卷 $subvol/$snap_name 不存在"
            exit 1
        fi
        echo "🔄 正在恢复子卷 $subvol 到快照 $snap_name"
        sudo btrfs subvolume delete "$MOUNT_POINT/$subvol"
        sudo btrfs subvolume snapshot "$SNAPSHOT_DIR/$subvol/$snap_name" "$MOUNT_POINT/$subvol"
    done

    echo "✅ 已恢复快照 ID=$id [$snap_name]"
}

# ==== 帮助 ====
print_help() {
    echo "用法: $0 {create [备注]|list|delete <id...>|restore <id>}"
    echo ""
    echo "命令："
    echo "  create [commit]   创建一个新快照，附带可选备注"
    echo "  list              列出所有快照"
    echo "  delete <id...>    删除指定快照 ID（可多个）"
    echo "  restore <id>      恢复指定快照 ID（需在 Arch Live 环境）"
    echo ""
}

# ==== 主函数 ====
main() {
    check_dependencies
    mount_disk
    init_snapshot_json

    case "$1" in
        create)
            shift
            create_snapshot "$*"
            ;;
        list)
            list_snapshots
            ;;
        delete)
            delete_snapshots "$@"
            ;;
        restore)
            shift
            restore_snapshot "$@"
            ;;
        help|-h|--help|"")
            print_help
            ;;
        *)
            echo "❌ 无效参数：$1"
            print_help
            exit 1
            ;;
    esac
}

main "$@"

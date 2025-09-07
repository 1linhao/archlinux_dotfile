#!/bin/bash

# ==== 配置区 ====
DISK_UUID="d2efc181-3137-4404-a70a-8b4f6da2b40b" # 使用lsblk -f 找到目标分区的uuid
MOUNT_POINT="/mnt/script" # 设置挂载点
SUBVOL_SNAPSHOT=("@" "@boot") # 需要管理快照的子卷
SNAPSHOT_DIR="$MOUNT_POINT/snapshots" # 快照子卷的路径
SNAPSHOT_JSON="$SNAPSHOT_DIR/snapshot.json" # 脚本数据文件路径
MOUNTED=0 # 0: 目标卷未挂载，1: 目标卷已挂载

# ==== 自动卸载 ====
unmount_disk() {
    if [ "$MOUNTED" -eq 1 ]; then
        cd - > /dev/null
        umount "$MOUNT_POINT"
    fi
}
trap unmount_disk EXIT

# ==== 检查依赖 ====
check_dependencies() {
    if ! command -v jq >/dev/null; then
        echo "Missing jq command, please install it (e.g., sudo pacman -S jq)"
        exit 1
    fi
}

# ==== 挂载磁盘 ====
mount_disk() {
    if mountpoint -q "$MOUNT_POINT"; then
        echo "Mount point $MOUNT_POINT is already in use, trying to unmount..."
        if ! umount "$MOUNT_POINT"; then
            echo "Unmount failed, aborting"
            exit 1
        fi
    fi

    if ! mount /dev/disk/by-uuid/"$DISK_UUID" "$MOUNT_POINT" --mkdir 2>/dev/null; then
        echo "Unable to mount disk, check UUID: $DISK_UUID"
        exit 1
    fi
    MOUNTED=1
    cd "$MOUNT_POINT" || {
        echo "Unable to enter mount directory $MOUNT_POINT"
        exit 1
    }
}

# ==== 初始化 JSON ====
init_snapshot_json() {
    mkdir -p "$SNAPSHOT_DIR"

    if [ ! -f "$SNAPSHOT_JSON" ]; then
        echo '{"snapshots": []}' | tee "$SNAPSHOT_JSON" > /dev/null
    else
        if ! jq -e '.snapshots | arrays' "$SNAPSHOT_JSON" >/dev/null 2>&1; then
            echo "Repairing invalid snapshot.json..."
            echo '{"snapshots": []}' | tee "$SNAPSHOT_JSON" > /dev/null
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
            echo "Subvolume $subvol does not exist"
            exit 1
        fi
    done

    for subvol in "${SUBVOL_SNAPSHOT[@]}"; do
        mkdir -p "$SNAPSHOT_DIR/$subvol"
        btrfs subvolume snapshot -r "$MOUNT_POINT/$subvol" "$SNAPSHOT_DIR/$subvol/$snap_name"
    done

    id=$(jq '.snapshots | length' "$SNAPSHOT_JSON")
    id=$((id + 1))

    new_entry="{\"id\": $id, \"name\": \"$snap_name\", \"commit\": \"$commit_content\"}"
    tmp=$(mktemp)
    jq ".snapshots += [$new_entry]" "$SNAPSHOT_JSON" > "$tmp"
    mv "$tmp" "$SNAPSHOT_JSON"

    echo "Snapshot $snap_name created (ID=$id, commit: $commit_content)"
}

# ==== 显示快照 ====
list_snapshots() {
    local tmp
    tmp=$(mktemp)
    jq '{snapshots: (.snapshots | sort_by(.id))}' "$SNAPSHOT_JSON" > "$tmp"
    mv "$tmp" "$SNAPSHOT_JSON"

    echo -e "ID\t| Name\t\t\t| Commit"
    echo    "--------------------------------|-------"
    jq -r '.snapshots[] | "\(.id)\t| \(.name)\t| \(.commit)"' "$SNAPSHOT_JSON"
}

# ==== 删除快照 ====
delete_snapshots() {
    shift
    local id snap_name tmp subvol

    if ! jq -e '.snapshots | arrays' "$SNAPSHOT_JSON" >/dev/null 2>&1; then
        echo "snapshot.json invalid or malformed"
        return 1
    fi

    for id in "$@"; do
        snap_name=$(jq -r ".snapshots[] | select(.id == $id) | .name" "$SNAPSHOT_JSON")
        if [ -n "$snap_name" ] && [ "$snap_name" != "null" ]; then
            echo "Deleting snapshot ID=$id [$snap_name]"
            for subvol in "${SUBVOL_SNAPSHOT[@]}"; do
                [ -d "$SNAPSHOT_DIR/$subvol/$snap_name" ] && btrfs subvolume delete "$SNAPSHOT_DIR/$subvol/$snap_name"
            done

            tmp=$(mktemp)
            jq '{snapshots: (.snapshots | map(select(.id != '"$id"')))}' "$SNAPSHOT_JSON" > "$tmp"
            mv "$tmp" "$SNAPSHOT_JSON"
        else
            echo "Snapshot ID $id does not exist"
        fi
    done

    if [ "$(jq '.snapshots | length' "$SNAPSHOT_JSON")" -eq 0 ]; then
        echo '{"snapshots": []}' | tee "$SNAPSHOT_JSON" > /dev/null
        echo "All snapshots deleted, JSON reset to empty structure"
        return
    fi

    tmp=$(mktemp)
    jq '{snapshots: (.snapshots | sort_by(.id) | to_entries | map(.value.id = (.key+1) | .value))}' "$SNAPSHOT_JSON" > "$tmp"
    mv "$tmp" "$SNAPSHOT_JSON"
}

# ==== 检查是否在 Arch Live 环境 ====
check_arch_live() {
    if [ ! -f /etc/arch-release ] || ! grep -q "Arch Linux" /etc/os-release || [ ! -d /run/archiso ]; then
        echo "Restore operation must be performed in an Arch Linux Live environment"
        exit 1
    fi
}

# ==== 恢复快照 ====
restore_snapshot() {
    local id snap_name subvol
    id="$1"

    check_arch_live

    if ! jq -e '.snapshots | arrays' "$SNAPSHOT_JSON" >/dev/null 2>&1; then
        echo "snapshot.json invalid or malformed"
        exit 1
    fi

    snap_name=$(jq -r ".snapshots[] | select(.id == $id) | .name" "$SNAPSHOT_JSON")
    if [ -z "$snap_name" ] || [ "$snap_name" = "null" ]; then
        echo "Snapshot ID $id does not exist"
        exit 1
    fi

    for subvol in "${SUBVOL_SNAPSHOT[@]}"; do
        if [ ! -d "$SNAPSHOT_DIR/$subvol/$snap_name" ]; then
            echo "Snapshot subvolume $subvol/$snap_name does not exist"
            exit 1
        fi
        echo "Restoring subvolume $subvol to snapshot $snap_name"
        btrfs subvolume delete "$MOUNT_POINT/$subvol"
        btrfs subvolume snapshot "$SNAPSHOT_DIR/$subvol/$snap_name" "$MOUNT_POINT/$subvol"
    done

    echo "Snapshot ID=$id [$snap_name] restored"
}

# ==== 帮助 ====
print_help() {
    echo "Usage: $0 {create [commit]|list|delete <id...>|restore <id>}"
    echo ""
    echo "Commands:"
    echo "  create [commit]   Create a new snapshot with an optional commit message"
    echo "  list              List all snapshots"
    echo "  delete <id...>    Delete one or more specified snapshot IDs"
    echo "  restore <id>      Restore a specified snapshot ID (requires Arch Live environment)"
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
            echo "Invalid argument: $1"
            print_help
            exit 1
            ;;
    esac
}

main "$@"

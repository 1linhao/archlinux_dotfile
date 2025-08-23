#!/bin/bash

# 屏幕截图脚本：screenshot.sh
# 功能：支持全屏截图（当前显示器）和区域截图
# 输出：保存截图到文件并复制到剪贴板，然后发送通知
# 环境：Arch Linux + Hyprland + Wayland

# 配置截图保存目录
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

# 检查依赖工具
DEPENDENCIES=("grim" "slurp" "feh" "tesseract" "wl-copy" "notify-send" "hyprctl")
for dep in "${DEPENDENCIES[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
        notify-send "错误" "依赖工具 $dep 未安装"
        exit 1
    fi
done

# 确保保存目录存在
mkdir -p "$SCREENSHOT_DIR" || {
    notify-send "错误" "无法创建目录 $SCREENSHOT_DIR"
    exit 1
}

# 生成时间戳
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 定义截图文件路径，检查是否提供第二个参数
if [ -n "$2" ]; then
    FILE="$2"
else
    FILE="$SCREENSHOT_DIR/screenshot_$TIMESTAMP.png"
fi

# 截取当前显示器全屏
CURRENT_MONITOR=$(hyprctl monitors | awk '/Monitor/{name=$2} /focused: yes/{print name}')
if [ -z "$CURRENT_MONITOR" ]; then
    notify-send "错误" "无法获取当前显示器"
    exit 1
fi

# 判断截图模式
case "$1" in
    full)
        MODE="全屏截图"
        grim -o "$CURRENT_MONITOR" "$FILE"
        ;;
    space)
        MODE="区域截图"
        # 截全屏并置顶以辅助区域选择
        grim -o "$CURRENT_MONITOR" - | feh --no-fehbg --fullscreen - &
        FEH_PID=$!
        sleep 0.05
        # 选取区域并截图
        grim -g "$(slurp)" "$FILE"
        kill $FEH_PID 2>/dev/null
        ;;
    *)
        notify-send "错误" "无效参数：请使用 'full'或 'space'"
        exit 1
        ;;
esac

# 检查截图是否成功（仅对 full 和 space 模式）
if [ -f "$FILE" ]; then
    # 复制截图到剪贴板
    wl-copy < "$FILE" || notify-send "错误" "无法复制截图到剪贴板"
    # 发送截图完成通知
    notify-send "截图完成" "$MODE 已保存至: $FILE 并已复制到剪贴板"
else
    notify-send "截图失败" "未能成功捕获屏幕"
    exit 1
fi

exit 0

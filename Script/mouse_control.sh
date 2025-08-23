#!/bin/bash

# 使用ydotool控制鼠标移动、点击和滚动的脚本
# 使用方法: ./mouse_control.sh {left|right|top|bottom|click|up|down} [speed]
# speed: 可选布尔值，true表示快速模式，false或省略表示正常模式

# 光标移动距离（单位：像素）
MOVEDISTANCE=20
# 快速模式下的移动距离（单位：像素）
MOVEDISTANCE_SPEED=100
# 速度状态，默认为false
SPEED_STATUS=false

# 检查第二个参数以设置速度状态
if [ $# -eq 2 ]; then
    if [ "$2" = "true" ]; then
        SPEED_STATUS=true
    elif [ "$2" != "false" ]; then
        echo "错误: 第二个参数必须为 true 或 false"
        usage
        exit 1
    fi
fi

# 光标移动方法
move_mouse() {
    # 根据SPEED_STATUS选择移动距离
    local distance=$MOVEDISTANCE
    if [ "$SPEED_STATUS" = true ]; then
        distance=$MOVEDISTANCE_SPEED
    fi

    case $1 in
        left)
            ydotool mousemove -x -${distance} -y 0
            ;;
        right)
            ydotool mousemove -x ${distance} -y 0
            ;;
        top)
            ydotool mousemove -x 0 -y -${distance}
            ;;
        bottom)
            ydotool mousemove -x 0 -y ${distance}
            ;;
        *)
            echo "无效的方向: $1"
            usage
            exit 1
            ;;
    esac
}

# 鼠标滚动方法
scroll_mouse() {
    # 根据SPEED_STATUS设置循环次数
    local repeat_count=1
    if [ "$SPEED_STATUS" = true ]; then
        repeat_count=3
    fi

    case $1 in
        up)
            for ((i=1; i<=repeat_count; i++)); do
                ydotool mousemove -w -- 0 1
                sleep 0.05
            done
            ;;
        down)
            for ((i=1; i<=repeat_count; i++)); do
                ydotool mousemove -w -- 0 -1
                sleep 0.05
            done
            ;;
        *)
            echo "无效的方向: $1"
            usage
            exit 1
            ;;
    esac
}

# 光标点击方法
click_mouse() {
    ydotool click 0xC0
}

# 使用帮助
usage() {
    echo "用法: $0 {left|right|top|bottom|click|up|down} [speed]"
    echo "  left: 将光标向左移动（快速模式: $MOVEDISTANCE_SPEED像素，正常模式: $MOVEDISTANCE像素）"
    echo "  right: 将光标向右移动（快速模式: $MOVEDISTANCE_SPEED像素，正常模式: $MOVEDISTANCE像素）"
    echo "  top: 将光标向上移动（快速模式: $MOVEDозд

System: $MOVEDISTANCE像素，正常模式: $MOVEDISTANCE像素）"
    echo "  bottom: 将光标向下移动（快速模式: $MOVEDISTANCE_SPEED像素，正常模式: $MOVEDISTANCE像素）"
    echo "  click: 执行左键点击"
    echo "  up: 向上滚动（快速模式: 3次，正常模式: 1次）"
    echo "  down: 向下滚动（快速模式: 3次，正常模式: 1次）"
    echo "  speed: 可选参数，true表示快速模式，false或省略表示正常模式"
}

# 脚本入口
if [ $# -lt 1 ]; then
    echo "错误: 至少需要一个参数"
    usage
    exit 1
fi

ACTION=$1

case $ACTION in
    left|right|top|bottom)
        move_mouse $ACTION
        ;;
    up|down)
        scroll_mouse $ACTION
        ;;
    click)
        click_mouse
        ;;
    *)
        echo "错误: 无效的动作 '$ACTION'"
        usage
        exit 1
        ;;
esac

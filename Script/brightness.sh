#!/bin/bash

# 调节当前显示器亮度 

CURRENT_MONITOR=$(hyprctl monitors | awk '/Monitor/{name=$2} /focused: yes/{print name}')
if [ -z "$CURRENT_MONITOR" ]; then
    notify-send "错误" "无法获取当前显示器"
    exit 1
fi

case $CURRENT_MONITOR in
  "eDP-1")
    case $1 in
      up)
        brightnessctl s 10%+ -d amdgpu_bl1 
        notify-send "当前显示器亮度" "$(brightnessctl -d amdgpu_bl1 | grep -oP '\d+%')"
        ;;
      down)
        brightnessctl s 10%- -d amdgpu_bl1 
        notify-send "当前显示器亮度" "$(brightnessctl -d amdgpu_bl1 | grep -oP '\d+%')"
        ;;
    esac
    ;;
  "HDMI-A-1")
    bright=$(ddcutil --bus=8 getvcp 10 --terse | awk '{print $4}')
    case $1 in
      up)
        if [ "$bright" -gt 90 ]; then
          bright=100
        else
          bright=$((bright + 10))
        fi
        ddcutil --bus=8 setvcp 10 $bright
        notify-send "当前显示器亮度" "$bright%"
        ;;
      down)
        if [ "$bright" -lt 10 ]; then
          bright=0
        else
          bright=$((bright - 10))
        fi
        ddcutil --bus=8 setvcp 10 $bright
        notify-send "当前显示器亮度" "$bright%"
        ;;
    esac
    ;;
  *)
    notify-send "亮度调节失败"
    exit 1
    ;;
esac





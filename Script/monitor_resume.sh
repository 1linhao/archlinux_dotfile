#!/bin/bash

variable_path="/home/lh/Script/monitor_status"
nvidia_monitor_name="HDMI-A-1"
inbuild_monitor_name="eDP-1"
monitor_script_path="/home/lh/Script/monitor_control.sh"

case "$1" in
  suspend)
    if hyprctl monitors | grep -q "$nvidia_monitor_name"; then
      bash "$monitor_script_path" mhc
      if hyprctl monitors | grep -q "$inbuild_monitor_name"; then
        echo "2" > "$variable_path"
      else
        echo "1" > "$variable_path"
        bash "$monitor_script_path" meo
      fi
    else
      if [ "$(cat "$variable_path")" != "0" ]; then
        echo "0" > "$variable_path"
      fi
      exit 0
    fi
    ;;
  resume)
    sleep 1
    case "$(cat "$variable_path")" in
      1)
        bash "$monitor_script_path" mho
        sleep 3
        bash "$monitor_script_path" mec
        ;;
      2)
        bash "$monitor_script_path" mho
        ;;
      *)
        exit 0
        ;;
    esac
    ;;
esac

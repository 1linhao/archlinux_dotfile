#!/bin/bash

case "$1" in
    mec)
        hyprctl keyword monitor "eDP-1,disable"
        ;;
    meo)
        hyprctl keyword monitor "eDP-1,preferred,0x0,1.25"
        ;;
    mhc)
        hyprctl keyword monitor "HDMI-A-1,disable"
        ;;
    mho)
        hyprctl keyword monitor "HDMI-A-1,1920x1080@200.00Hz,auto,1"
        ;;
    mhr)
        hyprctl keyword monitor "HDMI-A-1,disable"
        sleep 1
        hyprctl keyword monitor "HDMI-A-1,1920x1080@200.00Hz,auto,1"
        ;;
    *)
        echo "Usage: $0 {mec|meo|mhc|mho|mhr}"
        exit 1
        ;;
esac
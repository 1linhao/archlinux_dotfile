#!/bin/bash
# 用法: kitty-padding.sh <padding>

PADDING=$1
kitty @ set-spacing padding=${PADDING}


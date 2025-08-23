#!/bin/bash

# 主题目录
THEME_DIR="/boot/grub/themes"
# 查找所有 theme.txt 文件
THEMES=($(find "$THEME_DIR" -type f -name "theme.txt"))
# 随机选择一个主题
RANDOM_THEME=${THEMES[$RANDOM % ${#THEMES[@]}]}
# 更新 /etc/default/grub 中的 GRUB_THEME
sudo sed -i "s|GRUB_THEME=.*|GRUB_THEME=\"$RANDOM_THEME\"|" /etc/default/grub
# 更新 GRUB 配置
grub-mkconfig -o /boot/grub/grub.cfg

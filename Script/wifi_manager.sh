#!/usr/bin/env bash
# wifi_manager.sh
# 功能：扫描、连接、删除 WiFi，使用 nmcli、rofi、mako-send/notify-send

CACHE_FILE="/tmp/wifi_cache.txt"
CACHE_TIME_FILE="/tmp/wifi_cache_time.txt"
SCAN_INTERVAL=300  # 5 分钟
WLAN_DEV="wlp4s0"

# 获取当前连接的 SSID 和信号
get_current() {
  CUR_SSID=$(nmcli -t -f GENERAL.CONNECTION dev show $WLAN_DEV | cut -d: -f2-)
}

# 扫描 WiFi 并更新缓存
do_scan() {
  notify-send "开始扫描 WiFi"
  # 扫描并获取 SSID 和信号
  nmcli -t -f SSID,SIGNAL dev wifi list | \
  awk -F: '$1!="" && $1!="--"{print $1 "|" $2}' > /tmp/scan_raw.txt
  # 获取已记住的连接名列表
  nmcli -t -f NAME connection show | awk -F: '{print $1}' > /tmp/saved_list.txt
  # 生成缓存：SSID|信号|已保存
  > "$CACHE_FILE"
  while IFS="|" read -r ss sig; do
    saved=""
    if grep -Fxq "$ss" /tmp/saved_list.txt; then saved="已保存"; fi
    echo "$ss|$sig|$saved"
  done < /tmp/scan_raw.txt | sort -t"|" -k2 -nr > "$CACHE_FILE"
  date +%s > "$CACHE_TIME_FILE"
}

# 检查并加载缓存，超过 5 分钟重扫
load_cache() {
  if [[ ! -f $CACHE_FILE || ! -f $CACHE_TIME_FILE ]]; then
    do_scan
  else
    last=$(cat "$CACHE_TIME_FILE")
    now=$(date +%s)
    if (( now - last > SCAN_INTERVAL )); then
      do_scan
    fi
  fi
}

# 生成 rofi 菜单选项
build_menu() {
  OPTIONS=()
  OPTIONS+=("扫描 WiFi")
  if [[ -n $CUR_SSID ]]; then
    ss=$(echo "$CUR_SSID" | cut -d"|" -f1)
    sig=$(echo "$CUR_SSID" | cut -d"|" -f2)
    OPTIONS+=("[已连接]  [断开]  $ss")
    OPTIONS+=("[已连接]  [忘记]  $ss")
  fi
  while IFS="|" read -r ss sig saved; do
    # 跳过设备名为 WLAN_DEV 的项
    [[ "$ss" == "$CUR_SSID" ]] && continue

    label="$ss ($sig)"
    [[ $saved ]] && label="[已保存]  [连接]  $label"
    OPTIONS+=("$label")
    if [[ $saved ]]; then
      OPTIONS+=("[已保存]  [忘记]  $ss ($sig)")
    fi
  done < "$CACHE_FILE"
}

# 获取用户输入的密码
get_password() {
  ss="$1"
  password=$(rofi -dmenu -password -p "请输入密码 $ss")
  echo "$password"
}

# 处理用户选择
handle_choice() {
  choice="$1"
  case "$choice" in
    "扫描 WiFi")
      do_scan
      sleep 1
      exec "$0"
      ;;
    *"[断开]"*)
      nmcli device disconnect $WLAN_DEV
      notify-send "已断开 WiFi"
      exit
      ;;
    *"[忘记]"*)
      ss=$(echo "$choice" | awk '{print $3}')
      nmcli connection delete id "$ss"
      notify-send "已删除 WiFi: $ss"
      do_scan
      sleep 1
      exec "$0"
      ;;
    *"[连接]"*)
      ss=$(echo "$choice" | awk '{print $3}')
      notify-send "连接到 $ss"
      nmcli dev wifi connect "$ss"
      if [[ $? -ne 0 ]]; then
        password=$(get_password "$ss")
        if [[ -n $password ]]; then
          nmcli dev wifi connect "$ss" password "$password"
          if [[ $? -eq 0 ]]; then
            notify-send "已连接: $ss"
          else
            notify-send "连接失败: $ss"
          fi
        else
          notify-send "未输入密码"
        fi
      else
        notify-send "已连接: $ss"
      fi
      exit
      ;;
    *)
      # 处理新连接：提取 SSID 并要求密码
      ss=$(echo "$choice" | sed 's/ (\([0-9]*\))$//')
      notify-send "连接到 $ss"
      password=$(get_password "$ss")
      if [[ -n $password ]]; then
        nmcli dev wifi connect "$ss" password "$password"
        if [[ $? -eq 0 ]]; then
          notify-send "已连接: $ss"
        else
          notify-send "连接失败: $ss"
        fi
      else
        notify-send "未输入密码"
      fi
      exit
      ;;
  esac
}

# 主流程
get_current
load_cache
build_menu
CHOICE=$(printf '%s\n' "${OPTIONS[@]}" | rofi -dmenu -i -p "WiFi")
[[ -n $CHOICE ]] && handle_choice "$CHOICE"

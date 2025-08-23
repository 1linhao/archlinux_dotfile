#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
alias ll='ls -l'
alias big='setfont ter-124b'
# alias n='neovide'

# yazi
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# curl proxy
# export ALL_PROXY=SOCKS5h://127.0.0.1:1080

# git proxy
# git config --global http.proxy 'socks5h://127.0.0.1:1080'
# git config --global https.proxy 'socks5h://127.0.0.1:1080'

# update LANDG
function le {
  export LANG=en_US.UTF-8
}

function lc {
  export LANG=zh_CN.UTF-8
}

# 启动 wayland 桌面前设置一些环境变量
function set_wayland_env {
  # 设置语言环境为中文
  export LANG=zh_CN.UTF-8
  # 解决QT程序缩放问题
  export QT_AUTO_SCREEN_SCALE_FACTOR=1
  # QT使用wayland和gtk
  export QT_QPA_PLATFORM="wayland;xcb"
  # 关闭QT程序的窗口装饰
  export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
  # 使用qt5ct软件配置QT程序外观
  export QT_QPA_PLATFORMTHEME=qt5ct

  # 一些游戏使用wayland
  export SDL_VIDEODRIVER="wayland,x11"
  # 解决java程序启动黑屏错误
  export _JAVA_AWT_WM_NONEREPARENTING=1
  # GTK后端为 wayland和x11,优先wayland
  export GDK_BACKEND="wayland,x11"
}

# 命令行输入这个命令启动hyprland,可以自定义
function h {
  # set_wayland_env

  export LANG=zh_CN.UTF-8
  export XDG_SESSION_TYPE=wayland
  export XDG_SESSION_DESKTOP=Hyprland
  export XDG_CURRENT_DESKTOP=Hyprland
  # 启动 Hyprland程序
  exec Hyprland

}

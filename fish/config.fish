if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -gx PATH $PATH ~/.local/share/nvim/mason/bin/

# keybind
abbr m musicfox
abbr r rmpc
abbr n ncmpcpp
abbr f fanyi
abbr b btop
abbr e exit

# 目录跳转
## 文档目录
abbr gdd cd /home/lh/Downloads
abbr gdpp cd /home/lh/Pictures
abbr gdpg cd /home/lh/Pictures/Gallery
abbr gdpw cd /home/lh/Pictures/Wallpapers
abbr gdps cd /home/lh/Pictures/Screenshots
abbr gdvv cd /home/lh/Videos
abbr gdvr cd /home/lh/Videos/Recordings
abbr gdva cd /home/lh/Videos/Anime
abbr gdm cd /home/lh/Music
abbr gdo cd /home/lh/Public/share/obsidian
abbr gdgg cd /home/lh/git
abbr gdgd cd /home/lh/git/dotfile
abbr gdgc cd /home/lh/git/caelestia
abbr gdp cd /home/lh/Program
## config目录
abbr gcc cd /home/lh/.config
abbr gcy cd /home/lh/.config/yazi
abbr gcg cd /home/lh/.config/go-musicfox
abbr gck cd /home/lh/.config/kitty
abbr gch cd /home/lh/.config/hypr
abbr gcn cd /home/lh/.config/nvim
abbr gcf cd /home/lh/.config/fish
## cache目录
abbr gCC cd /home/lh/.cache
abbr gCg cd /home/lh/.cache/go-musicfox
## local目录
abbr glss cd /home/lh/.local/share
abbr glsa cd /home/lh/.local/share/applications
abbr glsa cd /home/lh/.local/share/applications
abbr glt cd /home/lh/.local/state
## share目录
abbr gss cd /usr/share
## 程序目录
### WallpaperEngineData for steam
abbr gasw cd /home/lh/.steam/steam/steamapps/workshop/content/431960
### 微信数据目录
abbr gawd cd /home/lh/.local/share/WeChat_Data
### wine用户目录
abbr gdw cd /home/lh/.wine/drive_c/users

# yazi 
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# neovim
abbr snvim sudo -E nvim

# systemctl
abbr spo systemctl poweroff
abbr sre systemctl reboot
abbr ssu systemctl suspend
abbr shi systemctl hibernate
abbr sjfu sudo journalctl -fu
abbr sstart sudo systemctl start
abbr sstop sudo systemctl stop
abbr srestart sudo systemctl restart
abbr senable sudo systemctl enable
abbr sdisable sudo systemctl disable
abbr sstatus sudo systemctl status

# 显示器管理
abbr mec bash $HOME/Script/monitor_control.sh mec
abbr meo bash $HOME/Script/monitor_control.sh meo
abbr mhc bash $HOME/Script/monitor_control.sh mhc
abbr mho bash $HOME/Script/monitor_control.sh mho
abbr mhr bash $HOME/Script/monitor_control.sh mhr

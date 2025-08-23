if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -gx PATH $PATH ~/.local/share/nvim/mason/bin/

# yazi 
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

abbr m musicfox
abbr r rmpc
abbr n ncmpcpp
abbr f fanyi
abbr b btop
abbr e exit

# dotfile
function df -d "Manage dotfiles with git"
  set -l DOTFILES_DIR "$HOME/dotfiles/"
  set -l WORK_TREE "$HOME"
  set -l DOTFILES \
    $HOME/.bashrc \
    $HOME/.config/fcitx5/* \
    $HOME/.config/fontconfig/* \
    $HOME/.config/fish/config.fish \
    # $HOME/.config/hypr/* \
    $HOME/.config/kitty/* \
    # $HOME/.config/mako/* \
    $HOME/.config/mpd/mpd.conf \
    $HOME/.config/ncmpcpp/bindings \
    $HOME/.config/ncmpcpp/config \
    $HOME/.config/nvim/* \
    $HOME/.config/rmpc/* \
    # $HOME/.config/rofi/* \
    # $HOME/.config/waybar/* \
    $HOME/.config/yazi/* \
    $HOME/Script/*

  switch $argv[1]
    case add
      git --git-dir=$DOTFILES_DIR --work-tree=$WORK_TREE add -f $DOTFILES
    case restore
      git --git-dir=$DOTFILES_DIR --work-tree=$WORK_TREE restore --staged $DOTFILES
    case '*'
      git --git-dir=$DOTFILES_DIR --work-tree=$WORK_TREE $argv
  end
end

# neovim
abbr snvim sudo -E nvim

# systemctl
abbr spo systemctl poweroff
abbr sre systemctl reboot
abbr ssu systemctl suspend
abbr shi systemctl hibernate
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

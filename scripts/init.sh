#!/bin/bash

pacman -S  intel-media-driver libva-utils vulkan-intel ntfsprogs dosfstools kio-admin less unzip btrfsmaintenance direnv thefuck uv yazi fd zoxide ripgrep bat eza fzf wl-clipboard --noconfirm
# go.nvim 的GoJson2Struct命令需要用到这个工具
go install github.com/twpayne/go-jsonstruct/v3/cmd/gojsonstruct@latest

sudo systemctl enable --now fstrim.timer

sudo systemctl enable --now cronie


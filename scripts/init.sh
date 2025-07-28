#!/bin/bash

pacman -S fd zoxide ripgrep bat eza fzf wl-clipboard --noconfirm
# go.nvim 的GoJson2Struct命令需要用到这个工具
go install github.com/twpayne/go-jsonstruct/v3/cmd/gojsonstruct@latest

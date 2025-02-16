#!/bin/bash

# install.sh
CONFIG_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 创建符号链接
create_link() {
    local src="$1"
    local dest="$2"
    mkdir -p "$dest"
    if [ -e "$dest" ]; then
        mv "$dest" "${dest}.backup"
    fi
    ln -sf "$src" "$dest"
}

# 安装各个配置
install_nvim() {
    create_link "$CONFIG_ROOT/nvim" "$HOME/.config/nvim"
}

install_zsh() {
    create_link "$CONFIG_ROOT/zsh/.zshrc" "$HOME/.zshrc"
}

install_tmux() {
    # 创建配置文件软链接
    create_link "$CONFIG_ROOT/tmux/.tmux.conf" "$HOME/.tmux.conf"
    
    # 设置 TPM 安装目录
    TPM_DIR="$HOME/.tmux/plugins/tpm"
    
    # 检查 TPM 目录是否存在
    if [ ! -d "$TPM_DIR" ]; then
        echo "TPM not found. Installing TPM..."
        
        # 检查 git 是否安装
        if ! command -v git >/dev/null 2>&1; then
	
            echo "Error: git is not installed"
            return 1
	fi
        
        
        # 创建父目录
        mkdir -p "$HOME/.tmux/plugins"
        
        # 克隆 TPM
        git clone https://github.com/tmux-plugins/tpm "$TPM_DIR" || {
            echo "Failed to clone TPM repository"
            return 1
        }
        
        # 设置执行权限
        chmod +x "$TPM_DIR/tpm"
        chmod +x "$TPM_DIR/scripts/"*
        
        echo "TPM installed successfully"
    else
        echo "TPM already installed at $TPM_DIR"
    fi
    
    # 检查 tmux 是否已安装
    if ! command -v tmux >/dev/null 2>&1; then
        echo "Warning: tmux is not installed"
        return 1
    fi
    mkdir -p ~/.config/tmux/plugins/catppuccin
    mkdir -p ~/.tmux/resurrect
    git clone -b v2.1.2 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
    ~/.tmux/plugins/tpm/scripts/install_plugins.sh

    # 重新加载配置并自动安装插件
    tmux source ~/.tmux.conf || tmux source-file ~/.tmux.conf

}


install_kitty() {
    create_link "$CONFIG_ROOT/kitty" "$HOME/.config/kitty"
}

install_hyde() {
    create_link "$CONFIG_ROOT/Hyde/userprefs.conf" "$HOME/.config/hypr/userprefs.conf"
}
install_git() {
    create_link "$CONFIG_ROOT/git/.gitconfig" "$HOME/.gitconfig"
}
install_tldr() {
    # if tealdeer is not installed, then installed it
    create_link "$CONFIG_ROOT/tealdeer/config.toml" "$HOME/.config/tealdeer/config.toml"
    create_link "$CONFIG_ROOT/tealdeer/pages" "$HOME/.local/share/tealdeer/pages"
}
install_fcitx5() {
    create_link "$CONFIG_ROOT/fcitx5/rime/default.custom.yaml" "$HOME/.local/share/fcitx5/rime/default.custom.yaml"
    create_link "$CONFIG_ROOT/fcitx5/rime/rime_ice.custom.yaml" "$HOME/.local/share/fcitx5/rime/rime_ice.custom.yaml"
}
# 主安装流程
main() {
    pacman -S ripgrep fzf zoxide cmake python-pynvim git-delta bat fd
    install_nvim
#   install_zsh
    install_tmux
#   install_kitty
    install_hyde
    install_git
    install_tldr
    install_fcitx5
}


main "$@"


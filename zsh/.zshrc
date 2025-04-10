# Oh-my-zsh installation path
ZSH=/usr/share/oh-my-zsh/

# Powerlevel10k theme path
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# List of plugins used
plugins=( git sudo zsh-256color zsh-autosuggestions zsh-syntax-highlighting )
source $ZSH/oh-my-zsh.sh

# In case a command is not found, try to find the package that has it function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
    if (( ${#entries[@]} )) ; then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}" ; do
            local fields=( ${(0)entry} )
            if [[ "$pkg" != "${fields[2]}" ]]; then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

# Detect AUR wrapper
if pacman -Qi yay &>/dev/null; then
   aurhelper="yay"
elif pacman -Qi paru &>/dev/null; then
   aurhelper="paru"
fi

function in {
    local -a inPkg=("$@")
    local -a arch=()
    local -a aur=()

    for pkg in "${inPkg[@]}"; do
        if pacman -Si "${pkg}" &>/dev/null; then
            arch+=("${pkg}")
        else
            aur+=("${pkg}")
        fi
    done

    if [[ ${#arch[@]} -gt 0 ]]; then
        sudo pacman -S "${arch[@]}"
    fi

    if [[ ${#aur[@]} -gt 0 ]]; then
        ${aurhelper} -S "${aur[@]}"
    fi
}

# Helpful aliases
alias c='clear' # clear terminal
alias l='eza -lh --icons=auto' # long list
alias ls='eza -1 --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree
alias un='$aurhelper -Rns' # uninstall package
alias up='$aurhelper -Syu' # update system/package/aur
alias pl='$aurhelper -Qs' # list installed package
alias pa='$aurhelper -Ss' # list available package
alias pc='$aurhelper -Sc' # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
alias vc='code' # gui code editor

# Directory navigation shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -p'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Display Pokemon
# pokemon-colorscripts --no-title -r 1,3,6
if [ -z "$TMUX" ]; then
    # $TMUX 为空，表示不在 tmux 会话中
    fastfetch
fi

# 以下是自己加的
# ---------------------------------------------------
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1

# ---------------------------------------------------
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
# fi
# unset __conda_setup
# <<< conda initialize <<<


# 以下是自己加的
# ---------------------------------------------------
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=1
source /usr/share/nvm/init-nvm.sh
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward

export FORCE_THEME_UPDATE=true

# 解决vscode输入中文
# 似乎已经原生支持了
# alias code='code --enable-wayland-ime'

export MANPAGER='nvim +Man!'

nvim() {
    if [[ $1 == "sudo" ]]; then
        command sudo -E nvim "${@:2}"
    else
        command nvim "$@"
    fi
}
alias v='nvim'

# fzf
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

export FZF_DEFAULT_COMMAND='fd --type f --color=never --hidden'
export FZF_DEFAULT_OPTS='--no-height --color=bg+:#343d46,gutter:-1,pointer:#ff3c3c,info:#0dbc79,hl:#0dbc79,hl+:#23d18b'

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :50 {}'"

export FZF_ALT_C_COMMAND='fd --type d . --color=never --hidden'
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -50'"

alias findf="find . -type f | fzf --preview 'cat {}'"
alias cdf='cd "$(find . -type d | fzf --preview "ls -l {}")"'

# Set up zoxide
eval "$(zoxide init zsh)"
alias nano='nvim'
alias snvim="sudo -E nvim"
# yazi wrapper
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# alias cp="rsync -ahiv --progress --stats"
alias memo="calcurse"

# # 启用vim mode
bindkey -v
# # 减少 ESC 键延迟
export KEYTIMEOUT=1
# 在 Vi 模式下为 zsh-autosuggestions 设置快捷键
# 插入模式下的绑定
bindkey -M viins '^F' autosuggest-accept  # Ctrl+F 接受建议

# 普通模式下的绑定
bindkey -M vicmd 'L' autosuggest-accept   # 在普通模式下按 L 接受建议

# 如果您想使用右箭头接受建议（这是默认行为）
bindkey -M viins '^[[C' autosuggest-accept  # 右箭头
bindkey -M vicmd '^[[C' autosuggest-accept  # 普通模式下的右箭头

# 部分接受建议（接受到光标处）
bindkey -M viins '^B' autosuggest-accept-line  # Ctrl+B 接受当前行的建议
alias nvidia-enable-with-audio='sudo virsh nodedev-reattach pci_0000_01_00_0 && sudo virsh nodedev-reattach pci_0000_01_00_1 && echo "GPU reattached (now host ready)" && sudo rmmod vfio_pci vfio_pci_core vfio_iommu_type1 && echo "VFIO drivers removed" && sudo modprobe -i nvidia_modeset nvidia_uvm nvidia nvidia_drm && systemctl --user restart pipewire.service &&echo "NVIDIA drivers added" && echo "COMPLETED!"'
alias nvidia-enable='sudo virsh nodedev-reattach pci_0000_01_00_0 && echo "GPU reattached (now host ready)" && sudo rmmod vfio_pci vfio_pci_core vfio_iommu_type1 && echo "VFIO drivers removed" && sudo modprobe -i nvidia_modeset nvidia_drm nvidia_uvm nvidia && echo "NVIDIA drivers added" && echo "COMPLETED!"'
alias nvidia-disable='sudo rmmod -f  nvidia_drm nvidia_modeset nvidia_uvm nvidia && echo "NVIDIA drivers removed" && sudo modprobe -i vfio_pci vfio_pci_core vfio_iommu_type1 && echo "VFIO drivers added" && sudo virsh nodedev-detach pci_0000_01_00_0 && echo "GPU detached (now vfio ready)" && echo "COMPLETED!"'


## ---------------------------------------------------
## >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

eval $(thefuck --alias)
alias lzd='lazydocker'
eval "$(uv generate-shell-completion zsh)"
eval "$(direnv hook zsh)"

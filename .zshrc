export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="random"

plugins=(
  git
  command-not-found
  colored-man-pages
  extract
  history
  jsontools
  python
  rust
  fzf
  zsh-completions
  zsh-autosuggestions
)

source "$ZSH/oh-my-zsh.sh"


# vi mode
bindkey -v
# Higher timeout inside tmux — avoids jk/jj timing collisions with tmux buffering
[[ -n $TMUX ]] && KEYTIMEOUT=5 || KEYTIMEOUT=1

# quick escape from insert mode
bindkey -M viins 'jk' vi-cmd-mode
bindkey -M viins 'jj' vi-cmd-mode

# keep useful readline-like keys in insert mode
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line
bindkey -M viins '^R' history-incremental-search-backward
bindkey -M viins '^W' backward-kill-word

# cursor shape — use echoti to go through terminfo, not raw print
_zsh_vi_cursor() {
  local shape
  case "$KEYMAP" in
    vicmd)      shape=2 ;;  # block
    viins|main) shape=6 ;;  # beam
  esac
  [[ -n $TMUX ]] && printf '\ePtmux;\e\e[%d q\e\\' "$shape" \
                 || printf '\e[%d q' "$shape"
}

zle -N zle-keymap-select _zsh_vi_cursor
zle -N zle-line-init     _zsh_vi_cursor

autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsh_vi_cursor

# ls colours. Lain palette; hexes resolved through the role map in
# lain-colors.md. See .dircolors for the indexed profile everything else uses.
#
#   directory      highprimary   #C1B48E   193;180;142
#   symlink        foreprimary   #CE7688   206;118;136
#   executable     accent        #FFB1C3   255;177;195
#   read bits      hightertiary  #A49978   164;153;120
#   write bits     foreprimary   #CE7688   206;118;136
#   exec bits      accent        #FFB1C3   255;177;195
#   size unit      highsenary    #7A7158   122;113;88
#   date           foresenary    #804654   128;70;84

# LS_COLORS drives zsh completion listings and GNU coreutils; eza reads it too,
# then EZA_COLORS overrides the keys below. It was previously unset, which left
# .dircolors doing nothing at all.
if [ -r "$HOME/.dircolors" ] && command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b "$HOME/.dircolors")"
fi

export EZA_COLORS="\
ur=38;2;164;153;120:\
uw=38;2;206;118;136:\
ux=38;2;255;177;195:\
ue=38;2;255;177;195:\
gr=38;2;164;153;120:\
gw=38;2;206;118;136:\
gx=38;2;255;177;195:\
tr=38;2;164;153;120:\
tw=38;2;206;118;136:\
tx=38;2;255;177;195:\
sn=38;2;193;180;142:\
sb=38;2;122;113;88:\
da=38;2;128;70;84:\
di=38;2;193;180;142:\
ln=38;2;206;118;136:\
ex=38;2;255;177;195"

# Exports
export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export BROWSER="firefox"
export PATH="$HOME/.local/bin:$PATH"

HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY

# Aliases
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -lah --icons=auto --group-directories-first'
alias la='eza -la --icons=auto --group-directories-first'
alias lt='eza --tree --icons=auto --group-directories-first'
alias cat='bat'
alias vi='nvim'
alias vim='nvim'
alias v='nvim'
alias yz='yazi'
alias c='clear'
alias q='exit'

alias xi='doas xbps-install -S'
alias xu='doas xbps-install -Syu'
alias xr='doas xbps-remove -R'
alias xs='xbps-query -Rs'
alias xl='xbps-query -l | grep -i'
alias xo='doas xbps-remove -o'
alias xc='doas xbps-remove -O'

alias svs='doas sv status'
alias svu='doas sv up'
alias svd='doas sv down'
alias svr='doas sv restart'

alias wifi='nmcli dev wifi list'
alias ports='ss -tulpen'
alias myip='ip -br a'
alias route='ip route'


# VPN/Wireguard aliases
vpn-down() {
    nmcli -t -f NAME,TYPE connection show --active \
        | awk -F: '$2=="wireguard"{print $1}' \
        | while read -r conn; do
            doas nmcli connection down "$conn"
        done
}

vpn-up() {
    [ -n "$1" ] || {
        echo "usage: vpn-up <wg-profile>"
        nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="wireguard"{print $1}'
        return 1
    }

    vpn-down
    doas nmcli connection up "$1"
}

vpn-list() {
    nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="wireguard"{print $1}'
}

vpn-active() {
    nmcli connection show --active
    doas wg
}

# Power Profile aliases
alias pwr-performance='powerprofilesctl set performance'
alias pwr-balanced='powerprofilesctl set balanced'
alias pwr-save='powerprofilesctl set power-saver'
alias pwr-get='powerprofilesctl get'

alias lsblko='lsblk -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINT,ROTA,RO,RM,VENDOR,MODEL,SERIAL,TRAN,STATE,OWNER,GROUP,MODE,MAJ:MIN'

# Dictionary lookup — exact-headword entry across all dicts in ~/.dicts
def() {
    for f in ~/.dicts/*(.); do
        awk -v w="$1" -v src="${f:t}" '
            BEGIN { IGNORECASE=1; found=0 }
            /^[^ \t]/ { printing = (tolower($0) == tolower(w)); if (printing && !found){ print "=== " src " ==="; found=1 } }
            printing { print }
        ' "$f"
    done | bat --paging=always --language=txt
}

autoload -Uz compinit
compinit

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

# zoxide — must be LAST (after compinit + all PATH/eval blocks); --cmd cd replaces builtin cd
# cd <query> jumps by frecency, cdi = interactive pick
eval "$(zoxide init zsh --cmd cd)"
export OLLAMA_MODELS=/mnt/hgst/ollama-models

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

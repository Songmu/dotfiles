if [[ $ZPROF_DEBUG != "" ]]; then
  zmodload zsh/zprof && zprof
fi

export LANG=en_US.UTF-8

if [[ -t 0 ]]; then
  stty -ixon
fi

if [[ -z "$HOMEBREW_PREFIX" ||
      ":$PATH:" != *":$HOMEBREW_PREFIX/bin:"* ||
      ":$PATH:" != *":$HOMEBREW_PREFIX/sbin:"* ||
      ":$FPATH:" != *":$HOMEBREW_PREFIX/share/zsh/site-functions:"* ]]; then
  for brew_cmd in "${commands[brew]:-}" /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [[ -x "$brew_cmd" ]]; then
      eval "$("$brew_cmd" shellenv zsh)"
      break
    fi
  done
  unset brew_cmd
fi

if which direnv > /dev/null; then
  eval "$(direnv hook zsh)"
fi

export GOPATH=~/dev

typeset -U path PATH
path=(
    ~/bin
    ~/.plenv/libexec
    ~/.plenv/shims
    ~/.bun/bin
    $GOPATH/bin
    $path
    /usr/local/sbin
)
if which ghg > /dev/null; then
  export PATH=$(ghg bin):$PATH
fi

init_env() {
  local env_cmd=$1
  unset -f $env_cmd
  if which $env_cmd > /dev/null; then eval "$($env_cmd init --no-rehash -)"; fi
}

plenv() {
  init_env plenv
  plenv "$@"
}

[ -f ~/.zshrc.local ] && source ~/.zshrc.local
[ -f ~/.cargo/env ] && source ~/.cargo/env

export COPILOT_OTEL_ENABLED=true
export COPILOT_OTEL_EXPORTER_TYPE=file
export COPILOT_OTEL_FILE_EXPORTER_PATH="$HOME/.copilot/otel/copilot-otel.jsonl"

autoload -Uz add-zsh-hook

if [[ -r "$HOME/.zplug/init.zsh" ]]; then
  if [[ ! -f "$HOME/.zplug/packages.zsh" &&
        ( -z "$ZPLUG_LOADFILE" || "$ZPLUG_LOADFILE" == "$HOME/.zplug/packages.zsh" ) ]]; then
    export ZPLUG_LOADFILE="$HOME/.zsh/plugins.zsh"
  fi
  source ~/.zplug/init.zsh
  if [[ "$ZPLUG_LOADFILE" != "$HOME/.zsh/plugins.zsh" ]]; then
    source "$HOME/.zsh/plugins.zsh"
  fi

  zplug load
fi

cleanup_cdd() {
  if [ -n "$WINDOW" ] && [ -f "$CDD_FILE" ]; then
    _cdd_delete $WINDOW
  fi
}
(( $+functions[_cdd_delete] )) && add-zsh-hook zshexit cleanup_cdd
(( $+functions[_cdd_chpwd] )) && add-zsh-hook chpwd _cdd_chpwd

setopt magic_equal_subst

# use 'exit' to exit.
setopt IGNOREEOF
setopt COMBINING_CHARS

autoload -U zmv
alias zmv='noglob zmv'

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats '%F{red}(%s %b)%f'
zstyle ':vcs_info:*' disable-patterns "$HOME/"
zstyle ':vcs_info:*' disable-patterns "$HOME/temporary/"

setopt prompt_subst
my_precmd () {
  LANG=en_US.UTF-8 vcs_info
  local line1="%F{yellow}%~%f ${vcs_info_msg_0_}"
  local line2
  if [ -z "${SSH_CONNECTION}" ]; then
    line2="[%*]$ "
  else
    line2="%F{green}[%n@%m]$%f "
  fi
  PROMPT=$'\n'"${line1}"$'\n'"${line2}"

  if [[ -n "$STY" ]]; then
    screen -X title $(basename $(print -P "%~"))
  fi
}
add-zsh-hook precmd my_precmd

PROMPT2='[%n]> '
RPROMPT="%(?.%F{green}%?%f.%F{red}%?%f)"
setopt transient_rprompt

# chpwd cdr
autoload -U chpwd_recent_dirs cdr
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ":chpwd:*" recent-dirs-max 500
zstyle ":chpwd:*" recent-dirs-default true
zstyle ":completion:*" recent-dirs-insert always

#履歴
HISTFILE=${HISTFILE:-$HOME/.zsh_history}
if [[ -f "$HOME/Dropbox/.zsh_history" ]]; then
  HISTFILE="$HOME/Dropbox/.zsh_history"
fi
HISTSIZE=10000000
SAVEHIST=10000000

setopt hist_ignore_dups
setopt share_history
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt hist_no_store

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
bindkey "^?" backward-delete-char

bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward

bindkey '^]' peco-src
bindkey '^^' peco-select-history
bindkey '^@' peco-cdr

#エディタ
export GIT_MERGE_AUTOEDIT=no
export EDITOR=vim

#ビープ音ならなさない
setopt nobeep

#cd
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups

#lsと補間にでる一覧の色
export LSCOLORS=gxfxxxxxcxxxxxxxxxgxgx
export LS_COLORS='di=01;36:ln=01;35:ex=01;32'
zstyle ':completion:*' list-colors 'di=36' 'ln=35' 'ex=32'

#デフォルトパーミッションの設定
umask 022

#alias
case "${OSTYPE}" in
freebsd*|darwin*)
  alias ls="ls -GFa"
  ;;
linux*)
  alias ls="ls -Fa --color"
  ;;
esac

alias ll='ls -l'
alias gi="git"
alias gti="git"

#改行のない出力をプロンプトで上書きするのを防ぐ
unsetopt promptcr

#screenのステータスラインに最後に実行したコマンドを表示
if [[ -n "$STY" ]]; then
    set_screen_status() {
        # see [zsh-workers:13180]
        # http://www.zsh.org/mla/workers/2000/msg03993.html
        emulate -L zsh
        local -a cmd; cmd=(${(z)2})
        local dir=$(basename $(print -P "%~"))
        case $cmd[1] in
            fg)
                if (( $#cmd == 1 )); then
                    cmd=(builtin jobs -l %+)
                else
                    cmd=(builtin jobs -l $cmd[2])
                fi
                ;;
            %*)
                cmd=(builtin jobs -l $cmd[1])
                ;;
            cd)
                return
                ;;
            *)
                echo -n "k$cmd[1]:t:$dir\\"
                return
                ;;
        esac

        local -A jt; jt=(${(kv)jobtexts})
        $cmd >>(read num rest
            cmd=(${(z)${(e):-\$jt$num}})
            echo -n "k$cmd[1]:t:$dir\\") 2>/dev/null
    }
    add-zsh-hook preexec set_screen_status
fi

#w3m4alc
alc() {
  if [ $# != 0 ]; then
    w3m "http://eow.alc.co.jp/$*/UTF-8/?ref=sa" | \less +97
  else
    echo 'usage: alc word'
  fi
}

## peco
peco-src () {
    local selected_dir=$(ghq list | peco --query "$LBUFFER")
    if [ -n "$selected_dir" ]; then
        selected_dir=$(ghq list --full-path --exact "$selected_dir")
        BUFFER="cd -- ${(q)selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-src

peco-select-history() {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    elif which gtac > /dev/null; then
        tac="gtac"
    else
        tac="tail -r"
    fi
    BUFFER=$(history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history

peco-cdr () {
    local -a reply
    cdr -r || return
    local selected_dir=$(print -rl -- "${reply[@]}" | peco)
    if [ -n "$selected_dir" ]; then
        BUFFER="cd -- ${(q)selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-cdr

if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

if (which zprof > /dev/null 2>&1); then
  zprof
fi

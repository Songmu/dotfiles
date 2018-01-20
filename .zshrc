#文字コード
export LANG=en_US.UTF-8

stty -ixon

source ~/.zplug/init.zsh

zplug "m4i/cdd", use:"cdd"
zplug "mafredri/zsh-async"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "chrissicool/zsh-256color"
zplug "~/.zsh/my-completions", from:local, use:"*"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi
# Then, source plugins and add commands to $PATH
zplug load

cleanup_cdd() {
  if [ -n "$WINDOW" ]; then
    _cdd_delete $WINDOW
  fi
}
# add-zsh-hook have loaded in zplug
add-zsh-hook zshexit cleanup_cdd
add-zsh-hook chpwd _cdd_chpwd

# use 'exit' to exit.
setopt IGNOREEOF
setopt COMBINING_CHARS

autoload -U zmv
alias zmv='noglob zmv'

autoload -Uz vcs_info
zstyle ':vcs_info:*' formats '%{'${fg[red]}'%}(%s %b) %{'$reset_color'%}'

setopt prompt_subst
my_precmd () {
  LANG=en_US.UTF-8 vcs_info
  if [ -z "${SSH_CONNECTION}" ]; then
    PROMPT="
 %{${fg[yellow]}%}%~%{${reset_color}%} ${vcs_info_msg_0_}
[%*]$ "
  else
    PROMPT="
 %{${fg[yellow]}%}%~%{${reset_color}%} ${vcs_info_msg_0_}
%{${fg[green]}%}[%n@%m]$%{${reset_color}%} "
  fi

  if [[ "$TERM" =~ ^screen ]]; then
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
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

#エディタ
export GIT_MERGE_AUTOEDIT=no
export EDITOR=vim

setopt hist_ignore_dups
setopt share_history
setopt hist_ignore_space
setopt hist_ignore_all_dups

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
bindkey "^?" backward-delete-char

bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward

bindkey '^]' peco-src
bindkey '^H' peco-select-history
bindkey '^@' peco-cdr
bindkey '^f' peco-mackerel-host

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
alias be="bundle exec"

#改行のない出力をプロンプトで上書きするのを防ぐ
unsetopt promptcr

#screenのステータスラインに最後に実行したコマンドを表示
if [[ "$TERM" =~ ^screen ]]; then
    #chpwd () { echo -n "_`dirs`\\" }
    set_screen_status() {
        # see [zsh-workers:13180]
        # http://www.zsh.org/mla/workers/2000/msg03993.html
        emulate -L zsh
        local -a cmd; cmd=(${(z)2})
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
                if (( $#cmd == 2)); then
                    cmd[1]=$cmd[2]
                fi
                ;&
            *)
                echo -n "k$cmd[1]:t\\"
                return
                ;;
        esac

        local -A jt; jt=(${(kv)jobtexts})

        $cmd >>(read num rest
            cmd=(${(z)${(e):-\$jt$num}})
            echo -n "k$cmd[1]:t\\") 2>/dev/null
    }
    add-zsh-hook preexec set_screen_status
    chpwd () {}
fi

ssh_screen() {
    eval server=\${$#}
    screen -t $server ssh "$@"
}
if [[ "$TERM" =~ ^screen ]]; then
    alias ssh='ssh_screen'
fi

#w3m4alc
alc() {
  if [ $# != 0 ]; then
    w3m "http://eow.alc.co.jp/$*/UTF-8/?ref=sa" | \less +33
  else
    echo 'usage: alc word'
  fi
}

## peco
peco-src () {
    local selected_dir=$(ghq list | peco --query "$LBUFFER")
    if [ -n "$selected_dir" ]; then
        selected_dir="$GOPATH/src/$selected_dir"
        BUFFER="cd ${selected_dir}"
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
    local selected_dir=$(cdr -l | awk '{ print $2 }' | peco)
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-cdr

autoload -U modify-current-argument
autoload -U split-shell-arguments

peco-mackerel-host () {
    local mode_append_only=0
    local REPLY
    local reply

    split-shell-arguments
    if [ $(($REPLY % 2)) -eq 0 ]; then
        # query by word under cursor
        query_arg="--query=$reply[$REPLY]"
    elif [ -n "${LBUFFER##* }" ]; then
        # query by word just before cursor
        query_arg="--query=${LBUFFER##* }"
    else
        # no word detected
        query_arg='--query='
        mode_append_only=1
    fi

    res=$(mkr-hosts-tsv | eval peco "$query_arg")
    if [ -z "$res" ]; then
        zle reset-prompt
        return 1
    fi

    host=$(echo "$res" | cut -f2)

    if [ $mode_append_only = 1 ]; then
        LBUFFER+="ssh $host"
    else
        modify-current-argument "ssh $host"
    fi

    zle reset-prompt
}
zle -N peco-mackerel-host

# added by travis gem
[ -f ~/.travis/travis.sh ] && source ~/.travis/travis.sh

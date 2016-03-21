#文字コード
export LANG=ja_JP.UTF-8

stty -ixon

# use 'exit' to exit.
setopt IGNOREEOF
setopt COMBINING_CHARS

##
## ^[ <- これエスケープ {C-v ESC}
##

autoload colors
colors

autoload zmv
alias zmv='noglob zmv'

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' formats '%{'${fg[red]}'%}(%s %b) %{'$reset_color'%}'

setopt prompt_subst
precmd () {
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

  if [[ "$TERM" = "screen" ]]; then
    screen -X title $(basename $(print -P "%~"))
  fi
}

PROMPT2='[%n]> '
RPROMPT="%(?.%F{green}%?%f.%F{red}%?%f)"
setopt transient_rprompt

fpath=(~/.zsh/zsh-completions/src(N-/) $fpath)
fpath=(~/.zsh/my-completions(N-/) $fpath)
#補間
autoload -Uz compinit && compinit

# cdr
typeset -ga chpwd_functions
autoload -U chpwd_recent_dirs cdr
chpwd_functions+=chpwd_recent_dirs
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

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
bindkey "^?" backward-delete-char

bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward

bindkey '^F' peco-src
bindkey '^H' peco-select-history
bindkey '^@' peco-cdr

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

alias gs="git svn"
alias gi="git"
alias gti="git"
alias be="bundle exec"

alias screen='screen -U -D -RR'

alias perlsrc='perldoc -MPod::Strip'

alias ca='pygmentize -O style=vim -f console256 -g'

#改行のない出力をプロンプトで上書きするのを防ぐ
unsetopt promptcr

#screenのステータスラインに最後に実行したコマンドを表示
if [ "$TERM" = "screen" ]; then
    #chpwd () { echo -n "_`dirs`\\" }
    preexec() {
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
    chpwd () {}
fi

function ssh_screen(){
    eval server=\${$#}
    \screen -t $server ssh "$@"
}
if [ "$TERM" = "screen" ]; then
    alias ssh='ssh_screen'
fi

#w3m4alc
function alc() {
  if [ $# != 0 ]; then
    w3m "http://eow.alc.co.jp/$*/UTF-8/?ref=sa" | \less +33
  else
    echo 'usage: alc word'
  fi
}

#pminfo
function pminfo() {
  if [ $# != 0 ]; then
    perl -le 'eval "require $ARGV[0]";print ${"${ARGV[0]}::VERSION"};print qx/perldoc -ml $ARGV[0]/' $*
  else
    echo 'usage: pminfo perlmodule'
  fi
}

## peco
function peco-src () {
    local selected_dir=$(ghq list --full-path | perl -pe 's/(\Q$ENV{HOME}\E(.*$))/$2\0$1/' | peco --null --query "$LBUFFER")
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-src

function peco-select-history() {
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


function peco-cdr () {
    local selected_dir=$(cdr -l | awk '{ print $2 }' | peco)
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-cdr

# added by travis gem
[ -f /Users/Songmu/.travis/travis.sh ] && source /Users/Songmu/.travis/travis.sh

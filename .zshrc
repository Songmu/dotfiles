#文字コード
export LANG=ja_JP.UTF-8

PATH=$PATH:~/bin/
stty -ixon

#プロンプト
autoload colors
colors

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' formats '%{'${fg[red]}'%}(%s %b) %{'$reset_color'%}'

setopt prompt_subst
precmd () {
  LANG=en_US.UTF-8 vcs_info
  if [ -z "${SSH_CONNECTION}" ]; then
    PROMPT="
 %{${fg[yellow]}%}%~%{${reset_color}%} ${vcs_info_msg_0_}
[%n]$ "
  else
    PROMPT="
 %{${fg[yellow]}%}%~%{${reset_color}%} ${vcs_info_msg_0_}
%{${fg[green]}%}[%n@%m]$%{${reset_color}%} "
  fi

  if [ "$TERM" = "screen" ]; then
    screen -X title $(basename $(print -P "%~"))
  fi
}


PROMPT2='[%n]> ' 

#補間
autoload -U compinit
compinit

#履歴
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

#エディタ
export EDITOR=vim

setopt hist_ignore_dups
setopt share_history
setopt hist_ignore_space

#キーバインド
bindkey -v

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end 

bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward

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

alias pg="ps auxw | grep"

alias svnadd="svn st | grep '^?' | awk '{ print \$2 }' | xargs svn add"
alias svndel="svn st | grep '^!' | awk '{ print \$2 }' | xargs svn delete"

alias gs="git svn"
alias gi="git"
alias gti="git"

alias screen='screen -U -D -RR'

alias less='/usr/share/vim/vim73/macros/less.sh'
alias pad="plackup -p 1978 -MPlack::App::Directory -e 'Plack::App::Directory->new->to_app'"

alias perlsrc='perldoc -MPod::Strip'

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
    w3m "http://eow.alc.co.jp/$*/UTF-8/?ref=sa" | \less +38
    #w3m "http://eow.alc.co.jp/$*/UTF-8/?ref=sa"
  else
    echo 'usage: alc word'
  fi
}

#json_view
function json_view() {
  if [ $# != 0 ]; then
    perl -MLWP::Simple -MJSON -MData::Dumper -we 'print Dumper decode_json get $ARGV[0]' $*
  else
    echo 'usage: json_view url'
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

#url_decode
function url_decode() {
  if [ $# != 0 ]; then
    perl -MURI::Escape -wle 'print uri_unescape $ARGV[0]' $*
  else
    echo 'usage: url_decode url'
  fi
}

#imageinfo
function imageinfo() {
  if [ $# != 0 ]; then
    perl -MImage::Info -MYAML -le 'print $_, "\n", Dump Image::Info::image_info($_) for @ARGV'
  else
    echo 'usage: imageinfo file [file..]'
  fi
}

#perlbrew
[ -f ~/perl5/perlbrew/etc/bashrc ] && source ~/perl5/perlbrew/etc/bashrc

#pythonbrew
[ -f ~/.pythonbrew/etc/bashrc ] && source ~/.pythonbrew/etc/bashrc

#nvm
# [ -f ~/.nvm/nvm.sh ] && source ~/.nvm/nvm.sh

#個別設定を読み込む
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

if [[ -s ~/.rvm/scripts/rvm ]] ; then source ~/.rvm/scripts/rvm ; fi

export PATH=$HOME/.nodebrew/current/lib/node_modules/.bin:$HOME/.nodebrew/current/bin:$PATH

if [[ -f ~/.zsh/git-completion.bash ]]
then
    autoload bashcompinit
    bashcompinit
    source ~/.zsh/git-completion.bash
fi

#
# Set vi mode status bar
#

#
# Reads until the given character has been entered.
#
readuntil () {
    typeset a
    while [ "$a" != "$1" ]
    do
        read -E -k 1 a
    done
}

#
# If the $SHOWMODE variable is set, displays the vi mode, specified by
# the $VIMODE variable, under the current command line.
#
# Arguments:
#
#   1 (optional): Beyond normal calculations, the number of additional
#   lines to move down before printing the mode.  Defaults to zero.
#
showmode() {
    typeset movedown
    typeset row

    # Get number of lines down to print mode
    movedown=$(($(echo "$RBUFFER" | wc -l) + ${1:-0}))

    # Get current row position
    echo -n "\e[6n"
    row="${${$(readuntil R)#*\[}%;*}"

    # Are we at the bottom of the terminal?
    if [ $((row+movedown)) -gt "$LINES" ]
    then
        # Scroll terminal up one line
        echo -n "\e[1S"

        # Move cursor up one line
        echo -n "\e[1A"
    fi

    # Save cursor position
    echo -n "\e[s"

    # Move cursor to start of line $movedown lines down
    echo -n "\e[$movedown;E"

    # Change font attributes
    echo -n "\e[1m"

    # Has a mode been set?
    if [ -n "$VIMODE" ]
    then
        # Print mode line
        echo -n "-- $VIMODE -- "
    else
        # Clear mode line
        echo -n "\e[0K"
    fi

    # Restore font
    echo -n "\e[0m"

    # Restore cursor position
    echo -n "\e[u"
}

clearmode() {
    VIMODE= showmode
}

#
# Temporary function to extend built-in widgets to display mode.
#
#   1: The name of the widget.
#
#   2: The mode string.
#
#   3 (optional): Beyond normal calculations, the number of additional
#   lines to move down before printing the mode.  Defaults to zero.
#
makemodal () {
    # Create new function
    eval "$1() { zle .'$1'; ${2:+VIMODE='$2'}; showmode $3 }"

    # Create new widget
    zle -N "$1"
}

# Extend widgets
makemodal vi-add-eol           INSERT
makemodal vi-add-next          INSERT
makemodal vi-change            INSERT
makemodal vi-change-eol        INSERT
makemodal vi-change-whole-line INSERT
makemodal vi-insert            INSERT
makemodal vi-insert-bol        INSERT
makemodal vi-open-line-above   INSERT
makemodal vi-substitute        INSERT
makemodal vi-open-line-below   INSERT 1
makemodal vi-replace           REPLACE
makemodal vi-cmd-mode          NORMAL

unfunction makemodal

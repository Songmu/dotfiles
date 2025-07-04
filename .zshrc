export LANG=en_US.UTF-8

stty -ixon

zshrc=$HOME/.zshrc
if [ -L zshrc ]; then
  zshrc=$(readlink $zshrc)
fi
[ $zshrc -nt ~/.zshrc.zwc ] && zcompile ~/.zshrc

source ~/.zplug/init.zsh
zplug "m4i/cdd", use:"cdd"
zplug "mafredri/zsh-async"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "chrissicool/zsh-256color"
zplug "~/.zsh/my-completions", from:local, use:"*"

zplug load

cleanup_cdd() {
  if [ -n "$WINDOW" ] && [ -f "$CDD_FILE" ]; then
    _cdd_delete $WINDOW
  fi
}
# add-zsh-hook have loaded in zplug
add-zsh-hook zshexit cleanup_cdd
add-zsh-hook chpwd _cdd_chpwd

if (( $+commands[sw_vers] )) && (( $+commands[arch] )); then
    zsh() {
        local arch=$(uname -m)
        if  [[ "$arch" == "arm64" ]]; then
            exec arch -arch arm64 /opt/homebrew/bin/zsh
        elif [[ "$arch" == "x86_64" ]]; then
            exec arch -arch x86_64 /usr/local/bin/zsh
        fi
        exec /bin/zsh
    }

    [[ -x /usr/local/bin/brew ]] && alias xbrew="arch -arch x86_64 /usr/local/bin/brew"
    alias x64='exec arch -x86_64 /usr/local/bin/zsh'
    alias a64='exec arch -arm64 /opt/homebrew/bin/zsh'
    switch-arch() {
        local arch=$(uname -m)
        if  [[ "$arch" == "arm64" ]]; then
            exec arch -arch x86_64 /usr/local/bin/zsh
        elif [[ "$arch" == "x86_64" ]]; then
            exec arch -arch arm64 /opt/homebrew/bin/zsh
        fi
        exec /bin/zsh
    }
fi

setopt magic_equal_subst

# use 'exit' to exit.
setopt IGNOREEOF
setopt COMBINING_CHARS

autoload -U zmv
alias zmv='noglob zmv'

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats '%{'${fg[red]}'%}(%s %b) %{'$reset_color'%}'
zstyle ':vcs_info:*' disable-patterns "$HOME/"
zstyle ':vcs_info:*' disable-patterns "/Users/Songmu/temporary/"

awx-profiles() {
    local conf=${AWS_CONFIG_FILE:-~/.aws/config}
    grep "^\[.*\]" $conf | tr -d "[]" | sed -e "s/^profile //"
}

awx-complete() {
    _values "awx-complete" $(awx-profiles)
}

awx() {
  local aws_profile="$1"
  if [ -z "$aws_profile" ]; then
    aws_profile=$(awx-profiles | peco)
  fi
  if [ -z "${aws_profile}" ]; then return 1; fi
  export AWS_DEFAULT_PROFILE=$aws_profile
}
compdef awx-complete awx

setopt prompt_subst
my_precmd () {
  LANG=en_US.UTF-8 vcs_info
  if [ -z "${SSH_CONNECTION}" ]; then
    PROMPT="
%{${fg[yellow]}%}%~%{${reset_color}%} ${vcs_info_msg_0_}($(uname -m ))(aws ${AWS_DEFAULT_PROFILE:-default})
[%*]$ "
  else
    PROMPT="
%{${fg[yellow]}%}%~%{${reset_color}%} ${vcs_info_msg_0_}
%{${fg[green]}%}[%n@%m]$%{${reset_color}%} "
  fi

  if [[ "$SCREEN" == "1" ]]; then
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
HISTFILE="$HOME/Dropbox/.zsh_history"
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
if [[ "$SCREEN" == "1" ]]; then
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
        selected_dir=$(ghq list --full-path --exact $selected_dir)
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

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

eval "$(mise activate zsh)"

# bun completions
[ -s "/Users/Songmu/.bun/_bun" ] && source "/Users/Songmu/.bun/_bun"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/Songmu/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/Songmu/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/Songmu/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/Songmu/google-cloud-sdk/completion.zsh.inc'; fi

if (which zprof > /dev/null 2>&1); then
  zprof
fi


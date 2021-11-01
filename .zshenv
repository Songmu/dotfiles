if [[ $ZPROF_DEBUG != "" ]]; then
  zmodload zsh/zprof && zprof
fi

eval "$(direnv hook zsh)"

export GOPATH=~/dev

typeset -U path PATH
path=(
    /opt/homebrew/bin(N-/)
    ~/bin
    /usr/local/opt/ruby/bin
    ~/.plenv/libexec
    ~/.plenv/shims
    $GOPATH/bin
    /usr/local/bin
    $PATH
    /usr/local/sbin # nagios plugins
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

rbenv() {
  init_env rbenv
  rbenv "$@"
}

nodenv() {
  init_env nodenv
  nodenv "$@"
}

[ -f /usr/local/share/zsh/site-functions/_aws ] && source /usr/local/share/zsh/site-functions/_aws
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

if [[ $ZPROF_DEBUG != "" ]]; then
  zmodload zsh/zprof && zprof
fi

export GOPATH=$HOME/dev
export PATH=$HOME/.plenv/shims:$GOPATH/bin:$PATH:/usr/local/bin
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

export PATH=~/bin:/usr/local/opt/ruby/bin:$PATH:/usr/local/sbin

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

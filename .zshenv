export GOPATH=$HOME/dev
PATH=$PATH:/usr/local/bin
if which go > /dev/null; then
  PATH=$(go env GOROOT)/bin:$PATH
fi
PATH=$GOPATH/bin:$PATH

#plenv/rbenv
PATH=$HOME/.plenv/shims:$PATH
if which plenv > /dev/null; then eval "$(plenv init -)"; fi
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

export PATH=~/bin:$PATH:/usr/local/sbin

if command -v docker-machine > /dev/null; then
  local machine=$(docker-machine ls | grep Running | head -n 1 | awk '{ print $1 }')
  if [ "$machine" != "" ]; then
    eval "$(docker-machine env $machine)"
    export DOCKER_IP=$(docker-machine ip $machine)
  fi
fi

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

export GOPATH=$HOME/dev
export PATH=$HOME/.plenv/shims:$GOPATH/bin:$PATH:/usr/local/bin
if which ghg > /dev/null; then
  export PATH=$(ghg bin):$PATH
fi

#plenv/rbenv
if which plenv > /dev/null; then eval "$(plenv init -)"; fi
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
if which nodenv > /dev/null; then eval "$(nodenv init -)"; fi

export PATH=~/bin:$PATH:/usr/local/sbin

if command -v docker-machine > /dev/null; then
  local machine=$(docker-machine ls | grep Running | head -n 1 | awk '{ print $1 }')
  if [ "$machine" != "" ]; then
    eval "$(docker-machine env $machine)"
    export DOCKER_IP=$(docker-machine ip $machine)
  fi
fi

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

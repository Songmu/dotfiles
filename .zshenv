export GOPATH=$HOME/dev
export PATH=$HOME/.plenv/shims:$GOPATH/bin:$PATH:/usr/local/bin
if which ghg > /dev/null; then
  export PATH=$(ghg bin):$PATH
fi

for env_cmd in plenv rbenv nodenv; do
  if which $env_cmd > /dev/null; then eval "$($env_cmd init -)"; fi
done

export PATH=~/bin:$PATH:/usr/local/sbin

[ -f ~/.zshrc.local ] && source ~/.zshrc.local

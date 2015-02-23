PATH=~/bin:/usr/local/bin:/usr/local/sbin:$PATH
#plenv/rbenv
export PATH=$HOME/.plenv/shims:$HOEM/.rbenv/shims:$PATH
if which plenv > /dev/null; then eval "$(plenv init -)"; fi
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

export GOROOT=/usr/local/opt/go/libexec
export GOPATH=$HOME/dev
export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.nodebrew/current/lib/node_modules/.bin:$HOME/.nodebrew/current/bin:$PATH

if [ "$(boot2docker status)" = "running" ]; then
  $(boot2docker shellinit 2>/dev/null)
fi

#個別設定を読み込む
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

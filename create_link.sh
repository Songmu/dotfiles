#!/bin/sh
cd $(dirname $0)
for dotfile in .?*; do
    if [ $dotfile != '..' ] && \
        [ $dotfile != '.git' ] && \
        [ $dotfile != '.gitmodules' ] && \
        [ $dotfile != '.gitignore' ] && \
        [ $dotfile != '.config' ]; then
        ln -is "$PWD/$dotfile" $HOME
    fi
done

find .config -type f | while read file; do
    target_dir="$HOME/$(dirname $file)"
    mkdir -p "$target_dir"
    ln -is "$PWD/$file" "$HOME/$file" < /dev/tty
done


#!/bin/sh
cd $(dirname $0)
for dotfile in .?*
do
    if [ $dotfile != '..' ] && [ $dotfile != '.git' ] && [ $dotfile != 'vimfiles' ]
    then
        ln -Fis "$PWD/$dotfile" $HOME
    fi
done
ln -s ~/.dotfiles/vimfiles ~/.vim

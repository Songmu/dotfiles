#!/bin/sh
cd $(dirname $0)
for dotfile in .?*
do
    if [ $dotfile != '..' ] && [ $dotfile != '.git' ] && [ $dotfile != 'vimfiles' ] && [ $dotfile != '.gitmodules' ] && [ $dotfile != '.gitignore' ]
    then
        ln -is "$PWD/$dotfile" $HOME
    fi
done

if [ ! -d ~/.vim ]
then
    ln -s ~/.dotfiles/vimfiles ~/.vim
fi

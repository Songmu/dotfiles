#!/bin/zsh
for f in $(find .zplug -name "*.zsh"); do
  zcompile $f
done

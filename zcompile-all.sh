#!/bin/zsh
for f in $(find .zplug/repos -name "*.zsh"); do
  zcompile $f
done

#!/bin/bash

# Install tmuxinator completion if it doesn't exist
if [ ! -f "/usr/local/share/zsh/site-functions/_tmuxinator" ]; then
  wget https://raw.githubusercontent.com/tmuxinator/tmuxinator/master/completion/tmuxinator.zsh -O /usr/local/share/zsh/site-functions/_tmuxinator
fi
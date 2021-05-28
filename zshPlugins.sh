#!/bin/sh

cd ~/.oh-my-zsh/custom/plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting
sudo sed -e '/plugins/d' ~/.zshrc
sudo sed '73 aplugins=(git zsh-syntax-highlighting colored-man-pages)' -i ~/.zshrc
source ~/.zshrc


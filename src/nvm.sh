#!/bin/bash
root_path=$(dirname "$(readlink -f "$0")")
brew_install=$root_path/../conf/brew_install.sh

$brew_install "nvm"


mkdir ~/.nvm

echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm' >> ~/.zshrc
echo '[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion' >> ~/.zshrc

source ~/.zshrc

nvm install 18
nvm install 16.15.0
nvm install 14
nvm install 12

nvm alias default 16

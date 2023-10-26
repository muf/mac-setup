#!/bin/bash
root_path=$(dirname "$(readlink -f "$0")")
brew_install=$root_path/../conf/brew_install.sh

$brew_install -c "google-chrome"

cd  ~/Library/Application\ Support/Google
sudo chmod a+w Chrome

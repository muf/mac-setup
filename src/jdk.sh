#!/bin/bash
root_path=$(dirname "$(readlink -f "$0")")
brew_install=$root_path/../conf/brew_install.sh

$brew_install -c "adoptopenjdk/openjdk/adoptopenjdk11"
$brew_install -c "adoptopenjdk/openjdk/adoptopenjdk18"

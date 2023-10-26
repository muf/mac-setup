#!/bin/bash
root_path=$(dirname "$(readlink -f "$0")")
brew_install=$root_path/../conf/brew_install.sh

$brew_install "zsh"

# 패키지가 잘 설치 되었는지 확인
if brew list $package_name; then
    echo ">>> 테마 설정 진행합니다."

    chsh -s `which zsh`

    sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

    # zsh 테마 변경
    new_theme="agnoster"

    # ~/.zshrc 파일 경로
    zshrc_file="$HOME/.zshrc"

    # ZSH_THEME 값을 변경
    sed -i '' "s/ZSH_THEME=.*/ZSH_THEME=\"$new_theme\"/" "$zshrc_file"

    echo ">>> ZSH_THEME가 \"$new_theme\"(으)로 설정되었습니다."
else
    echo ">>> 정상적으로 설치되지 않았습니다"
fi

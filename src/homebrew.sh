#!/bin/bash
# Homebrew가 이미 설치되었는지 확인
if ! command -v brew &> /dev/null; then
    echo ">>> Homebrew를 설치합니다."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo ">>> Homebrew는 이미 설치되어 있습니다."
fi


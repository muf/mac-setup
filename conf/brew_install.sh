#!/bin/bash

while getopts ":c" opt; do
  case $opt in
    c)
      cask_option=true
      ;;
    \?)
      echo "사용법: $0 [-c]"
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

if [ "$cask_option" = true ]; then
  echo ">>> --cask 옵션이 사용됨"
else
  echo ">>> --cask 옵션이 사용되지 않음"
fi

package_name="$1"

# 패키지가 이미 설치되어 있는지 확인
if brew list $package_name; then
    echo ">>> 패키지 $package_name 가 이미 설치되어 있습니다."
else
    echo ">>> 패키지 $package_name 를 설치합니다."
    if [ "$cask_option" = true ]; then
        brew install --cask $package_name
    else
        brew install $package_name
    fi
fi

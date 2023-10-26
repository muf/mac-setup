#!/bin/bash

root_path=$(dirname "$(readlink -f "$0")")

echo -e "\n"

# 실행에 필요한 스크립트 권한 755 변경
./conf/chmod.sh

# 실행 가능한 스크립트 목록 생성
ls "$root_path/src" > $root_path/conf/install_list

# todo 파일 생성 (최초 1회)
cat "$root_path/conf/todo.md" > $root_path/todo.md

# 기본 경로 생성
mkdir /Users/user/workspace
mkdir /Users/user/workspace/oss

cd /Users/user/workspace/oss
# git clone https://oss.navercorp.com/userfeedback/console


# guide
echo -e "\n>>> /conf 하위의 install_list 목록을 확인 후 설치를 원하지 않는 경우 주석 처리 해주세요. 이후 run.sh 를 실행하면 설치가 진행됩니다. \n"


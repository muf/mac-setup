#!/bin/bash

path=$(dirname "$(readlink -f "$0")")

# 파일 이름을 저장할 배열을 생성
files=()

# 파일에서 주석 처리되지 않은 줄을 읽고 배열에 추가
while IFS= read -r line; do
    if [[ ! $line =~ ^\s*# ]]; then
        files+=("$line")
    fi
done < $path/install_list

# 배열에 저장된 파일 목록을 출력
for file in "${files[@]}"; do
    echo "$file"
done



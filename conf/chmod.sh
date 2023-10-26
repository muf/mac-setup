#!/bin/bash

# 현재 스크립트 파일의 경로를 변수에 저장
script_path="$(readlink -f "$0")"

# 상위 디렉토리 경로 계산
src_path="$(dirname "$script_path")/../"

# 파일에 대해서만 권한 변경
find "$src_path" -type f -exec chmod 755 {} +

# 권한 변경 완료 메시지 출력
echo "$src_path 하위의 모든 파일의 권한을 755로 변경하였습니다."


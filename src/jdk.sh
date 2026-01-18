#!/bin/bash

# SDKMAN 설치 확인 및 설치
if [ ! -d "$HOME/.sdkman" ]; then
    echo ">>> SDKMAN을 설치합니다."
    curl -s "https://get.sdkman.io" | bash
else
    echo ">>> SDKMAN은 이미 설치되어 있습니다."
fi

# SDKMAN 초기화
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# zshrc에 SDKMAN 초기화 스크립트 추가 (이미 추가되어 있지 않은 경우)
if ! grep -q "sdkman-init.sh" ~/.zshrc 2>/dev/null; then
    echo "" >> ~/.zshrc
    echo "# SDKMAN 초기화" >> ~/.zshrc
    echo 'export SDKMAN_DIR="$HOME/.sdkman"' >> ~/.zshrc
    echo '[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"' >> ~/.zshrc
    echo ">>> SDKMAN 초기화 스크립트를 ~/.zshrc에 추가했습니다."
fi

# JDK 설치 (Eclipse Temurin)
echo ">>> JDK 11 (Eclipse Temurin) 설치 중..."
sdk install java 11-tem 2>/dev/null || echo ">>> JDK 11이 이미 설치되어 있거나 설치에 실패했습니다."

echo ">>> JDK 17 (Eclipse Temurin) 설치 중..."
sdk install java 17-tem 2>/dev/null || echo ">>> JDK 17이 이미 설치되어 있거나 설치에 실패했습니다."

echo ">>> JDK 21 (Eclipse Temurin) 설치 중..."
sdk install java 21-tem 2>/dev/null || echo ">>> JDK 21이 이미 설치되어 있거나 설치에 실패했습니다."

echo ">>> JDK 25 (Eclipse Temurin) 설치 중..."
sdk install java 25-tem 2>/dev/null || echo ">>> JDK 25이 이미 설치되어 있거나 설치에 실패했습니다."

# JDK 25를 default로 설정
echo ">>> JDK 25를 default로 설정합니다."
sdk default java 25-tem 2>/dev/null || echo ">>> JDK 25 default 설정에 실패했습니다."

# Maven 설치
echo ">>> Maven 2 최신 버전 설치 중..."
sdk install maven 2 2>/dev/null || echo ">>> Maven 2가 이미 설치되어 있거나 설치에 실패했습니다."

echo ">>> Maven 3 최신 버전 설치 중..."
sdk install maven 3 2>/dev/null || echo ">>> Maven 3가 이미 설치되어 있거나 설치에 실패했습니다."

# Maven 3를 default로 설정
echo ">>> Maven 3를 default로 설정합니다."
sdk default maven 3 2>/dev/null || echo ">>> Maven 3 default 설정에 실패했습니다."

# Gradle 최신 major 버전 2개 찾기 및 설치
echo ">>> Gradle 최신 major 버전 2개 찾는 중..."

# SDKMAN에서 사용 가능한 Gradle 버전 목록 가져오기
GRADLE_LIST=$(sdk list gradle 2>/dev/null)

# Major 버전 추출 (예: 8.9, 9.0 -> 8, 9)
MAJOR_VERSIONS=$(echo "$GRADLE_LIST" | grep -oE "^\s*[0-9]+\." | sed 's/[^0-9]//g' | sort -n -r | uniq | head -2)

if [ -n "$MAJOR_VERSIONS" ]; then
    GRADLE_ARRAY=($MAJOR_VERSIONS)
    LATEST_MAJOR=${GRADLE_ARRAY[0]}
    SECOND_MAJOR=${GRADLE_ARRAY[1]}
    
    if [ -n "$SECOND_MAJOR" ] && [ "$SECOND_MAJOR" != "$LATEST_MAJOR" ]; then
        echo ">>> Gradle $SECOND_MAJOR.x 설치 중..."
        sdk install gradle $SECOND_MAJOR 2>/dev/null || echo ">>> Gradle $SECOND_MAJOR.x가 이미 설치되어 있거나 설치에 실패했습니다."
    fi
    
    if [ -n "$LATEST_MAJOR" ]; then
        echo ">>> Gradle $LATEST_MAJOR.x 설치 중..."
        sdk install gradle $LATEST_MAJOR 2>/dev/null || echo ">>> Gradle $LATEST_MAJOR.x가 이미 설치되어 있거나 설치에 실패했습니다."
        # 가장 최신 Gradle을 default로 설정
        echo ">>> Gradle $LATEST_MAJOR.x를 default로 설정합니다."
        sdk default gradle $LATEST_MAJOR 2>/dev/null || echo ">>> Gradle default 설정에 실패했습니다."
    fi
else
    echo ">>> Gradle 버전을 찾을 수 없습니다. 최신 버전을 설치합니다."
    sdk install gradle 2>/dev/null || echo ">>> Gradle 설치에 실패했습니다."
    sdk default gradle 2>/dev/null || echo ">>> Gradle default 설정에 실패했습니다."
fi

echo ">>> JDK/Maven/Gradle 설치가 완료되었습니다."

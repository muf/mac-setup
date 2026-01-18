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
echo ">>> Maven 버전 확인 중..."
MAVEN_LIST=$(sdk list maven 2>/dev/null)

# Maven 2.x 최신 버전 찾기
MAVEN_2_VERSION=$(echo "$MAVEN_LIST" | grep -E "^\s*2\.[0-9]" | head -1 | awk '{print $NF}' | tr -d '|' | xargs)
if [ -n "$MAVEN_2_VERSION" ]; then
    echo ">>> Maven $MAVEN_2_VERSION 설치 중..."
    sdk install maven $MAVEN_2_VERSION < /dev/null || echo ">>> Maven $MAVEN_2_VERSION이 이미 설치되어 있거나 설치에 실패했습니다."
else
    echo ">>> Maven 2.x 버전을 찾을 수 없습니다."
fi

# Maven 3.x 최신 버전 찾기
MAVEN_3_VERSION=$(echo "$MAVEN_LIST" | grep -E "^\s*3\.[0-9]" | head -1 | awk '{print $NF}' | tr -d '|' | xargs)
if [ -n "$MAVEN_3_VERSION" ]; then
    echo ">>> Maven $MAVEN_3_VERSION 설치 중..."
    sdk install maven $MAVEN_3_VERSION < /dev/null || echo ">>> Maven $MAVEN_3_VERSION이 이미 설치되어 있거나 설치에 실패했습니다."
    # Maven 3를 default로 설정
    echo ">>> Maven $MAVEN_3_VERSION을 default로 설정합니다."
    sdk default maven $MAVEN_3_VERSION 2>/dev/null || echo ">>> Maven default 설정에 실패했습니다."
else
    echo ">>> Maven 3.x 버전을 찾을 수 없습니다."
fi

# Gradle 최신 major 버전 2개 찾기 및 설치
echo ">>> Gradle 최신 major 버전 2개 찾는 중..."

# SDKMAN에서 사용 가능한 Gradle 버전 목록 가져오기
GRADLE_LIST=$(sdk list gradle 2>/dev/null)

# 사용 가능한 모든 Gradle 버전 추출 (예: 9.0, 8.9, 8.8 등)
GRADLE_VERSIONS=$(echo "$GRADLE_LIST" | grep -E "^\s*[0-9]+\.[0-9]" | awk '{print $NF}' | tr -d '|' | xargs | tr ' ' '\n' | sort -V -r)

if [ -n "$GRADLE_VERSIONS" ]; then
    # Major 버전별로 그룹화하여 최신 버전 찾기
    LATEST_MAJOR_NUM=$(echo "$GRADLE_VERSIONS" | head -1 | cut -d. -f1)
    SECOND_MAJOR_NUM=$(echo "$GRADLE_VERSIONS" | awk -F. '{print $1}' | sort -n -r | uniq | sed -n '2p')
    
    # 각 major 버전의 최신 버전 찾기
    LATEST_VERSION=$(echo "$GRADLE_VERSIONS" | grep "^${LATEST_MAJOR_NUM}\." | head -1)
    
    if [ -n "$SECOND_MAJOR_NUM" ] && [ "$SECOND_MAJOR_NUM" != "$LATEST_MAJOR_NUM" ]; then
        SECOND_LATEST_VERSION=$(echo "$GRADLE_VERSIONS" | grep "^${SECOND_MAJOR_NUM}\." | head -1)
        if [ -n "$SECOND_LATEST_VERSION" ]; then
            echo ">>> Gradle $SECOND_LATEST_VERSION 설치 중..."
            sdk install gradle $SECOND_LATEST_VERSION < /dev/null || echo ">>> Gradle $SECOND_LATEST_VERSION이 이미 설치되어 있거나 설치에 실패했습니다."
        fi
    fi
    
    if [ -n "$LATEST_VERSION" ]; then
        echo ">>> Gradle $LATEST_VERSION 설치 중..."
        sdk install gradle $LATEST_VERSION < /dev/null || echo ">>> Gradle $LATEST_VERSION이 이미 설치되어 있거나 설치에 실패했습니다."
        # 가장 최신 Gradle을 default로 설정
        echo ">>> Gradle $LATEST_VERSION을 default로 설정합니다."
        sdk default gradle $LATEST_VERSION 2>/dev/null || echo ">>> Gradle default 설정에 실패했습니다."
    fi
else
    echo ">>> Gradle 버전을 찾을 수 없습니다. 최신 버전을 설치합니다."
    sdk install gradle < /dev/null || echo ">>> Gradle 설치에 실패했습니다."
    INSTALLED_GRADLE=$(sdk list gradle | grep "installed" | head -1 | awk '{print $NF}' | tr -d '|' | xargs)
    if [ -n "$INSTALLED_GRADLE" ]; then
        sdk default gradle $INSTALLED_GRADLE 2>/dev/null || echo ">>> Gradle default 설정에 실패했습니다."
    fi
fi

echo ">>> JDK/Maven/Gradle 설치가 완료되었습니다."

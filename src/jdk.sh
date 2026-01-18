#!/bin/bash

# SDKMAN 패키지 설치 함수 (이미 설치된 경우와 실패를 구분)
install_sdk_package() {
    local candidate=$1
    local version=$2
    
    # 패키지 이름 설정
    if [ -z "$version" ]; then
        local package_name="$candidate (최신 버전)"
        local install_cmd="sdk install $candidate"
    else
        local package_name="$candidate $version"
        local install_cmd="sdk install $candidate $version"
    fi
    
    # 이미 설치되어 있는지 확인 (sdk list 출력에서 확인)
    local candidate_list=$(sdk list $candidate 2>/dev/null)
    
    if [ -n "$version" ]; then
        # 버전이 지정된 경우: 해당 버전이 설치되어 있는지 확인
        # SDKMAN 출력 형식 예시:
        # " > 3.3.9          | installed  | 3.3.9"
        # "   3.3.9          | local only | 3.3.9"
        # " > 3.3.9          |            | 3.3.9" (현재 사용 중)
        
        # 현재 사용 중인 버전 (>) 또는 설치된 버전 (installed/local only) 확인
        local installed_line=$(echo "$candidate_list" | grep -E "^\s*[>|\*]\s+${version}\s+\|" | head -1)
        local installed_only=$(echo "$candidate_list" | grep -E "^\s+${version}\s+\|\s+(installed|local only)" | head -1)
        
        if [ -n "$installed_line" ] || [ -n "$installed_only" ]; then
            echo ">>> $package_name은(는) 이미 설치되어 있습니다."
            return 0
        fi
    else
        # 버전이 지정되지 않은 경우: 설치된 버전이 있는지 확인
        local installed_line=$(echo "$candidate_list" | grep -E "^\s*[>|\*]\s+" | head -1)
        if [ -n "$installed_line" ]; then
            # 버전 번호 추출 (공백으로 구분된 두 번째 필드)
            local installed_version=$(echo "$installed_line" | awk '{for(i=1;i<=NF;i++){if($i ~ /^[0-9]/){print $i; break}}}')
            if [ -n "$installed_version" ]; then
                echo ">>> $candidate $installed_version은(는) 이미 설치되어 있습니다."
                return 0
            fi
        fi
    fi
    
    # 설치 시도
    echo ">>> $package_name 설치 중..."
    local install_output
    install_output=$($install_cmd < /dev/null 2>&1)
    local install_status=$?
    
    # 설치 출력 분석
    local output_lower=$(echo "$install_output" | tr '[:upper:]' '[:lower:]')
    
    # 이미 설치된 경우 확인 (여러 패턴 체크)
    if echo "$output_lower" | grep -qiE "already installed|이미 설치|is already installed|already have|found in"; then
        echo ">>> $package_name은(는) 이미 설치되어 있습니다."
        return 0
    fi
    
    # 설치 실패 확인
    if echo "$output_lower" | grep -qiE "not available|invalid version|not found|failed|error|실패"; then
        echo ">>> $package_name 설치에 실패했습니다."
        return 1
    fi
    
    # 설치 성공 확인
    if [ $install_status -eq 0 ]; then
        # 설치 후 다시 확인하여 실제로 설치되었는지 검증
        if [ -n "$version" ]; then
            # 잠시 대기 후 목록 갱신
            sleep 0.5
            local verify_list=$(sdk list $candidate 2>/dev/null)
            local verify_line=$(echo "$verify_list" | grep -E "^\s*[>|\*]\s+${version}\s+\|" | head -1)
            local verify_only=$(echo "$verify_list" | grep -E "^\s+${version}\s+\|\s+(installed|local only)" | head -1)
            
            if [ -n "$verify_line" ] || [ -n "$verify_only" ]; then
                # 새로 설치된 경우
                echo ">>> $package_name 설치 완료."
                return 0
            else
                # 설치 시도했지만 목록에 없음 - 이미 있었을 가능성
                echo ">>> $package_name은(는) 이미 설치되어 있습니다."
                return 0
            fi
        else
            echo ">>> $package_name 설치 완료."
            return 0
        fi
    else
        # exit code가 0이 아니지만, 이미 설치된 경우일 수 있음
        if echo "$output_lower" | grep -qiE "already|이미"; then
            echo ">>> $package_name은(는) 이미 설치되어 있습니다."
            return 0
        else
            echo ">>> $package_name 설치에 실패했습니다."
            return 1
        fi
    fi
}

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
install_sdk_package "java" "11-tem"
install_sdk_package "java" "17-tem"
install_sdk_package "java" "21-tem"
install_sdk_package "java" "25-tem"

# JDK 25를 default로 설정
echo ">>> JDK 25-tem을 default로 설정합니다."
if sdk default java 25-tem 2>/dev/null; then
    echo ">>> JDK 25-tem default 설정 완료."
else
    echo ">>> JDK 25-tem default 설정에 실패했습니다."
fi

# Maven 설치
echo ">>> Maven 버전 확인 중..."
MAVEN_LIST=$(sdk list maven 2>/dev/null)

# Maven 2.x 최신 버전 찾기
MAVEN_2_VERSION=$(echo "$MAVEN_LIST" | grep -E "^\s*2\.[0-9]" | head -1 | awk '{print $NF}' | tr -d '|' | xargs)
if [ -n "$MAVEN_2_VERSION" ]; then
    install_sdk_package "maven" "$MAVEN_2_VERSION"
else
    echo ">>> Maven 2.x 버전을 찾을 수 없습니다."
fi

# Maven 3.x 최신 버전 찾기
MAVEN_3_VERSION=$(echo "$MAVEN_LIST" | grep -E "^\s*3\.[0-9]" | head -1 | awk '{print $NF}' | tr -d '|' | xargs)
if [ -n "$MAVEN_3_VERSION" ]; then
    install_sdk_package "maven" "$MAVEN_3_VERSION"
    # Maven 3를 default로 설정
    echo ">>> Maven $MAVEN_3_VERSION을 default로 설정합니다."
    if sdk default maven $MAVEN_3_VERSION 2>/dev/null; then
        echo ">>> Maven $MAVEN_3_VERSION default 설정 완료."
    else
        echo ">>> Maven default 설정에 실패했습니다."
    fi
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
            install_sdk_package "gradle" "$SECOND_LATEST_VERSION"
        fi
    fi
    
    if [ -n "$LATEST_VERSION" ]; then
        install_sdk_package "gradle" "$LATEST_VERSION"
        # 가장 최신 Gradle을 default로 설정
        echo ">>> Gradle $LATEST_VERSION을 default로 설정합니다."
        if sdk default gradle $LATEST_VERSION 2>/dev/null; then
            echo ">>> Gradle $LATEST_VERSION default 설정 완료."
        else
            echo ">>> Gradle default 설정에 실패했습니다."
        fi
    fi
else
    echo ">>> Gradle 버전을 찾을 수 없습니다. 최신 버전을 설치합니다."
    if install_sdk_package "gradle" ""; then
        INSTALLED_GRADLE=$(sdk list gradle 2>/dev/null | grep "installed" | head -1 | awk '{print $NF}' | tr -d '|' | xargs)
        if [ -n "$INSTALLED_GRADLE" ]; then
            echo ">>> Gradle $INSTALLED_GRADLE을 default로 설정합니다."
            if sdk default gradle $INSTALLED_GRADLE 2>/dev/null; then
                echo ">>> Gradle $INSTALLED_GRADLE default 설정 완료."
            else
                echo ">>> Gradle default 설정에 실패했습니다."
            fi
        fi
    fi
fi

echo ">>> JDK/Maven/Gradle 설치가 완료되었습니다."

#!/bin/bash

# 범용 MSA 멀티모듈 프로젝트 자동 생성기
# 사용법: ./setup-msa-project.sh [프로젝트명]

set -e  # 에러 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 전역 변수 선언 (중요!)
declare -a SERVICES
declare -a PORTS
declare PROJECT_NAME
declare GROUP_ID
declare PACKAGE_PATH
declare SERVICE_COUNT
declare INCLUDE_GATEWAY
declare GATEWAY_PORT
declare PROJECT_DIR

# 유틸리티 함수들
print_header() {
    echo -e "${CYAN}===========================================${NC}"
    echo -e "${CYAN}🚀 범용 MSA 프로젝트 생성기${NC}"
    echo -e "${CYAN}===========================================${NC}"
}

print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_debug() {
    echo -e "${PURPLE}🔍 DEBUG: $1${NC}"
}

# 프로젝트 기본 정보 입력
get_project_info() {
    print_header
    
    # 프로젝트명 입력
    if [ -z "$1" ]; then
        read -p "📝 프로젝트명을 입력하세요 (기본: my-msa-project): " PROJECT_NAME
        PROJECT_NAME=${PROJECT_NAME:-"my-msa-project"}
    else
        PROJECT_NAME="$1"
    fi
    
    # 그룹 ID 입력
    read -p "📦 그룹 ID를 입력하세요 (기본: com.example): " GROUP_ID
    GROUP_ID=${GROUP_ID:-"com.example"}
    
    # 패키지 경로 생성 (com.example -> com/example)
    PACKAGE_PATH=$(echo "$GROUP_ID" | tr '.' '/')
    
    echo
    print_success "프로젝트명: $PROJECT_NAME"
    print_success "그룹 ID: $GROUP_ID"
    print_success "패키지 경로: $PACKAGE_PATH"
    echo
}

# 마이크로서비스 정보 입력
get_microservices_info() {
    print_step "마이크로서비스 설정"
    
    # 마이크로서비스 개수 입력
    while true; do
        read -p "🎯 생성할 마이크로서비스 개수를 입력하세요 (1-10): " SERVICE_COUNT
        if [[ "$SERVICE_COUNT" =~ ^[1-9]$|^10$ ]]; then
            break
        else
            print_error "1-10 사이의 숫자를 입력해주세요."
        fi
    done
    
    # 배열 초기화
    SERVICES=()
    PORTS=()
    BASE_PORT=8081
    
    # 각 마이크로서비스명 입력
    echo
    print_step "마이크로서비스명 입력 (예: user, product, order, payment 등)"
    
    for ((i=1; i<=SERVICE_COUNT; i++)); do
        while true; do
            read -p "🔧 ${i}번째 서비스명을 입력하세요: " service_name
            
            # 서비스명 유효성 검사
            if [[ "$service_name" =~ ^[a-z][a-z0-9-]*[a-z0-9]$|^[a-z]$ ]]; then
                # 중복 검사
                if [[ " ${SERVICES[@]} " =~ " ${service_name} " ]]; then
                    print_error "이미 존재하는 서비스명입니다. 다른 이름을 입력해주세요."
                else
                    SERVICES+=("$service_name")
                    PORTS+=($((BASE_PORT + i - 1)))
                    print_success "${service_name}-service (포트: $((BASE_PORT + i - 1)))"
                    break
                fi
            else
                print_error "서비스명은 소문자, 숫자, 하이픈만 사용 가능합니다. (예: user, user-management)"
            fi
        done
    done
    
    # 디버그: 배열 내용 확인
    print_debug "입력된 서비스 개수: ${#SERVICES[@]}"
    print_debug "서비스 목록: ${SERVICES[*]}"
    print_debug "포트 목록: ${PORTS[*]}"
    
    # API Gateway 포함 여부
    echo
    read -p "🌐 API Gateway를 포함하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INCLUDE_GATEWAY=true
        GATEWAY_PORT=8080
        print_success "API Gateway 포함 (포트: $GATEWAY_PORT)"
    else
        INCLUDE_GATEWAY=false
    fi
    
    echo
    print_step "생성될 서비스 목록:"
    if [ "$INCLUDE_GATEWAY" = true ]; then
        echo -e "${PURPLE}  - api-gateway (포트: $GATEWAY_PORT)${NC}"
    fi
    for ((i=0; i<${#SERVICES[@]}; i++)); do
        echo -e "${PURPLE}  - ${SERVICES[i]}-service (포트: ${PORTS[i]})${NC}"
    done
    echo
}

# 프로젝트 디렉토리 설정
setup_project_directory() {
    CURRENT_DIR=$(pwd)
    PROJECT_DIR="$CURRENT_DIR/$PROJECT_NAME"
    
    print_step "프로젝트 디렉토리 설정: $PROJECT_DIR"
    
    if [ -d "$PROJECT_DIR" ]; then
        print_warning "프로젝트 디렉토리가 이미 존재합니다: $PROJECT_DIR"
        read -p "덮어쓰시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$PROJECT_DIR"
            print_success "기존 디렉토리 삭제 완료"
        else
            print_error "스크립트를 종료합니다."
            exit 1
        fi
    fi
    
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"
    print_success "프로젝트 디렉토리 생성 완료"
}

# 패키지명 변환 함수 개선
convert_to_package_name() {
    local service_name="$1"
    # 하이픈을 제거하고 camelCase로 변환
    echo "$service_name" | sed 's/-\([a-z]\)/\U\1/g' | tr '[:upper:]' '[:lower:]'
}

# 클래스명 변환 함수
convert_to_class_name() {
    local service_name="$1"
    # 하이픈을 제거하고 PascalCase로 변환
    echo "$service_name" | sed 's/-\([a-z]\)/\U\1/g; s/^./\U&/'
}

# 디렉토리 구조 생성
create_directory_structure() {
    print_step "디렉토리 구조 생성 중..."
    
    # 디버그: 현재 작업 디렉토리와 변수 확인
    print_debug "현재 작업 디렉토리: $(pwd)"
    print_debug "PACKAGE_PATH: $PACKAGE_PATH"
    print_debug "SERVICES 배열 크기: ${#SERVICES[@]}"
    print_debug "SERVICES 내용: ${SERVICES[*]}"
    
    # 공통 라이브러리 디렉토리
    print_debug "공통 라이브러리 디렉토리 생성 중..."
    mkdir -p libs/common-models/src/main/java/$PACKAGE_PATH/common/models
    mkdir -p libs/saga-framework/src/main/java/$PACKAGE_PATH/saga
    
    # 각 마이크로서비스 디렉토리 생성
    if [ ${#SERVICES[@]} -eq 0 ]; then
        print_error "SERVICES 배열이 비어있습니다!"
        return 1
    fi
    
    for service in "${SERVICES[@]}"; do
        print_debug "서비스 '$service' 디렉토리 생성 중..."
        
        # 패키지명 변환
        service_package=$(convert_to_package_name "$service")
        print_debug "변환된 패키지명: $service_package"
        
        # 디렉토리 경로 구성
        service_dir="services/${service}-service"
        java_dir="$service_dir/src/main/java/$PACKAGE_PATH/$service_package"
        resources_dir="$service_dir/src/main/resources"
        
        print_debug "생성할 디렉토리들:"
        print_debug "  - $java_dir"
        print_debug "  - $resources_dir"
        
        # 디렉토리 생성
        mkdir -p "$java_dir"
        mkdir -p "$resources_dir"
        
        # 생성 확인
        if [ -d "$java_dir" ] && [ -d "$resources_dir" ]; then
            print_success "${service}-service 디렉토리 생성 완료"
        else
            print_error "${service}-service 디렉토리 생성 실패"
        fi
    done
    
    # API Gateway 디렉토리 (선택된 경우)
    if [ "$INCLUDE_GATEWAY" = true ]; then
        print_debug "API Gateway 디렉토리 생성 중..."
        mkdir -p services/api-gateway/src/main/java/$PACKAGE_PATH/gateway
        mkdir -p services/api-gateway/src/main/resources
        print_success "API Gateway 디렉토리 생성 완료"
    fi
    
    print_success "디렉토리 구조 생성 완료"
    
    # 최종 확인을 위한 트리 구조 표시
    print_debug "생성된 디렉토리 구조:"
    if command -v tree &> /dev/null; then
        tree -d . | head -20
    else
        find . -type d | head -20 | sort
    fi
}

# Gradle 설정 파일 생성
create_gradle_files() {
    print_step "Gradle 설정 파일 생성 중..."
    
    # settings.gradle 생성
    cat > settings.gradle << EOF
rootProject.name = '$PROJECT_NAME'

// 공통 라이브러리
include 'libs:common-models'
include 'libs:saga-framework'

// 마이크로서비스들
EOF
    
    for service in "${SERVICES[@]}"; do
        echo "include 'services:${service}-service'" >> settings.gradle
    done
    
    if [ "$INCLUDE_GATEWAY" = true ]; then
        echo "include 'services:api-gateway'" >> settings.gradle
    fi
    
    # 루트 build.gradle 생성
    cat > build.gradle << 'EOF'
plugins {
    id 'java'
    id 'org.springframework.boot' version '3.3.4' apply false
    id 'io.spring.dependency-management' version '1.1.6' apply false
}

allprojects {
    group = 'GROUP_ID_PLACEHOLDER'
    version = '1.0.0'
    repositories {
        mavenCentral()
    }
}

subprojects {
    apply plugin: 'java'
    
    java {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }
    
    dependencies {
        implementation 'org.slf4j:slf4j-api:2.0.13'
        testImplementation 'org.junit.jupiter:junit-jupiter:5.10.3'
        testRuntimeOnly 'org.junit.platform:junit-platform-launcher'
    }
    
    tasks.named('test') {
        useJUnitPlatform()
        jvmArgs += ['--enable-preview']
    }
    
    tasks.withType(JavaCompile) {
        options.encoding = 'UTF-8'
        options.release = 21
        options.compilerArgs += ['--enable-preview']
    }
}

configure(subprojects.findAll { it.path.startsWith(':libs') }) {
    apply plugin: 'java-library'
}

wrapper {
    gradleVersion = '8.8'
    distributionType = Wrapper.DistributionType.BIN
}

task projectInfo {
    doLast {
        println "=== PROJECT_NAME_PLACEHOLDER ==="
        println "Root project: ${rootProject.name}"
        println "Version: ${version}"
        println "Java version: 21"
        println "Spring Boot: 3.3.4"
        println "Gradle: 8.8"
        println ""
        println "Subprojects:"
        subprojects.each { project ->
            println "  - ${project.name} (${project.path})"
        }
    }
}
EOF

    # 플레이스홀더 교체 (macOS 호환성 개선)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/GROUP_ID_PLACEHOLDER/$GROUP_ID/g" build.gradle
        sed -i '' "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" build.gradle
    else
        sed -i "s/GROUP_ID_PLACEHOLDER/$GROUP_ID/g" build.gradle
        sed -i "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" build.gradle
    fi
    
    # gradle.properties 생성
    cat > gradle.properties << EOF
# Gradle 성능 최적화 설정
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configuration-cache=true
org.gradle.build-cache=true

# JVM 설정 (Java 21 최적화)
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=512m --add-opens java.base/java.util=ALL-UNNAMED

# 프로젝트 정보
group=$GROUP_ID
version=1.0.0

# Java 21 관련 설정
spring.threads.virtual.enabled=true
java.preview.enabled=true

# 인코딩 설정
file.encoding=UTF-8
java.compile.encoding=UTF-8
EOF

    print_success "Gradle 설정 파일 생성 완료"
}

# 공통 라이브러리 build.gradle 생성
create_common_libraries() {
    print_step "공통 라이브러리 파일 생성 중..."
    
    # common-models build.gradle
    cat > libs/common-models/build.gradle << 'EOF'
plugins {
    id 'java-library'
    id 'io.spring.dependency-management'
}

description = '공통 도메인 모델 및 DTO 클래스'

dependencyManagement {
    imports {
        mavenBom 'org.springframework.boot:spring-boot-dependencies:3.3.4'
    }
}

dependencies {
    api 'com.fasterxml.jackson.core:jackson-annotations'
    api 'com.fasterxml.jackson.core:jackson-databind'
    api 'com.fasterxml.jackson.datatype:jackson-datatype-jsr310'
    api 'jakarta.validation:jakarta.validation-api'
    api 'org.apache.commons:commons-lang3:3.15.0'
}
EOF

    # saga-framework build.gradle
    cat > libs/saga-framework/build.gradle << 'EOF'
plugins {
    id 'java-library'
    id 'io.spring.dependency-management'
}

description = 'Saga 패턴 구현을 위한 프레임워크'

dependencyManagement {
    imports {
        mavenBom 'org.springframework.boot:spring-boot-dependencies:3.3.4'
    }
}

dependencies {
    api project(':libs:common-models')
    api 'org.springframework:spring-context'
    api 'org.springframework:spring-tx'
    api 'com.fasterxml.jackson.core:jackson-databind'
    api 'com.fasterxml.jackson.datatype:jackson-datatype-jsr310'
    api 'org.springframework:spring-web'
    
    testImplementation 'org.springframework:spring-test'
    testImplementation 'org.mockito:mockito-core'
}
EOF

    print_success "공통 라이브러리 파일 생성 완료"
}

# 마이크로서비스 build.gradle 생성
create_microservice_build_files() {
    print_step "마이크로서비스 build.gradle 파일 생성 중..."
    
    for service in "${SERVICES[@]}"; do
        print_debug "${service}-service build.gradle 생성 중..."
        cat > services/${service}-service/build.gradle << EOF
plugins {
    id 'java'
    id 'org.springframework.boot'
    id 'io.spring.dependency-management'
}

description = '${service} 마이크로서비스'

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    
    runtimeOnly 'com.h2database:h2'
    
    developmentOnly 'org.springframework.boot:spring-boot-devtools'
    annotationProcessor 'org.springframework.boot:spring-boot-configuration-processor'
    
    implementation project(':libs:common-models')
    implementation project(':libs:saga-framework')
    
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

tasks.named('bootRun') {
    jvmArgs += ['--enable-preview']
}
EOF
    done
    
    # API Gateway build.gradle (선택된 경우)
    if [ "$INCLUDE_GATEWAY" = true ]; then
        cat > services/api-gateway/build.gradle << 'EOF'
plugins {
    id 'java'
    id 'org.springframework.boot'
    id 'io.spring.dependency-management'
}

description = 'API Gateway 서비스'

dependencyManagement {
    imports {
        mavenBom 'org.springframework.cloud:spring-cloud-dependencies:2023.0.3'
    }
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-webflux'
    implementation 'org.springframework.boot:spring-boot-starter-actuator'
    implementation 'org.springframework.cloud:spring-cloud-starter-gateway'
    
    developmentOnly 'org.springframework.boot:spring-boot-devtools'
    annotationProcessor 'org.springframework.boot:spring-boot-configuration-processor'
    
    implementation project(':libs:common-models')
    
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

tasks.named('bootRun') {
    jvmArgs += ['--enable-preview']
}
EOF
    fi
    
    print_success "마이크로서비스 build.gradle 파일 생성 완료"
}

# Spring Boot 메인 클래스 생성
create_main_classes() {
    print_step "Spring Boot 메인 클래스 생성 중..."
    
    for ((i=0; i<${#SERVICES[@]}; i++)); do
        service=${SERVICES[i]}
        service_package=$(convert_to_package_name "$service")
        class_name=$(convert_to_class_name "$service")
        
        print_debug "${service} 서비스 메인 클래스 생성 중..."
        print_debug "  - 패키지: $service_package"
        print_debug "  - 클래스명: ${class_name}ServiceApplication"
        
        cat > services/${service}-service/src/main/java/$PACKAGE_PATH/$service_package/${class_name}ServiceApplication.java << EOF
package $GROUP_ID.$service_package;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ${class_name}ServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(${class_name}ServiceApplication.class, args);
    }
}
EOF
        print_success "${service}-service 메인 클래스 생성 완료"
    done
    
    # API Gateway 메인 클래스 (선택된 경우)
    if [ "$INCLUDE_GATEWAY" = true ]; then
        cat > services/api-gateway/src/main/java/$PACKAGE_PATH/gateway/ApiGatewayApplication.java << EOF
package $GROUP_ID.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class ApiGatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }
}
EOF
        print_success "API Gateway 메인 클래스 생성 완료"
    fi
    
    print_success "Spring Boot 메인 클래스 생성 완료"
}

# application.yml 파일 생성
create_application_configs() {
    print_step "application.yml 파일 생성 중..."
    
    for ((i=0; i<${#SERVICES[@]}; i++)); do
        service=${SERVICES[i]}
        port=${PORTS[i]}
        service_package=$(convert_to_package_name "$service")
        
        print_debug "${service}-service application.yml 생성 중..."
        
        cat > services/${service}-service/src/main/resources/application.yml << EOF
server:
  port: $port

spring:
  application:
    name: ${service}-service
  threads:
    virtual:
      enabled: true
  datasource:
    url: jdbc:h2:mem:${service}db
    driver-class-name: org.h2.Driver
    username: sa
    password: ''
  h2:
    console:
      enabled: true
      path: /h2-console
      settings:
        web-allow-others: true
  jpa:
    hibernate:
      ddl-auto: create-drop
    show-sql: true
    properties:
      hibernate:
        format_sql: true
        dialect: org.hibernate.dialect.H2Dialect

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,threaddump
  endpoint:
    health:
      show-details: always

logging:
  level:
    $GROUP_ID.$service_package: DEBUG
    org.springframework.web: INFO
    org.hibernate.SQL: DEBUG
EOF
    done
    
    # API Gateway application.yml (선택된 경우)
    if [ "$INCLUDE_GATEWAY" = true ]; then
        cat > services/api-gateway/src/main/resources/application.yml << EOF
server:
  port: $GATEWAY_PORT

spring:
  application:
    name: api-gateway
  threads:
    virtual:
      enabled: true
  cloud:
    gateway:
      routes:
EOF
        
        # 각 서비스에 대한 라우팅 규칙 추가
        for ((i=0; i<${#SERVICES[@]}; i++)); do
            service=${SERVICES[i]}
            port=${PORTS[i]}
            cat >> services/api-gateway/src/main/resources/application.yml << EOF
        - id: ${service}-service
          uri: http://localhost:$port
          predicates:
            - Path=/api/$service/**
          filters:
            - StripPrefix=0
EOF
        done
        
        cat >> services/api-gateway/src/main/resources/application.yml << EOF
      globalcors:
        corsConfigurations:
          '[/**]':
            allowedOrigins: "*"
            allowedMethods:
              - GET
              - POST
              - PUT
              - DELETE
              - OPTIONS
            allowedHeaders: "*"

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,gateway
  endpoint:
    health:
      show-details: always

logging:
  level:
    $GROUP_ID.gateway: DEBUG
    org.springframework.cloud.gateway: DEBUG
    org.springframework.web: INFO
EOF
    fi
    
    print_success "application.yml 파일 생성 완료"
}

# 유용한 스크립트 파일 생성
create_utility_scripts() {
    print_step "유틸리티 스크립트 생성 중..."
    
    # 빌드 스크립트
    cat > build-all.sh << 'EOF'
#!/bin/bash
echo "🔨 전체 프로젝트 빌드 시작..."
./gradlew clean build
echo "✅ 빌드 완료!"
EOF
    
    # 모든 서비스 실행 스크립트
    cat > run-all-services.sh << 'EOF'
#!/bin/bash
echo "🚀 모든 서비스 실행 중..."

# 로그 및 PID 디렉토리 생성
mkdir -p logs pids

EOF
    
    # API Gateway 실행 (포함된 경우)
    if [ "$INCLUDE_GATEWAY" = true ]; then
        cat >> run-all-services.sh << EOF
echo "Starting API Gateway (port $GATEWAY_PORT)..."
./gradlew :services:api-gateway:bootRun > logs/api-gateway.log 2>&1 &
GATEWAY_PID=\$!
echo \$GATEWAY_PID > pids/api-gateway.pid

EOF
    fi
    
    # 각 서비스 실행 명령어 추가
    for ((i=0; i<${#SERVICES[@]}; i++)); do
        service=${SERVICES[i]}
        port=${PORTS[i]}
        service_var_name=$(echo "${service^^}" | tr '-' '_')
        cat >> run-all-services.sh << EOF
echo "Starting ${service} Service (port $port)..."
./gradlew :services:${service}-service:bootRun > logs/${service}-service.log 2>&1 &
${service_var_name}_PID=\$!
echo \$${service_var_name}_PID > pids/${service}-service.pid

EOF
    done
    
    cat >> run-all-services.sh << 'EOF'
echo "✅ 모든 서비스가 백그라운드에서 실행 중입니다!"
echo "📊 Health Check URLs:"
EOF
    
    # Health Check URL 추가
    if [ "$INCLUDE_GATEWAY" = true ]; then
        echo "echo \"  - API Gateway: http://localhost:$GATEWAY_PORT/actuator/health\"" >> run-all-services.sh
    fi
    
    for ((i=0; i<${#SERVICES[@]}; i++)); do
        service=${SERVICES[i]}
        port=${PORTS[i]}
        service_display=$(convert_to_class_name "$service")
        echo "echo \"  - $service_display Service: http://localhost:$port/actuator/health\"" >> run-all-services.sh
    done
    
    cat >> run-all-services.sh << 'EOF'
echo ""
echo "🛑 서비스 중지: ./stop-all-services.sh"
EOF
    
    # 모든 서비스 중지 스크립트
    cat > stop-all-services.sh << 'EOF'
#!/bin/bash
echo "🛑 모든 서비스 중지 중..."

if [ -d "pids" ]; then
    for pidfile in pids/*.pid; do
        if [ -f "$pidfile" ]; then
            pid=$(cat "$pidfile")
            if kill -0 "$pid" 2>/dev/null; then
                echo "Stopping process $pid..."
                kill "$pid"
            fi
            rm "$pidfile"
        fi
    done
    rmdir pids 2>/dev/null
fi

echo "✅ 모든 서비스가 중지되었습니다."
EOF
    
    # 서비스 상태 확인 스크립트
    cat > check-services.sh << 'EOF'
#!/bin/bash
echo "🔍 서비스 상태 확인 중..."

services=(
EOF
    
    if [ "$INCLUDE_GATEWAY" = true ]; then
        echo "    \"$GATEWAY_PORT:API-Gateway\"" >> check-services.sh
    fi
    
    for ((i=0; i<${#SERVICES[@]}; i++)); do
        service=${SERVICES[i]}
        port=${PORTS[i]}
        service_display=$(convert_to_class_name "$service")
        echo "    \"$port:$service_display\"" >> check-services.sh
    done
    
    cat >> check-services.sh << 'EOF'
)

for service in "${services[@]}"; do
    port="${service%%:*}"
    name="${service##*:}"
    
    if curl -s "http://localhost:$port/actuator/health" >/dev/null 2>&1; then
        echo "✅ $name Service ($port) - 정상"
    else
        echo "❌ $name Service ($port) - 중단됨"
    fi
done
EOF
    
    # 실행 권한 부여
    chmod +x build-all.sh run-all-services.sh stop-all-services.sh check-services.sh
    
    # 로그 및 PID 디렉토리 생성
    mkdir -p logs pids
    
    print_success "유틸리티 스크립트 생성 완료"
}

# README.md 생성
create_readme() {
    print_step "README.md 파일 생성 중..."
    
    cat > README.md << EOF
# $PROJECT_NAME

🚀 MSA (Microservices Architecture) 프로젝트

## 🏗️ 아키텍처

\`\`\`
📱 클라이언트 애플리케이션
    ↓
EOF
    
    if [ "$INCLUDE_GATEWAY" = true ]; then
        cat >> README.md << EOF
🌐 API Gateway ($GATEWAY_PORT)
    ↓
EOF
    fi
    
    echo "┌$(printf '─%.0s' {1..15})" >> README.md
    for ((i=1; i<${#SERVICES[@]}; i++)); do
        echo -n "┬$(printf '─%.0s' {1..15})" >> README.md
    done
    echo "┐" >> README.md
    
    # 서비스 박스 그리기
    for ((i=0; i<${#SERVICES[@]}; i++)); do
        service=${SERVICES[i]}
        port=${PORTS[i]}
        service_upper=$(echo "${service^^}" | tr '-' ' ')
        if [ $i -eq 0 ]; then
            printf "│  %-13s" "$service_upper ($port)" >> README.md
        else
            printf "│  %-13s" "$service_upper ($port)" >> README.md
        fi
    done
    echo "│" >> README.md
    
    echo "└$(printf '─%.0s' {1..15})" >> README.md
    for ((i=1; i<${#SERVICES[@]}; i++)); do
        echo -n "┴$(printf '─%.0s' {1..15})" >> README.md
    done
    echo "┘" >> README.md
    
    cat >> README.md << 'EOF'
```

## 🚀 빠른 시작

### 전체 빌드
```bash
./build-all.sh
```

### 모든 서비스 실행
```bash
./run-all-services.sh
```

### 모든 서비스 중지
```bash
./stop-all-services.sh
```

### 서비스 상태 확인
```bash
./check-services.sh
```

### 개별 서비스 실행
```bash
EOF
    
    for service in "${SERVICES[@]}"; do
        echo "# ${service} Service" >> README.md
        echo "./gradlew :services:${service}-service:bootRun" >> README.md
        echo "" >> README.md
    done
    
    if [ "$INCLUDE_GATEWAY" = true ]; then
        echo "# API Gateway" >> README.md
        echo "./gradlew :services:api-gateway:bootRun" >> README.md
        echo '```' >> README.md
    else
        echo '```' >> README.md
    fi
    
    cat >> README.md << 'EOF'

## 🌐 접속 정보

### Health Check URLs
EOF
    
    if [ "$INCLUDE_GATEWAY" = true ]; then
        echo "- API Gateway: http://localhost:$GATEWAY_PORT/actuator/health" >> README.md
    fi
    
    for ((i=0; i<${#SERVICES[@]}; i++)); do
        service=${SERVICES[i]}
        port=${PORTS[i]}
        service_display=$(convert_to_class_name "$service")
        echo "- $service_display Service: http://localhost:$port/actuator/health" >> README.md
    done
    
    cat >> README.md << 'EOF'

### H2 Database Console
EOF
    
    for ((i=0; i<${#SERVICES[@]}; i++)); do
        service=${SERVICES[i]}
        port=${PORTS[i]}
        service_display=$(convert_to_class_name "$service")
        echo "- $service_display DB: http://localhost:$port/h2-console (DB: ${service}db)" >> README.md
    done
    
    if [ "$INCLUDE_GATEWAY" = true ]; then
        cat >> README.md << 'EOF'

### API Gateway Routes
EOF
        
        for service in "${SERVICES[@]}"; do
            service_display=$(convert_to_class_name "$service")
            echo "- $service_display API: http://localhost:$GATEWAY_PORT/api/$service/*" >> README.md
        done
    fi
    
    cat >> README.md << EOF

## 🛠️ 기술 스택

- **Java**: 21 LTS (Virtual Threads)
- **Spring Boot**: 3.3.4
- **Gradle**: 8.8
- **Database**: H2 (In-Memory)
- **Architecture**: Microservices + Saga Pattern

## 📁 프로젝트 구조

\`\`\`
$PROJECT_NAME/
├── libs/                           # 공통 라이브러리
│   ├── common-models/             # 공통 도메인 모델
│   └── saga-framework/            # Saga 패턴 프레임워크
├── services/                      # 마이크로서비스들
EOF
    
    for service in "${SERVICES[@]}"; do
        service_display=$(convert_to_class_name "$service")
        echo "│   ├── ${service}-service/           # ${service_display} 마이크로서비스" >> README.md
    done
    
    if [ "$INCLUDE_GATEWAY" = true ]; then
        echo "│   └── api-gateway/               # API Gateway" >> README.md
    fi
    
    cat >> README.md << 'EOF'
├── build-all.sh                   # 전체 빌드 스크립트
├── run-all-services.sh            # 모든 서비스 실행
├── stop-all-services.sh           # 모든 서비스 중지
├── check-services.sh              # 서비스 상태 확인
└── README.md                      # 이 파일
```

## 🎯 개발 가이드

### 새로운 API 추가
각 서비스에 Controller, Service, Repository를 추가하여 API를 개발하세요.

### 서비스 간 통신
- **동기 통신**: WebClient 또는 OpenFeign 사용
- **비동기 통신**: 메시지 큐 (RabbitMQ, Kafka) 사용 권장

### 데이터베이스 변경
H2 대신 PostgreSQL, MySQL 등을 사용하려면 각 서비스의 `application.yml`과 `build.gradle`을 수정하세요.

### 모니터링
각 서비스에 Spring Boot Actuator가 포함되어 있어 기본적인 모니터링이 가능합니다.

## 🔧 트러블슈팅

### 포트 충돌
다른 애플리케이션이 사용 중인 포트가 있다면 `application.yml`에서 포트를 변경하세요.

### 메모리 부족
Java 21과 Virtual Threads를 사용하므로 충분한 메모리를 할당해주세요.

### 빌드 실패
Java 21과 Gradle 8.8이 설치되어 있는지 확인하세요.

## 📝 라이선스

이 프로젝트는 학습 목적으로 생성되었습니다.
EOF
    
    print_success "README.md 파일 생성 완료"
}

# Gradle wrapper 생성
create_gradle_wrapper() {
    print_step "Gradle wrapper 생성 중..."
    
    if command -v gradle &> /dev/null; then
        gradle wrapper --gradle-version 8.8
        print_success "Gradle wrapper 생성 완료"
    else
        print_warning "Gradle이 설치되지 않았습니다. gradlew 파일을 수동으로 생성합니다."
        # 기본 gradlew 파일들 다운로드
        curl -L https://services.gradle.org/distributions/gradle-8.8-bin.zip -o gradle-8.8-bin.zip
        unzip -q gradle-8.8-bin.zip
        rm gradle-8.8-bin.zip
        mv gradle-8.8 gradle
        gradle/bin/gradle wrapper --gradle-version 8.8
        rm -rf gradle
        print_success "Gradle wrapper 수동 생성 완료"
    fi
}

# 최종 정보 출력
print_final_info() {
    echo
    echo -e "${GREEN}🎉 MSA 프로젝트 생성 완료!${NC}"
    echo -e "${CYAN}===========================================${NC}"
    echo -e "${BLUE}📁 프로젝트 위치: $PROJECT_DIR${NC}"
    echo
    echo -e "${PURPLE}🚀 다음 단계:${NC}"
    echo -e "  ${YELLOW}1.${NC} cd $PROJECT_NAME"
    echo -e "  ${YELLOW}2.${NC} ./build-all.sh          # 전체 빌드"
    echo -e "  ${YELLOW}3.${NC} ./run-all-services.sh   # 모든 서비스 실행"
    echo -e "  ${YELLOW}4.${NC} ./check-services.sh     # 서비스 상태 확인"
    echo
    echo -e "${PURPLE}🌐 생성된 서비스:${NC}"
    
    if [ "$INCLUDE_GATEWAY" = true ]; then
        echo -e "  ${GREEN}✅${NC} API Gateway: http://localhost:$GATEWAY_PORT"
    fi
    
    for ((i=0; i<${#SERVICES[@]}; i++)); do
        service=${SERVICES[i]}
        port=${PORTS[i]}
        service_display=$(convert_to_class_name "$service")
        echo -e "  ${GREEN}✅${NC} $service_display Service: http://localhost:$port"
    done
    
    echo
    echo -e "${PURPLE}📖 더 자세한 정보는 README.md 파일을 확인하세요!${NC}"
    echo -e "${CYAN}===========================================${NC}"
}

# 메인 실행 함수
main() {
    # 함수들을 순서대로 실행
    get_project_info "$1"
    get_microservices_info
    setup_project_directory
    create_directory_structure
    
    # 중간 확인
    if [ ${#SERVICES[@]} -eq 0 ]; then
        print_error "서비스 목록이 비어있습니다. 스크립트를 재실행해주세요."
        exit 1
    fi
    
    create_gradle_files
    create_common_libraries
    create_microservice_build_files
    create_main_classes
    create_application_configs
    create_utility_scripts
    create_readme
    create_gradle_wrapper
    print_final_info
}

# 스크립트 실행
main "$@"
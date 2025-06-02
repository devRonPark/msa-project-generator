# 🚀 MSA Project Generator

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Java](https://img.shields.io/badge/Java-21-orange.svg)](https://www.oracle.com/java/technologies/javase/jdk21-archive-downloads.html)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.4-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Gradle](https://img.shields.io/badge/Gradle-8.8-blue.svg)](https://gradle.org/)

**30초 만에 완전한 MSA(Microservices Architecture) 프로젝트를 생성하는 범용 코드 생성기**

더 이상 지루한 보일러플레이트 코드 작성에 시간을 낭비하지 마세요! 
이 스크립트 하나로 **Java 21 + Spring Boot 3.3.4 + Gradle 8.8** 기반의 완전한 MSA 프로젝트를 생성할 수 있습니다.

## ✨ 주요 기능

### 🎯 **완전 대화형 설정**
- 📝 프로젝트명 커스터마이징
- 📦 그룹 ID 설정 (com.yourcompany)
- 🔢 마이크로서비스 개수 선택 (1-10개)
- 🏷️ 각 서비스명 개별 입력
- 🌐 API Gateway 포함 여부 선택

### 🏗️ **자동 생성되는 완전한 프로젝트**
- ✅ **60+ 파일/폴더** 자동 생성
- ✅ **Gradle 멀티모듈** 구조
- ✅ **Spring Boot 메인 클래스** (각 서비스별)
- ✅ **완전한 설정 파일들** (application.yml, build.gradle)
- ✅ **API Gateway 라우팅** 자동 설정
- ✅ **개발 편의 스크립트** (빌드, 실행, 중지, 상태확인)

### 🔧 **최신 기술 스택**
- **Java 21 LTS** (Virtual Threads 지원)
- **Spring Boot 3.3.4** (최신 안정 버전)
- **Gradle 8.8** (최고 성능)
- **H2 Database** (즉시 사용 가능)
- **Spring Boot Actuator** (모니터링)
- **Saga Pattern Framework** (분산 트랜잭션)

## 🚀 빠른 시작

### 1. 스크립트 다운로드
```bash
# Git 클론
git clone https://github.com/username/msa-project-generator.git
cd msa-project-generator

# 또는 직접 다운로드
curl -O https://raw.githubusercontent.com/username/msa-project-generator/main/setup-msa-project.sh
chmod +x setup-msa-project.sh
```

### 2. 프로젝트 생성
```bash
./setup-msa-project.sh
```

### 3. 대화형 설정
```bash
🚀 범용 MSA 프로젝트 생성기
===========================================
📝 프로젝트명을 입력하세요 (기본: my-msa-project): online-bookstore
📦 그룹 ID를 입력하세요 (기본: com.example): com.bookstore
🎯 생성할 마이크로서비스 개수를 입력하세요 (1-10): 4

🔧 1번째 서비스명을 입력하세요: user
✅ user-service (포트: 8081)

🔧 2번째 서비스명을 입력하세요: book
✅ book-service (포트: 8082)

🔧 3번째 서비스명을 입력하세요: order  
✅ order-service (포트: 8083)

🔧 4번째 서비스명을 입력하세요: payment
✅ payment-service (포트: 8084)

🌐 API Gateway를 포함하시겠습니까? (y/N): y
✅ API Gateway 포함 (포트: 8080)
```

### 4. 프로젝트 실행
```bash
cd online-bookstore

# 전체 빌드
./build-all.sh

# 모든 서비스 실행
./run-all-services.sh

# 서비스 상태 확인
./check-services.sh
```

## 📁 생성되는 프로젝트 구조

```
online-bookstore/
├── 📚 libs/                          # 공통 라이브러리
│   ├── common-models/                # 공통 도메인 모델 & DTO
│   └── saga-framework/               # Saga 패턴 구현체
├── 🎯 services/                      # 마이크로서비스들
│   ├── user-service/                 # 사용자 관리 (8081)
│   ├── book-service/                 # 도서 관리 (8082)  
│   ├── order-service/                # 주문 처리 (8083)
│   ├── payment-service/              # 결제 처리 (8084)
│   └── api-gateway/                  # API Gateway (8080)
├── 🔨 build-all.sh                   # 전체 빌드 스크립트
├── 🚀 run-all-services.sh            # 모든 서비스 실행
├── 🛑 stop-all-services.sh           # 모든 서비스 중지
├── 📊 check-services.sh              # 서비스 상태 확인
└── 📖 README.md                      # 생성된 프로젝트 가이드
```

## 🌐 생성되는 접속 정보

### Health Check URLs
- **API Gateway**: http://localhost:8080/actuator/health
- **User Service**: http://localhost:8081/actuator/health
- **Book Service**: http://localhost:8082/actuator/health
- **Order Service**: http://localhost:8083/actuator/health
- **Payment Service**: http://localhost:8084/actuator/health

### H2 Database Console
- **User DB**: http://localhost:8081/h2-console (userdb)
- **Book DB**: http://localhost:8082/h2-console (bookdb)
- **Order DB**: http://localhost:8083/h2-console (orderdb)
- **Payment DB**: http://localhost:8084/h2-console (paymentdb)

### API Gateway Routes
- **User API**: http://localhost:8080/api/user/*
- **Book API**: http://localhost:8080/api/book/*
- **Order API**: http://localhost:8080/api/order/*
- **Payment API**: http://localhost:8080/api/payment/*

## 💡 사용 사례

### 🛒 **E-commerce 플랫폼**
```bash
서비스: user, product, cart, order, payment, shipping, review, notification
```

### 📱 **소셜 미디어 플랫폼**
```bash
서비스: user, post, comment, like, follow, notification, media, chat
```

### 🏦 **금융 시스템**
```bash
서비스: account, transaction, loan, credit, fraud-detection, notification
```

### 🏥 **헬스케어 시스템**
```bash
서비스: patient, doctor, appointment, medical-record, prescription, billing
```

### 🎓 **온라인 교육 플랫폼**
```bash
서비스: user, course, lesson, quiz, progress, certificate, payment
```

### 🏨 **호텔 예약 시스템**
```bash
서비스: user, hotel, room, booking, payment, review, notification
```

## 🔧 고급 사용법

### 개별 서비스 관리
```bash
# 특정 서비스만 빌드
./gradlew :services:user-service:build

# 특정 서비스만 실행
./gradlew :services:user-service:bootRun

# 특정 서비스 테스트
./gradlew :services:user-service:test

# 로그 확인
tail -f logs/user-service.log
```

### 데이터베이스 변경
H2 대신 PostgreSQL 사용하려면:

```yaml
# application.yml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/userdb
    driver-class-name: org.postgresql.Driver
    username: postgres
    password: password
```

```gradle
// build.gradle
dependencies {
    runtimeOnly 'org.postgresql:postgresql'
}
```

### 프로덕션 배포
```bash
# JAR 빌드
./gradlew bootJar

# Docker 이미지 빌드 (Dockerfile 추가 후)
docker build -t user-service:latest services/user-service/

# Kubernetes 배포 (yaml 파일 추가 후)
kubectl apply -f k8s/
```

## 🛠️ 시스템 요구사항

### 필수 요구사항
- **Java 21** 이상
- **Bash Shell** (Linux, macOS, WSL)
- **curl** (스크립트 다운로드용)

### 권장 요구사항
- **Gradle 8.8** (없으면 자동 설치)
- **Git** (버전 관리용)
- **Docker** (컨테이너 배포용)
- **IDE**: IntelliJ IDEA, VS Code

## 🎯 설계 철학

### 🚀 **Zero Configuration**
복잡한 설정 없이 **즉시 실행 가능한** 프로젝트 생성

### 🔧 **Production Ready**
**실제 운영환경**에서 사용할 수 있는 수준의 코드 품질

### 📚 **Learning Friendly**
MSA 패턴과 **최신 기술 스택**을 학습할 수 있는 완전한 예제

### 🎨 **Highly Customizable**
다양한 도메인과 요구사항에 **유연하게 대응** 가능

## 🤝 기여하기

이 프로젝트는 오픈소스입니다! 기여를 환영합니다.

### 기여 방법
1. 이 레포지토리를 **Fork**
2. 새로운 브랜치 생성 (`git checkout -b feature/amazing-feature`)
3. 변경사항 커밋 (`git commit -m 'Add amazing feature'`)
4. 브랜치에 Push (`git push origin feature/amazing-feature`)
5. **Pull Request** 생성

### 개선 아이디어
- [ ] Docker Compose 자동 생성
- [ ] Kubernetes 매니페스트 생성
- [ ] CI/CD 파이프라인 템플릿
- [ ] 다양한 데이터베이스 지원
- [ ] 메시지 큐 통합 (RabbitMQ, Kafka)
- [ ] 모니터링 도구 통합 (Prometheus, Grafana)
- [ ] 보안 설정 템플릿
- [ ] API 문서화 자동 생성

## 🐛 이슈 신고

버그를 발견하거나 기능 제안이 있다면 **[Issues](https://github.com/username/msa-project-generator/issues)**에 등록해주세요.

## ⭐ Star History

If this project helps you, please consider giving it a star!

```bash
# Quick stats
⭐ Stars: Growing
🍴 Forks: Welcome
🐛 Issues: Active support
💡 PRs: Open to contributions
```

## 📄 라이선스

이 프로젝트는 [MIT License](LICENSE) 하에 있습니다.

## 🙏 감사의 말

이 프로젝트는 MSA 아키텍처를 학습하고 싶어하는 개발자들을 위해 만들어졌습니다. 
**Spring Boot**, **Gradle**, **Java** 커뮤니티에 감사드립니다.

---

<div align="center">

**⭐ 이 프로젝트가 도움이 되었다면 Star를 눌러주세요! ⭐**

[🐛 버그 신고](https://github.com/username/msa-project-generator/issues) • 
[💡 기능 제안](https://github.com/username/msa-project-generator/issues) • 
[📖 문서](https://github.com/username/msa-project-generator/wiki)

</div>

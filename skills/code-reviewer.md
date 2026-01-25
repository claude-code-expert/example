--- 
name: code-reviewer
description: 코드 리뷰 수행. PR 리뷰, 코드 품질 분석 요청 시 사용.
allowed-tools: Read, Grep, Glob
---

# 코드 리뷰 가이드
## 이 Skill을 사용할 때
- PR 리뷰 요청
- 코드 품질 분석
- 리팩토링 전 검토

## Instructions

### 적용 범위

이 Skill은 프로젝트 전체 코드에 적용됩니다:
- `frontend/src/**/*.{ts,tsx}`
- `backend/src/**/*.ts`

## 리뷰 관점

### 1. 코드 품질
- 타입 안정성 (any 사용 여부)
- 함수 길이 (30줄 이하 권장)
- 중복 코드 여부
### 2. 컨벤션 준수
- 네이밍 규칙 준수 여부
- 파일/폴더 구조 준수 여부

## 제한 사항
이 Skill은 읽기 전용입니다. 코드를 직접 수정하지 않고 피드백만 제공합니다.

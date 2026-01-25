---
name: react-component
description: TODO 앱의 React 컴포넌트를 팀 컨벤션에 맞게 생성합니다.
  컴포넌트 생성, UI 개발 요청 시 사용합니다.
allowed-tools: Read, Write, Glob
---

# React 컴포넌트 생성 가이드

## 적용 범위

이 Skill은 다음 경로의 파일에 적용됩니다:
- `frontend/src/components/**/*.tsx`
- `frontend/src/components/**/*.test.tsx`

## 폴더 구조

새 컴포넌트는 다음 구조로 생성합니다:

frontend/src/components/{컴포넌트명}/
├── index.tsx                 # 메인 컴포넌트
├── {컴포넌트명}.styles.ts    # styled-components
├── {컴포넌트명}.types.ts     # 타입 정의
└── __tests__/
└── {컴포넌트명}.test.tsx # 테스트 파일

## 네이밍 규칙

- 컴포넌트명: PascalCase (예: TodoItem, TodoList)
- 파일명: 컴포넌트명과 동일

## 템플릿 참조

컴포넌트 생성 시 `templates/component.tsx` 템플릿을 사용합니다.
테스트 생성 시 `templates/component.test.tsx` 템플릿을 사용합니다.

## 금지 사항

- `any` 타입 사용 금지
- 인라인 스타일 사용 금지
- default export 사용 금지 (named export만 사용)
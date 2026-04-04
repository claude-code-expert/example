# Git CLI 필수 명령어 레퍼런스

---

## 1. 필수 명령어

### 저장소 초기화 / 클론

| 명령어 | 문법 | 예시 |
|--------|------|------|
| 저장소 초기화 | `git init` | `git init` |
| 원격 저장소 클론 | `git clone <url>` | `git clone https://github.com/user/tika.git` |
| 원격 저장소 등록 | `git remote add <name> <url>` | `git remote add origin https://github.com/user/tika.git` |
| 원격 저장소 확인 | `git remote -v` | `git remote -v` |

### 브랜치

| 명령어 | 문법 | 예시 |
|--------|------|------|
| 브랜치 목록 확인 | `git branch` | `git branch` |
| 원격 포함 전체 목록 | `git branch -a` | `git branch -a` |
| 새 브랜치 생성 | `git branch <name>` | `git branch feature/kanban-board` |
| 새 브랜치 생성 + 전환 | `git checkout -b <name>` | `git checkout -b feature/kanban-board` |
| 새 브랜치 생성 + 전환 (신규 문법) | `git switch -c <name>` | `git switch -c feature/kanban-board` |
| 브랜치 삭제 | `git branch -d <name>` | `git branch -d feature/kanban-board` |
| 브랜치 이름 변경 | `git branch -m <old> <new>` | `git branch -m master main` |

### 체크아웃 / 전환

| 명령어 | 문법 | 예시 |
|--------|------|------|
| 브랜치 전환 | `git checkout <branch>` | `git checkout main` |
| 브랜치 전환 (신규 문법) | `git switch <branch>` | `git switch main` |
| 특정 커밋으로 이동 | `git checkout <commit-hash>` | `git checkout a1b2c3d` |
| 파일 변경 되돌리기 | `git checkout -- <file>` | `git checkout -- src/app.ts` |

### 스테이징 / 커밋

| 명령어 | 문법 | 예시 |
|--------|------|------|
| 파일 스테이징 | `git add <file>` | `git add src/components/Board.tsx` |
| 여러 파일 스테이징 | `git add <file1> <file2>` | `git add src/db/schema.ts src/types/index.ts` |
| 전체 스테이징 | `git add .` | `git add .` |
| 커밋 | `git commit -m "<message>"` | `git commit -m "티켓 생성 API 구현"` |
| 스테이징 + 커밋 (tracked 파일만) | `git commit -am "<message>"` | `git commit -am "버그 수정: position 계산 오류"` |
| 직전 커밋 메시지 수정 | `git commit --amend -m "<message>"` | `git commit --amend -m "수정된 커밋 메시지"` |

### 상태 확인 / 로그

| 명령어 | 문법 | 예시 |
|--------|------|------|
| 작업 상태 확인 | `git status` | `git status` |
| 변경 내용 확인 | `git diff` | `git diff` |
| 스테이징된 변경 확인 | `git diff --staged` | `git diff --staged` |
| 커밋 로그 | `git log --oneline` | `git log --oneline -10` |
| 그래프 형태 로그 | `git log --oneline --graph --all` | `git log --oneline --graph --all` |

### Fetch / Pull / Push

| 명령어 | 문법 | 예시 |
|--------|------|------|
| 원격 변경사항 가져오기 (병합 X) | `git fetch <remote>` | `git fetch origin` |
| 전체 원격 브랜치 가져오기 | `git fetch --all` | `git fetch --all` |
| 원격 변경사항 가져오기 + 병합 | `git pull <remote> <branch>` | `git pull origin main` |
| 리베이스 방식 pull | `git pull --rebase <remote> <branch>` | `git pull --rebase origin main` |
| 원격에 푸시 | `git push <remote> <branch>` | `git push origin feature/kanban-board` |
| 원격 브랜치 추적 설정 + 푸시 | `git push -u <remote> <branch>` | `git push -u origin feature/kanban-board` |
| 원격 브랜치 삭제 | `git push <remote> --delete <branch>` | `git push origin --delete feature/old-branch` |

### Merge

| 명령어 | 문법 | 예시 |
|--------|------|------|
| 브랜치 병합 | `git merge <branch>` | `git merge feature/kanban-board` |
| 병합 커밋 없이 (fast-forward) | `git merge --ff-only <branch>` | `git merge --ff-only hotfix/typo` |
| 항상 병합 커밋 생성 | `git merge --no-ff <branch>` | `git merge --no-ff feature/kanban-board` |
| 병합 충돌 해결 후 계속 | `git add . && git commit` | `git add . && git commit -m "충돌 해결"` |
| 관련 없는 히스토리 병합 | `git merge <branch> --allow-unrelated-histories` | `git merge feature --allow-unrelated-histories` |
| 병합 취소 | `git merge --abort` | `git merge --abort` |

### 태그

| 명령어 | 문법 | 예시 |
|--------|------|------|
| 태그 목록 | `git tag` | `git tag` |
| 경량 태그 생성 | `git tag <name>` | `git tag v0.1.0` |
| 주석 태그 생성 | `git tag -a <name> -m "<message>"` | `git tag -a v0.1.0 -m "MVP 릴리스"` |
| 특정 커밋에 태그 | `git tag -a <name> <commit>` | `git tag -a v0.1.0 a1b2c3d` |
| 태그 푸시 | `git push <remote> <tag>` | `git push origin v0.1.0` |
| 전체 태그 푸시 | `git push <remote> --tags` | `git push origin --tags` |
| 태그 삭제 (로컬) | `git tag -d <name>` | `git tag -d v0.1.0` |
| 태그 삭제 (원격) | `git push <remote> --delete <tag>` | `git push origin --delete v0.1.0` |

---

## 2. 고급 명령어

### Allow Unrelated Histories

> 공통 조상 커밋이 없는 **독립적인 두 히스토리를 병합**한다. `git init`으로 새로 만든 로컬 저장소와 기존 원격 저장소를 합치거나, 서로 다른 프로젝트를 하나로 통합할 때 사용한다.

**대표 사용 사례**: 로컬에서 `git init`으로 시작한 프로젝트를 이미 커밋이 있는 원격 저장소와 병합할 때.

```bash
# 문법
git merge <branch> --allow-unrelated-histories

# 예시 1: 원격 브랜치를 로컬 main에 병합
git fetch origin
git merge origin/feature --allow-unrelated-histories

# 예시 2: 로컬 브랜치끼리 병합
git merge feature --allow-unrelated-histories

# 예시 3: pull 시에도 사용 가능
git pull origin main --allow-unrelated-histories
```

> **발생 상황**: `fatal: refusing to merge unrelated histories` 에러가 나타나면 두 브랜치가 공통 조상이 없다는 의미이다. 의도적으로 합쳐야 하는 경우에만 이 옵션을 사용하고, 충돌이 발생하면 수동으로 해결한다.

---

### Cherry-pick

> 다른 브랜치의 **특정 커밋 하나만** 현재 브랜치로 가져온다. 전체 브랜치를 병합하지 않고, 필요한 커밋만 선택적으로 적용할 때 사용한다.

**대표 사용 사례**: hotfix 브랜치에서 수정한 버그 픽스 커밋을 develop 브랜치에도 적용하고 싶을 때.

```bash
# 문법
git cherry-pick <commit-hash>

# 예시: hotfix 브랜치의 특정 커밋을 현재 브랜치에 적용
git log --oneline hotfix/urgent       # 커밋 해시 확인
git cherry-pick a1b2c3d               # 해당 커밋만 가져오기

# 여러 커밋을 연속 적용
git cherry-pick a1b2c3d e4f5g6h

# 충돌 발생 시
git cherry-pick --abort               # 취소
git cherry-pick --continue            # 충돌 해결 후 계속
```

---

### Stash

> 현재 작업 중인 변경사항을 **임시 저장소에 보관**하고 워킹 디렉토리를 깨끗한 상태로 되돌린다. 작업 중 급하게 다른 브랜치로 전환해야 할 때 커밋하지 않고 변경사항을 보존할 수 있다.

**대표 사용 사례**: 기능 개발 중 긴급 버그 수정 요청이 와서, 현재 미완성 작업을 임시 보관하고 hotfix 브랜치로 전환할 때.

```bash
# 문법
git stash                             # 변경사항 임시 저장
git stash push -m "<message>"         # 메시지와 함께 저장

# 예시: 작업 중 브랜치 전환이 필요할 때
git stash push -m "Board 드래그 작업 중"
git switch hotfix/urgent              # 다른 브랜치에서 작업
# ... 작업 완료 ...
git switch feature/kanban-board
git stash pop                         # 마지막 stash 복원 + 삭제

# stash 관리
git stash list                        # 저장된 stash 목록
git stash show -p stash@{0}           # 특정 stash 내용 확인
git stash apply stash@{1}             # 특정 stash 복원 (삭제 안 함)
git stash drop stash@{0}              # 특정 stash 삭제
git stash clear                       # 전체 stash 삭제
```

---

### Squash (Interactive Rebase)

> 여러 개의 커밋을 **하나의 커밋으로 합친다**. 기능 개발 중 생긴 잡다한 커밋들("WIP", "typo 수정", "다시 수정")을 하나의 깔끔한 커밋으로 정리할 때 사용한다.

**대표 사용 사례**: PR 생성 전에 feature 브랜치의 커밋 5개를 의미 있는 커밋 1개로 합칠 때.

```bash
# 문법: 최근 N개 커밋을 대화형으로 정리
git rebase -i HEAD~<N>

# 예시: 최근 3개 커밋을 하나로 합치기
git rebase -i HEAD~3
# 에디터가 열리면:
#   pick a1b2c3d 첫 번째 커밋 (유지)
#   squash e4f5g6h 두 번째 커밋 (위 커밋에 합침)
#   squash i7j8k9l 세 번째 커밋 (위 커밋에 합침)
# 저장 후 커밋 메시지 편집

# merge 시 squash 옵션 (별도 커밋으로 합침)
git merge --squash feature/kanban-board
git commit -m "칸반 보드 기능 구현"
```

---

### Rebase

> 현재 브랜치의 커밋들을 **다른 브랜치 위로 재배치**한다. merge와 달리 병합 커밋 없이 직선형 히스토리를 만든다. 최신 main 위에 feature 작업을 얹고 싶을 때 사용한다.

**대표 사용 사례**: feature 브랜치에서 작업하는 동안 main이 앞서 나갔을 때, main의 최신 커밋 위에 내 작업을 재배치할 때.

```bash
# 문법
git rebase <base-branch>

# 예시: main의 최신 상태 위에 현재 브랜치 재배치
git switch feature/kanban-board
git rebase main

# 충돌 발생 시
git rebase --abort                    # 취소
git rebase --continue                 # 충돌 해결 후 계속
git rebase --skip                     # 현재 커밋 건너뛰기
```

> **주의**: 이미 push한 커밋을 rebase하면 히스토리가 변경되므로, 공유 브랜치에서는 사용하지 않는다.

---

### Reset

> 커밋 이력을 **되돌린다**. 되돌리는 강도에 따라 3가지 모드가 있다.

**대표 사용 사례**: 방금 한 커밋을 취소하고 다시 작업하고 싶을 때.

```bash
# soft: 커밋만 취소 (변경사항은 스테이징에 유지)
git reset --soft HEAD~1

# mixed (기본값): 커밋 + 스테이징 취소 (변경사항은 워킹 디렉토리에 유지)
git reset HEAD~1

# hard: 커밋 + 스테이징 + 변경사항 모두 삭제 ⚠️ 복구 불가
git reset --hard HEAD~1

# 특정 커밋으로 되돌리기
git reset --soft a1b2c3d
```

> **주의**: `--hard`는 변경사항이 완전히 삭제된다. 이미 push한 커밋에 사용 시 `force push`가 필요하므로 신중하게 사용한다.

---

### Revert

> 특정 커밋의 변경사항을 **취소하는 새 커밋**을 생성한다. reset과 달리 히스토리를 변경하지 않으므로 공유 브랜치에서도 안전하게 사용할 수 있다.

**대표 사용 사례**: 이미 push된 커밋에 문제가 있어서 되돌려야 할 때.

```bash
# 문법
git revert <commit-hash>

# 예시: 특정 커밋 되돌리기
git revert a1b2c3d

# 커밋 메시지 편집 없이 바로 적용
git revert --no-edit a1b2c3d

# 여러 커밋 범위 되돌리기
git revert HEAD~3..HEAD
```

---

### Bisect

> **이진 탐색**으로 버그가 도입된 커밋을 찾는다. "여기는 정상", "여기는 버그"를 표시하면 Git이 자동으로 범위를 좁혀가며 문제 커밋을 찾아준다.

**대표 사용 사례**: "언제부터 이 버그가 생겼지?" — 수십 개 커밋 중 원인 커밋을 빠르게 특정할 때.

```bash
# 시작
git bisect start

# 현재 상태가 버그 있음
git bisect bad

# 이 커밋은 정상이었음
git bisect good a1b2c3d

# Git이 중간 커밋을 체크아웃 → 테스트 후 판정
git bisect good                       # 이 커밋은 정상
git bisect bad                        # 이 커밋은 버그 있음
# ... 반복하면 원인 커밋을 찾아줌 ...

# 종료
git bisect reset
```

---

### Reflog

> Git의 **모든 HEAD 이동 기록**을 보여준다. 실수로 삭제한 커밋이나 브랜치를 복구할 때 사용한다. `reset --hard`로 날린 커밋도 여기서 찾을 수 있다.

**대표 사용 사례**: `git reset --hard`를 잘못 실행해서 날린 작업을 복구할 때.

```bash
# HEAD 이동 기록 확인
git reflog

# 출력 예시:
# a1b2c3d HEAD@{0}: reset: moving to HEAD~3
# e4f5g6h HEAD@{1}: commit: 드래그앤드롭 구현
# i7j8k9l HEAD@{2}: commit: Column 컴포넌트 추가

# 특정 시점으로 복구
git reset --hard HEAD@{1}             # e4f5g6h 시점으로 복구
```

---

### Worktree

> 하나의 저장소에서 **여러 브랜치를 동시에 체크아웃**한다. 브랜치 전환 없이 다른 디렉토리에서 별도 브랜치 작업이 가능하다.

**대표 사용 사례**: feature 작업 중 hotfix를 별도 디렉토리에서 동시에 진행할 때.

```bash
# 새 worktree 생성
git worktree add <path> <branch>

# 예시: hotfix 브랜치를 별도 디렉토리에서 작업
git worktree add ../tika-hotfix hotfix/urgent
cd ../tika-hotfix
# ... hotfix 작업 ...
cd ../tika

# worktree 목록 확인
git worktree list

# worktree 삭제
git worktree remove ../tika-hotfix
```

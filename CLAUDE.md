# Global Development Rules

범프로젝트 공통 개발 규칙. 각 프로젝트 CLAUDE.md와 함께 적용됨.

---

# Workflow

## Issue-driven Development

When given a GitHub issue number (e.g. `#123`), follow these steps in order:

1. **Analyze**: Read the issue content from context. Clarify requirements before touching code.
2. **Branch**: Create a branch named `issue-{number}-{short-description}` from the latest main (`git checkout main && git pull && git checkout -b ...`).
3. **Implement**: Make changes according to the issue requirements.
4. **Verify**: Run tests and lint. Fix all failures before proceeding.
5. **PR**: Create a PR with the issue number in the title and body.
6. **Wrap up**: Update CLAUDE.md if any new conventions or patterns were introduced.
7. **Stay**: Remain on the feature branch (do **not** switch back to main) so the change can be verified locally. Correctness of the next task is guaranteed by step 2 (branch from latest main), not by returning to main. Prune local branches whose remote is gone (`git fetch -p`, delete `[gone]` branches — skip any with unpushed work and report them).

Do not skip steps. Do not create a PR if tests or lint are failing.

## Prompt-driven Development

When given a Prompt from user (e.g. `Add tests and increase test coverage`), follow these steps in order:

1. **Analyze**: Read the prompt. Clarify requirements before touching code.
2. **Branch**: Create a branch named `{type}/{short-description}` (e.g. `feat/add-tests`) from the latest main (`git checkout main && git pull && git checkout -b ...`).
3. **Implement**: Make changes according to the requirements.
4. **Verify**: Run tests and lint. Fix all failures before proceeding.
5. **PR**: Create a PR with the description in the title and body.
6. **Wrap up**: Update CLAUDE.md if any new conventions or patterns were introduced.
7. **Stay**: Remain on the feature branch (do **not** switch back to main) so the change can be verified locally. Correctness of the next task is guaranteed by step 2 (branch from latest main), not by returning to main. Prune local branches whose remote is gone (`git fetch -p`, delete `[gone]` branches — skip any with unpushed work and report them).

---

## 개발 방법론: Agentic TDD + RLAIF

**Agentic TDD**와 **RLAIF**를 결합한 방법론으로 개발한다.

### Agentic TDD

기존 TDD(Red → Green → Refactor)의 사이클을 AI 에이전트가 **자율적으로** 수행한다.

```
[요구사항 분석] → [테스트 작성 (Red)] → [구현 (Green)] → [리팩터링] → [자가 검증]
      ↑                                                                    |
      └──────────────── AI Feedback Loop (RLAIF) ──────────────────────────┘
```

### RLAIF (Reinforcement Learning from AI Feedback)

AI 에이전트가 자신의 결과물을 스스로 피드백하고 개선한다. 평가 항목:
- **코드 품질**: 가독성, 중복 제거, 네이밍 일관성
- **아키텍처 일관성**: 프로젝트 문서에 정의된 구조와 패턴 준수 여부
- **엣지 케이스 커버리지**: 예외 상황이 충분히 테스트되었는가
- **보안**: 인증/인가, 입력 검증, SQL Injection 방지

### 개발 워크플로우

**Phase 1: 요구사항 분석**
1. 프로젝트 문서에서 비즈니스 요구사항 및 기술 스펙 파악
2. 구현 범위와 영향도 분석 → 작업 단위 세분화

**Phase 2: 테스트 작성 (Red)**
1. 기능 요구사항에 맞는 테스트 케이스를 먼저 작성
2. 테스트 실행 → **실패(Red) 상태 확인**

**Phase 3: 구현 (Green)**
1. 테스트를 통과시키는 **최소한의 코드** 구현
2. 과도한 추상화 및 미래 요구사항 선제적 구현 지양
3. 모든 테스트 통과(Green) 확인

**Phase 4: 리팩터링 & AI 피드백 (RLAIF)**
1. 중복 제거, 네이밍 개선, 관심사 분리
2. 에러 핸들링, 접근성(a11y) 자가 점검
3. 문제 발견 시 Phase 2로 돌아가 추가 테스트 작성 후 반복

**Phase 5: 최종 검증**
1. 전체 테스트 스위트 실행
2. 타입 체크 및 린트 수행
3. Regression Test — 기존 기능 파괴 여부 확인

---

## 코딩 규칙

### 커밋 메시지 규칙

```
feat: 신규 기능 구현
test: 단위 테스트 추가
fix: 버그 수정
refactor: 중복 코드 제거
docs: CLAUDE.md 최신화
```

### 브랜치 전략

- `main` 브랜치는 보호되어 있어 직접 push 불가. 반드시 feature 브랜치에서 작업 후 Pull Request로만 merge.
- 브랜치 네이밍: `feat/`, `fix/`, `refactor/`, `docs/`, `test/`, `chore/`, `hotfix/` 접두어 사용. 이슈 기반 작업은 `issue-{number}-{short-description}`.
- **신규 작업은 반드시 최신 `main` 브랜치를 기준으로 신규 브랜치를 생성해서 작업한다** (`git checkout main && git pull && git checkout -b feat/new-feature`). 다음 작업의 정합성은 이 "최신 main에서 분기" 단계가 보장하므로, 작업 후 main으로 복귀할 필요가 없다.
- 작업(PR 생성)이 끝나면 **feature 브랜치에 그대로 머문다**(main으로 복귀하지 않는다) — 로컬에서 변경 사항을 확인할 수 있도록. 원격에서 삭제된 `[gone]` 로컬 브랜치만 정리한다(`git fetch -p`).

### 브랜치 생성 강제 (Hook)

`git checkout -b` / `git switch -c` 는 PreToolUse 훅(`~/.claude/hooks/validate-branch.sh`)이 검증한다:
- **네이밍**: 이슈 작업 중이면 `issue-{N}` 포함 필수, 그 외엔 위 접두어 필수.
- **더티 워크트리**: 추적 파일에 커밋 안 된 변경이 있으면 차단 — 사용자에게 상태를 보여주고 stash/commit/폐기 여부를 물어본 뒤 진행한다.
- **베이스 검증**: 권장 복합 명령(`git checkout main && git pull && git checkout -b ...`)이 아니면, 현재 브랜치가 최신 main(origin/main과 동기화)일 때만 생성 허용.
- **예외(스택 브랜치)**: 사용자가 명시적으로 기존 브랜치 위 분기를 요청한 경우에만 `touch ~/.claude/.skip-branch-validation` 후 생성 (1회용 플래그).

---

## 에이전트 행동 규칙

### 권장 사항 (Do's)

- 모든 변경 전에 **기존 테스트를 실행**하여 현재 상태를 파악한다.
- 구현 전 반드시 **실패하는 테스트(Red)**를 먼저 작성한다.
- 에러 발생 시 **근본 원인을 분석**한 후 수정한다 (증상만 고치지 않는다).
- 변경 범위가 큰 경우 **사람에게 확인을 요청**한다.

### 금지 사항 (Don'ts)

- 테스트 없이 기능을 구현하지 않는다.
- 요구사항에 정의되지 않은 기능을 임의로 추가하지 않는다.
- 기존 테스트를 삭제하거나 `skip` 처리하지 않는다.
- 환경 변수의 실제 값을 코드에 하드코딩하지 않는다.
- 환경 변수 파일(`.env*`)을 커밋하지 않는다.

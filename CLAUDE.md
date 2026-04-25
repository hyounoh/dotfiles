# Global Development Rules

범프로젝트 공통 개발 규칙. 각 프로젝트 CLAUDE.md와 함께 적용됨.

---

# Workflow

## Issue-driven Development

When given a GitHub issue number (e.g. `#123`), follow these steps in order:

1. **Analyze**: Read the issue content from context. Clarify requirements before touching code.
2. **Branch**: Create a branch named `issue-{number}-{short-description}` from main.
3. **Implement**: Make changes according to the issue requirements.
4. **Verify**: Run tests and lint. Fix all failures before proceeding.
5. **PR**: Create a PR with the issue number in the title and body.
6. **Wrap up**: Update CLAUDE.md if any new conventions or patterns were introduced.

Do not skip steps. Do not create a PR if tests or lint are failing.

## Prompt-driven Development

When given a Prompt from user (e.g. `Add tests and increase test coverage`), follow these steps in order:

1. **Analyze**: Read the prompt. Clarify requirements before touching code.
2. **Branch**: Create a branch named `task-{short-description}` from main.
3. **Implement**: Make changes according to the requirements.
4. **Verify**: Run tests and lint. Fix all failures before proceeding.
5. **PR**: Create a PR with the description in the title and body.
6. **Wrap up**: Update CLAUDE.md if any new conventions or patterns were introduced.

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
- 브랜치 네이밍: `feat/`, `fix/`, `refactor/`, `docs/` 등 접두어 사용.
- **신규 feature는 반드시 최신 `main` 브랜치를 기준으로 신규 브랜치를 생성해서 작업한다** (`git checkout main && git pull && git checkout -b feat/new-feature`).

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

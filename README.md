# dotfiles

chezmoi로 관리하는 개발 환경 설정.

## 새 머신 설정

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply hyounoh
```

## 일상 사용

```bash
chezmoi edit ~/.zshrc       # 설정 편집
chezmoi apply               # 변경 사항 반영
chezmoi cd                  # 소스 디렉토리로 이동 (git push 등)
chezmoi diff                # 적용 전 미리보기
chezmoi add ~/.config/xxx   # 새 파일 추가
```

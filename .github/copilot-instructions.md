# Copilot Instructions for dotfiles

## tmux設定の検証

tmux.confの構文チェックには、既存セッションに影響を与えない方法を使用すること：

```bash
# 良い例: 新しいサーバーで構文チェックのみ
tmux -L test -f /path/to/tmux.conf new-session -d 2>&1 && tmux -L test kill-server

# 悪い例: 既存セッションをkillしてしまう
tmux -f /path/to/tmux.conf start-server \; kill-server  # NG
```

## シェルスクリプトの構文チェック

```bash
# zsh
zsh -n script.sh

# bash
bash -n script.sh
```

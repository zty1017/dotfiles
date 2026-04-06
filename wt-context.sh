#!/usr/bin/env bash

set -euo pipefail

task_file="${1:-TASK.md}"
agents_file="${2:-AGENTS.md}"

show_section() {
    printf '\n=== %s ===\n' "$1"
}

show_section "当前目录"
pwd

show_section "当前分支"
git branch --show-current 2>/dev/null || true

show_section "Worktree 列表"
git worktree list 2>/dev/null || true

show_section "任务说明 (${task_file})"
if [ -f "$task_file" ]; then
    sed -n '1,220p' "$task_file"
else
    echo "(无 ${task_file})"
fi

show_section "共享规则 (${agents_file})"
if [ -f "$agents_file" ]; then
    sed -n '1,220p' "$agents_file"
else
    echo "(无 ${agents_file})"
fi

show_section "计划文件 (PLAN.md)"
if [ -f "PLAN.md" ]; then
    sed -n '1,220p' PLAN.md
else
    echo "(无 PLAN.md)"
fi

show_section "Git 状态"
git status --short 2>/dev/null || true

show_section "当前未提交修改"
git diff --stat 2>/dev/null || true
printf '\n'
git diff --minimal 2>/dev/null || true

show_section "最近提交"
git log --oneline -n 10 2>/dev/null || true

show_section "目录结构（两层）"
if command -v tree >/dev/null 2>&1; then
    tree -L 2 -I '.git|node_modules|dist|build|__pycache__|.venv|.pytest_cache|.mypy_cache' 2>/dev/null || true
else
    find . -maxdepth 2 \
        -not -path './.git*' \
        -not -path './node_modules*' \
        -not -path './dist*' \
        -not -path './build*' \
        -not -path './__pycache__*' \
        -not -path './.venv*' \
        | sort
fi

#!/usr/bin/env bash

set -euo pipefail

find_dotfiles_dir() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [ -f "$script_dir/../TASK_TEMPLATE.md" ]; then
        cd "$script_dir/.." && pwd
        return 0
    fi

    if [ -f "$HOME/dotfiles/TASK_TEMPLATE.md" ]; then
        printf '%s\n' "$HOME/dotfiles"
        return 0
    fi

    echo "无法定位 dotfiles 目录，请设置 DOTFILES_DIR 或从仓库 bin/ 下运行脚本" >&2
    return 1
}

require_git_repo() {
    if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
        echo "当前目录不在 Git 仓库中" >&2
        return 1
    fi
}

slugify() {
    printf '%s' "$1" \
        | tr '[:upper:]' '[:lower:]' \
        | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

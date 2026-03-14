# My Dotfiles

A quick setup script to bootstrap my terminal environment across multiple servers.

## Features

- **Vim**: Configured with `vim-plug`, `vim-code-dark` (VS Code style), NERDTree, `fzf`, and Python optimizations.
- **Tmux**: Prefix mapped to `Ctrl+a`, true color support, mouse mode, intuitive split bindings (`|` and `-`), and clean status bar.
- **Tools**: Auto-installs `ripgrep` (for fast searches) and `glow` (for terminal Markdown rendering) without requiring root.
- **Cheat Sheet**: Adds a `cheat` alias to `.bashrc` for quick reference of Vim and Tmux bindings.

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
bash ~/dotfiles/setup.sh
```

## Shortcuts (via `cheat` command)

Run `cheat` in the terminal anytime to see:

### Tmux (`Ctrl+a` prefix)
- `prefix + |` : Vertical split
- `prefix + -` : Horizontal split
- `prefix + h/j/k/l` : Switch panes (Vim style)

### Vim
- `Ctrl + n` : Toggle NERDTree
- `Ctrl + p` : Fuzzy find files (`fzf`)
- `Ctrl + f` : Full-text search (`rg`)

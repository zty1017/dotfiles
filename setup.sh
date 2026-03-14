#!/bin/bash
# 一键部署 Vim + tmux 终端环境
# 用法: curl/scp 到目标服务器后执行 bash setup.sh

set -e

echo "=== 部署终端环境 ==="

# 1. 安装 vim-plug
echo "[1/5] 安装 vim-plug..."
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 2. 安装插件
echo "[2/5] 安装 Vim 插件..."
mkdir -p ~/.vim/plugged
cd ~/.vim/plugged
for repo in \
    tomasiser/vim-code-dark \
    preservim/nerdtree \
    junegunn/fzf \
    junegunn/fzf.vim \
    vim-airline/vim-airline \
    LunarWatcher/auto-pairs \
    Vimjas/vim-python-pep8-indent \
    stephpy/vim-yaml; do
    name=$(basename "$repo")
    if [ -d "$name" ]; then
        echo "  $name 已存在，跳过"
    else
        echo "  安装 $name..."
        git clone --depth 1 "https://github.com/$repo.git" 2>/dev/null
    fi
done

# 3. 安装 fzf 二进制
echo "[3/5] 安装 fzf 二进制..."
~/.vim/plugged/fzf/install --bin 2>/dev/null || true

# 4. 安装 ripgrep（无需 root）
echo "[4/5] 安装 ripgrep..."
mkdir -p ~/bin
if command -v rg &>/dev/null; then
    echo "  ripgrep 已存在，跳过"
else
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        RG_URL="https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz"
    elif [ "$ARCH" = "aarch64" ]; then
        RG_URL="https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-aarch64-unknown-linux-gnu.tar.gz"
    else
        echo "  不支持的架构: $ARCH，跳过 ripgrep"
        RG_URL=""
    fi
    if [ -n "$RG_URL" ]; then
        curl -fLo /tmp/rg.tar.gz "$RG_URL"
        tar xzf /tmp/rg.tar.gz -C /tmp
        cp /tmp/ripgrep-*/rg ~/bin/
        rm -rf /tmp/rg.tar.gz /tmp/ripgrep-*
        echo "  ripgrep 已安装到 ~/bin/rg"
    fi
fi

# 确保 ~/bin 在 PATH 中
if ! echo "$PATH" | grep -q "$HOME/bin"; then
    for rc in ~/.bashrc ~/.zshrc; do
        if [ -f "$rc" ] && ! grep -q 'export PATH="$HOME/bin:$PATH"' "$rc"; then
            echo 'export PATH="$HOME/bin:$PATH"' >> "$rc"
            echo "  已添加 ~/bin 到 $rc"
        fi
    done
fi

# 安装 glow (Markdown 渲染)
echo "[4.5] 安装 glow (Markdown 渲染工具)..."
if command -v glow &>/dev/null; then
    echo "  glow 已存在，跳过"
else
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        GLOW_URL="https://github.com/charmbracelet/glow/releases/download/v2.0.0/glow_2.0.0_Linux_x86_64.tar.gz"
        curl -fLo /tmp/glow.tar.gz "$GLOW_URL"
        tar xzf /tmp/glow.tar.gz -C /tmp glow_2.0.0_Linux_x86_64/glow
        mv /tmp/glow_2.0.0_Linux_x86_64/glow ~/bin/
        rm -rf /tmp/glow.tar.gz /tmp/glow_2.0.0_Linux_x86_64
        echo "  glow 已安装到 ~/bin/glow"
    else
        echo "  暂不支持自动安装 glow 到非 x86_64 架构"
    fi
fi

# 写入速查命令到 bashrc
echo "[4.8] 配置 cheat 速查命令..."
if ! grep -q "alias cheat" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

alias cheat='echo "
=== tmux (prefix = Ctrl+a) ===
  prefix+|    竖分屏
  prefix+-    横分屏
  prefix+hjkl 切换面板
  prefix+1-9  切换窗口
  prefix+c    新窗口
  prefix+d    分离 session
  prefix+r    重载配置
  prefix+?    所有快捷键
  prefix+w    窗口列表
  prefix+[    滚动模式 (q退出)

=== Vim ===
  Ctrl+n  文件树
  Ctrl+p  搜索文件
  Ctrl+f  全文搜索
  :w      保存
  :q      退出
  :wq     保存退出
  dd      删除行
  yy/p    复制/粘贴行
  u       撤销
  /关键词 搜索
"'
EOF
fi

# 5. 写入配置文件
echo "[5/5] 写入配置文件..."

# 备份旧配置
[ -f ~/.vimrc ] && cp ~/.vimrc ~/.vimrc.bak.$(date +%s)
[ -f ~/.tmux.conf ] && cp ~/.tmux.conf ~/.tmux.conf.bak.$(date +%s)

cat > ~/.vimrc << 'VIMRC'
set nocompatible

" 插件管理
call plug#begin('~/.vim/plugged')
Plug 'tomasiser/vim-code-dark'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'LunarWatcher/auto-pairs'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'stephpy/vim-yaml'
call plug#end()

" 基础设置
set number
set relativenumber
set cursorline

" 修复 tmux 下真彩色
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors

set background=dark
syntax on
colorscheme codedark

" Python 相关
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set autoindent
set fileencoding=utf-8

" NERDTree 快捷键
nnoremap <C-n> :NERDTreeToggle<CR>

" fzf 快捷键
nnoremap <C-p> :Files<CR>
nnoremap <C-f> :Rg<CR>
VIMRC

cat > ~/.tmux.conf << 'TMUX'
# prefix 改为 Ctrl+a
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# 真彩色支持
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"
set -g default-command "${SHELL}"

# 鼠标支持
set -g mouse on

# 解决 Vim 中 Esc 延迟
set -sg escape-time 10

# 增大滚动缓冲区
set -g history-limit 50000

# 窗口编号从 1 开始
set -g base-index 1
setw -g pane-base-index 1

# 窗口关闭后自动重新编号
set -g renumber-windows on

# 分屏快捷键
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"

# 新窗口保持当前目录
bind c new-window -c "#{pane_current_path}"

# vim 风格切换面板
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# 快速重载配置
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# 状态栏美化
set -g status-style bg=colour235,fg=colour136
set -g status-left-length 30
set -g status-right-length 50
set -g status-left '#[fg=colour46]#S #[fg=colour240]| '
set -g status-right '#[fg=colour240]| #[fg=colour250]%H:%M #[fg=colour240]| #[fg=colour250]%m-%d'

# 当前窗口高亮
setw -g window-status-current-style fg=colour81,bold
setw -g window-status-style fg=colour240

# 面板边框
set -g pane-border-style fg=colour240
set -g pane-active-border-style fg=colour81

setw -g aggressive-resize on
TMUX

echo ""
echo "=== 部署完成 ==="
echo "快捷键:"
echo "  Vim:  Ctrl+n 文件树 | Ctrl+p 搜索文件 | Ctrl+f 全文搜索"
echo "  tmux: prefix+| 竖分屏 | prefix+- 横分屏 | prefix+hjkl 切换面板"
echo "  tmux: prefix+r 重载配置"
echo ""
echo "请重新登录或执行 source ~/.bashrc 使 PATH 生效"

#!/bin/bash
# 一键部署 Vim + tmux 终端环境
# 用法: curl/scp 到目标服务器后执行 bash setup.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    tpope/vim-commentary \
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

# 确保 ~/bin 和 dotfiles/bin 在 PATH 中
if ! echo "$PATH" | grep -q "$HOME/bin"; then
    for rc in ~/.bashrc ~/.zshrc; do
        if [ -f "$rc" ] && ! grep -q 'export PATH="$HOME/bin:$PATH"' "$rc"; then
            echo 'export PATH="$HOME/bin:$PATH"' >> "$rc"
            echo "  已添加 ~/bin 到 $rc"
        fi
    done
fi

if ! echo "$PATH" | grep -q "$SCRIPT_DIR/bin"; then
    for rc in ~/.bashrc ~/.zshrc; do
        if [ -f "$rc" ] && ! grep -Fq "export PATH=\"$SCRIPT_DIR/bin:\$PATH\"" "$rc"; then
            echo "export PATH=\"$SCRIPT_DIR/bin:\$PATH\"" >> "$rc"
            echo "  已添加 $SCRIPT_DIR/bin 到 $rc"
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
    {
        echo ""
        cat "$SCRIPT_DIR/config/shell/cheat_alias.sh"
    } >> ~/.bashrc
fi

# 5. 写入配置文件
echo "[5/5] 写入配置文件..."

# 备份旧配置
[ -f ~/.vimrc ] && cp ~/.vimrc ~/.vimrc.bak.$(date +%s)
[ -f ~/.tmux.conf ] && cp ~/.tmux.conf ~/.tmux.conf.bak.$(date +%s)

cp "$SCRIPT_DIR/config/vim/vimrc" ~/.vimrc
cp "$SCRIPT_DIR/config/tmux/tmux.conf" ~/.tmux.conf

echo ""
echo "=== 部署完成 ==="
echo "快捷键:"
echo "  Vim:  Ctrl+n 文件树 | Ctrl+p 搜索文件 | Ctrl+f 全文搜索"
echo "  tmux: prefix+| 竖分屏 | prefix+- 横分屏 | prefix+hjkl 切换面板"
echo "  tmux: prefix+r 重载配置"
echo ""
echo "请重新登录或执行 source ~/.bashrc 使 PATH 生效"

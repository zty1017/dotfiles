# 极简终端开发环境 (Dotfiles)

专为 **多服务器部署**、**多 worktree 开发** 和 **AI CLI 工具辅助开发** 设计的轻量终端环境。

## 核心理念

1. **零配置心智负担**：不依赖庞大的 LSP（交由 AI 工具补全），只提供最高频的代码微调和查看能力。
2. **极速跨机同步**：一段命令完成部署，无 root 依赖，自带幂等性，可反复执行。
3. **终端优先但不排斥 IDE**：Vim 用于高频阅读与轻编辑，VS Code 负责重编辑与调试。
4. **面向 AI 工作流演进**：不仅有安装脚本，也开始沉淀 `AGENTS`/`TASK` 模板和 worktree 胶水脚本。

---

## 🚀 快速安装

在任何新的 Linux 服务器上，只需克隆本仓库并执行 `setup.sh`：

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
bash ~/dotfiles/setup.sh
```

**部署内容包括**：
- 安装和配置 `vim-plug` 及其核心微调插件
- 配置真彩色 VS Code 风格 (`vim-code-dark`)
- 无 Root 安装 `ripgrep` (极速全文搜索) 和 `glow` (终端 Markdown 渲染)
- 写入优化后的 `~/.tmux.conf`
- 安装 `vim-commentary`，支持 `gcc` / `gc` 系列注释操作
- 自动备份服务器上原有的 Vim 和 Tmux 配置

---

## 📚 仓库内容

当前仓库除了基础安装脚本，也开始包含面向 AI 工作流的方案和模板：

- `setup.sh`
  基础环境安装脚本。现在主要负责安装、备份和同步，不再承载大段配置正文。
- `config/vim/vimrc`
  仓库内维护的 Vim 配置
- `config/tmux/tmux.conf`
  仓库内维护的 tmux 配置
- `config/shell/cheat_alias.sh`
  `cheat` 速查命令定义
- `bin/`
  worktree 与 AI 工作流胶水脚本目录
- `AI_WORKFLOW_PROPOSAL.md`
  面向多设备、多服务器、AI agent 协作的系统方案文档
- `AGENTS_TEMPLATE.md`
  项目级 AI 规则模板
- `TASK_TEMPLATE.md`
  worktree 任务说明模板
- `wt-context.sh`
  打包当前 worktree 上下文的胶水脚本

如果你只是想快速部署终端环境，看 `setup.sh` 即可。  
如果你想进一步构建 AI-native 的个人工作流，建议从 `AI_WORKFLOW_PROPOSAL.md` 开始。
如果你要调整终端配置本身，应优先修改 `config/` 下的真实配置文件，而不是去改 `setup.sh` 中的脚本逻辑。

---

## 🤖 Worktree / AI 胶水脚本

安装后，`setup.sh` 会把仓库的 `bin/` 加入 PATH。当前已经提供：

- `wt-new <type> <name> [base_branch]`
  创建新分支、新 worktree，并自动初始化 `TASK.md`
- `task-init [target_file]`
  用模板初始化任务文件
- `task-handoff [-o output_file]`
  生成适合交接给其他 AI 或未来自己的任务摘要
- `wt-context`
  汇总当前 worktree 的任务、规则、diff 和目录结构

典型用法：

```bash
wt-new feature new-loss main
cd ../wt-feature-new-loss
wt-context
task-handoff -o HANDOFF.md
```

---

## 📖 快捷键与功能速查

在终端随时输入 `cheat` 命令即可唤出简易备忘录。以下是详细说明：

### 🖥️ Tmux (多窗口与分屏管理)

前缀键已从难按的 `Ctrl+b` 修改为 **`Ctrl+a`** (单手即可操作)。

| 快捷键 | 功能说明 | 适用场景 |
|---|---|---|
| `Ctrl+a` + `\|` | **左右竖分屏** | 一边开 AI 工具，一边看代码 |
| `Ctrl+a` + `-` | **上下横分屏** | 底部开个小窗看实时日志 |
| `Ctrl+a` + `h/j/k/l`| **切换光标面板** | Vim 风格的上下左右切换分屏 |
| `Ctrl+a` + `c` | **新建全屏窗口** | 新开一个工作区（默认保持当前目录） |
| `Ctrl+a` + `1~9` | **切换全屏窗口** | 在不同工作区（如代码区、日志区）切换 |
| `Ctrl+a` + `d` | **分离会话 (Detach)** | 关闭终端，程序在后台继续跑（训练必备）|
| `Ctrl+a` + `[` | **滚屏模式** | 查看很长的历史输出，用 `j/k` 上下滚，`q` 退出 |
| `Ctrl+a` + `r` | **重载配置** | 修改 `.tmux.conf` 后立即生效 |

> **多显示器工作流**：如果你有 3 个屏幕，不要在一个终端里分屏。应该打开 3 个独立的终端窗口，每个终端输入 `tmux new-session -t session_name`。这样 3 个终端连在同一个会话下，但每个窗口的分辨率独立适配各自的显示器！

---

### 📝 Vim (代码查看与微调)

抛弃沉重的配置，只保留微调最需要的神兵利器。

#### 1. 查找与跳转
| 快捷键 / 命令 | 功能 | 依赖插件 |
|---|---|---|
| `Ctrl+n` | 侧边栏开启/关闭**文件树**。按 `Enter` 打开文件，`m` 管理文件 | `nerdtree` |
| `Ctrl+p` | 弹窗**模糊搜索文件名** (类似 VS Code `Ctrl+P`) | `fzf.vim` |
| `Ctrl+f` | 弹窗**全局全文内容搜索** | `fzf.vim` + `ripgrep` |
| `gd` | 跳转到当前文件内该变量的**定义位置** | 原生 |
| `*` / `#` | 跳到上/下一个**同名变量**处 (相当于“查找引用”) | 原生 |
| `Ctrl+o` / `Ctrl+i` | 跳回/前进 (跳转定义后**返回上一处**) | 原生 |

#### 2. 编辑与修改
当前行显示**绝对行号**，上下行显示**相对行号**，极大地加速了块操作。

| 快捷键 | 功能 | 说明 |
|---|---|---|
| `5dd` | 向下删除 5 行 | 配合相对行号，不再数数 |
| `3yy` | 向下复制 3 行 | 按 `p` 粘贴 |
| `>>` / `<<` | 向右/左缩进当前行 | 配合 `V` 选中多行可批量缩进 (Python 必备) |
| `gcc` | **单行注释 / 取消注释** | `vim-commentary` 插件 |
| `gc3j` | **向下注释 3 行** | 配合相对行号极速注释 |
| `u` / `Ctrl+r`| 撤销 / 重做 | 输错了随时抢救 |
| `:%s/old/new/g` | 批量替换变量名 | 把当前文件所有 old 替换为 new |

---

### 🛠️ 独立终端工具

| 命令 | 功能 | 适用场景 |
|---|---|---|
| `glow README.md` | 带样式的 **Markdown 渲染** | 在终端直接看文档、表格、代码高亮 |
| `glow -p README.md`| 分页渲染 Markdown | 文档太长时使用，像 `less` 一样上下滚动 |
| `./wt-context.sh` | 导出当前 worktree 的任务、规则、diff 和目录摘要 | 切换 AI 工具、做任务交接、补上下文 |

---

## 🧩 下一步方向

这个仓库现在处于“基础环境可用，AI 工作流逐步产品化”的阶段。更完整的目标包括：

- 把 AI 配置从通用 dotfiles 中进一步拆层
- 增加 `wt-new`、`task-handoff` 等辅助脚本
- 提供 `AGENTS.md` / `TASK.md` 实际模板落地方式
- 逐步把多 agent / 多 worktree 工作流固化为可复用规范

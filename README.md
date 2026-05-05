# LaTeX Thesis Writing — 中文学位论文 LaTeX 模板 + Claude 写作辅助技能

通用中文学位论文 LaTeX 模板，配套 Claude Code 写作辅助技能，帮助你在
几分钟内搭建格式规范的毕业论文，专注于内容创作而非格式排版。

## 特性

- **开箱即用的模板**: 符合中国高校学位论文通用规范的完整 LaTeX 模板
- **格式自动检查**: PowerShell / Bash 双平台预检脚本，编译前检查编码、括号、引用
- **Git 工作流集成**: 预提交 hook 自动编译验证 + 引用完整性检查
- **Claude 技能辅助**: 配套 AI 写作技能，引导论文写作全流程
- **封面 + 声明 + 摘要 + 致谢**: 模板包含所有前置/后置页面
- **跨平台字体支持**: Windows / Linux / macOS 字体配置（见 `setup/`）
- **原生矢量绘图**: 内置 TikZ + PGFPlots + CircuiTikZ，流程图/架构图/数据图直接写代码生成，编译产出矢量 PDF
- **AI 主动配图**: Claude 写章节时按"触发词→图类型"对照表自动识图，写到"架构/流程/对比/趋势"等关键词时主动用模板样式画图，无需用户事后提醒
- **CI/CD 验证**: GitHub Actions 自动编译检查

## 快速开始

### 前置依赖

| 工具 | 说明 | 安装 |
|------|------|------|
| LaTeX 发行版 | 含 xelatex + biber | Windows: `winget install --id MiKTeX.MiKTeX -e`（轻量、按需下宏包）<br/>或 [TeX Live 官方安装包](https://tug.org/texlive/)（体积大但全套）<br/>macOS: [MacTeX](https://tug.org/mactex/) · Linux: `sudo apt install texlive-full` |
| VS Code（可选） | 编辑 + LaTeX Workshop 插件 | `winget install --id Microsoft.VisualStudioCode -e` |
| Git（可选） | 版本控制 | `winget install --id Git.Git -e` |
| PowerShell 5.1+/7+ | 运行预检脚本 | Windows 自带 |

> **完全没接触过 LaTeX？** 推荐先看 B 站教学视频
> [《LaTeX 入门》（BV1Yq66Y3EFq）](https://www.bilibili.com/video/BV1Yq66Y3EFq/)，
> 配合 [LaTeX 项目官网](https://www.latex-project.org/) 的 Getting Started 一起过一遍。
>
> **没装 LaTeX 也别慌**：直接跑 `pwsh tools/setup_env.ps1`，脚本会检测 xelatex / biber /
> 中文字体（SimSun、SimHei、FangSong、STZhongsong），缺什么报什么，并可一键 winget 装 MiKTeX。

### 一分钟上手

```bash
# 1. 克隆模板仓库
git clone https://github.com/your-org/latex-thesis-package.git
cd latex-thesis-package

# 2. 创建你的论文项目
cp -r thesis-template my-thesis && cd my-thesis

# 3. 修改封面信息
# 编辑 setup/titlepage.tex — 填入标题、姓名、学院等

# 4. 编译
make
# 或手动: xelatex thesis; biber thesis; xelatex thesis; xelatex thesis
```

打开生成的 `thesis.pdf`，封面页已就绪。

### 写论文

```bash
# 编辑前先运行格式检查
pwsh tools/check_thesis.ps1

# 各章对应文件:
#   chapters/01_introduction.tex  — 绪论
#   chapters/02_related_work.tex  — 相关工作
#   chapters/03_system_design.tex — 系统设计
#   chapters/04_method.tex        — 方法
#   chapters/05_experiment.tex    — 实验
#   chapters/06_conclusion.tex    — 总结
#   chapters/abstract.tex         — 中英文摘要
#   chapters/acknowledgement.tex  — 致谢

# 参考文献
#   编辑 refs.bib，在正文中用 \cite{key} 引用

# 提交前检查
git add -A
# pre-commit hook 自动运行编译 + 格式检查
git commit -m "完成第 3 章初稿"
```

## 项目结构

```
latex_thesis_package/
├── README.md                          # 本文件
├── LICENSE                            # MIT 许可证
├── CONTRIBUTING.md                    # 贡献指南
├── CHANGELOG.md                       # 版本历史
├── CODE_OF_CONDUCT.md                 # 行为准则
│
├── claude_skills/
│   └── latex_thesis_writing.md        # Claude Code 技能文档
│
├── thesis-template/                   # 可直接编译的模板项目
│   ├── thesis.tex                     # 主文件（编译入口）
│   ├── Makefile                       # 一键编译
│   ├── refs.bib                       # 参考文献数据库
│   ├── .gitignore
│   ├── .claude/
│   │   └── thesis_progress.md         # 论文进度记忆
│   ├── setup/
│   │   ├── package.tex                # 宏包引入
│   │   ├── format.tex                 # 格式设定（核心配置）
│   │   ├── command.tex                # 自定义命令/代码风格
│   │   └── titlepage.tex              # 封面 + 声明页
│   ├── chapters/
│   │   ├── abstract.tex               # 中英文摘要
│   │   ├── 01_introduction.tex        # 第 1 章
│   │   ├── 02_related_work.tex        # 第 2 章
│   │   ├── 03_system_design.tex       # 第 3 章
│   │   ├── 04_method.tex              # 第 4 章
│   │   ├── 05_experiment.tex          # 第 5 章
│   │   ├── 06_conclusion.tex          # 第 6 章
│   │   └── acknowledgement.tex        # 致谢
│   └── figures/
│
├── tools/
│   ├── check_thesis.ps1               # PowerShell 格式预检
│   ├── check_thesis.sh                # Bash 格式预检
│   └── setup_env.ps1                  # 一键部署脚本
│
├── docs/
│   ├── customization.md               # 学校格式适配指南
│   ├── font-setup.md                  # 字体配置指南
│   └── migration-guide.md             # 从 Word 迁移到 LaTeX
│
├── .githooks/
│   └── pre-commit                     # Git 预提交 hook
│
├── .github/
│   ├── workflows/
│   │   └── compile-check.yml          # CI：自动编译验证
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md
│       └── feature_request.md
│
└── .vscode/
    └── settings.json                  # VS Code + LaTeX Workshop 配置
```

## AI 主动配图

启用 [`claude_skills/latex_thesis_writing.md`](claude_skills/latex_thesis_writing.md)
后，Claude 写每一节正文时都会扫一遍内容，识别出"应该配图"的位置，
**主动**用模板里预设的 TikZ/PGFPlots 样式生成矢量图，无需用户提醒。

**触发词对照表**（节选，完整列表见技能文档 §9.0）：

| 文本里出现 | 自动配图类型 | 使用样式 |
|-----------|------------|---------|
| 系统由……构成 / 整体架构 / 模块组成 | TikZ 系统框图 | `block/module` `block/bus` |
| 流程 / 步骤 / 算法 / 判断 | TikZ 流程图 | `flow/start` `flow/proc` `flow/decide` |
| 对比 / 提升 N% / 不同 X 下的 Y | PGFPlots 折线/柱状图 | `thesis` 样式 |
| 随……变化 / 曲线 / 趋势 | PGFPlots 函数曲线 | `thesis` 样式 |
| 电路 / 信号链路 / 时序 | CircuiTikZ | — |

**执行链路**：扫文本 → 插 figure → 加 `\ref` 交叉引用 → 编译验证 → 回报"本节加了 N 张图"。

约束：必须复用 `setup/command.tex` 里已定义的样式，不得重新发明颜色/字号；
caption 不超过 20 字；标签前缀必须是 `fig:`；标签命名需反映内容（`fig:system_arch` 而非 `fig:1`）。

不想要时一句"先只写文字不画图"即可关闭本轮配图，Claude 会在交付时单独
列出建议补图位置。

## 格式规范

本模板遵循以下通用高校学位论文格式要求：

| 项目 | 参数 |
|------|------|
| 纸张 | A4 (21cm × 29.7cm) |
| 页边距 | 上 2.54cm / 下 2.54cm / 左 3.17cm / 右 3.17cm |
| 行距 | 1.5 倍 |
| 中文字体 | SimSun（宋体，正文）、SimHei（黑体，标题） |
| 英文字体 | Times New Roman |
| 正文字号 | 小四号 (12pt) |
| 章标题 | 黑体 小二号 (18pt) 居中 |
| 节标题 | 黑体 三号 (16pt) 左对齐 |
| 小节标题 | 黑体 四号 (14pt) 左对齐 |
| 图表编号 | 按章编号（图 3.1、表 4.2） |
| 页眉 | 居中「大学名字毕业设计（论文）」（五号） |
| 页脚 | 居中页码（五号） |

详细格式参数见 [docs/customization.md](docs/customization.md)。

## 适配你的学校

不同高校在页边距、封面格式、标题字体等方面有差异。本模板使用 `大学名字`
作为学校占位符，通过修改 `setup/` 下的配置文件适配具体学校。

**快速适配步骤：**

1. 修改 `setup/titlepage.tex` 中的「大学名字」为你的学校名
2. 如有特殊格式要求，调整 `setup/format.tex` 中的参数
3. 如需替换字体，参考 [docs/font-setup.md](docs/font-setup.md)

## 常见问题

### 编译报错 "Missing character" 或字体问题

Windows 大多自带 SimSun、SimHei，但**精简版 Win10/11 可能没有 STZhongsong / FangSong**
（这两个字体常随 Office 一起装）。先跑 `pwsh tools/setup_env.ps1`，脚本会列出系统里
缺哪些字体并给出对应方案。Linux/macOS 用户的开源字体替换方案详见
[docs/font-setup.md](docs/font-setup.md)。

### 参考文献样式不对

本模板默认使用 `style=numeric`。若想使用国标 GB/T 7714-2015 格式：

```bash
tlmgr install biblatex-gb7714-2015
# 然后修改 thesis.tex 中 biblatex 的 style 为 style=gb7714-2015
```

### check_thesis.ps1 报花括号未配对

如果在中文 Windows 上使用 PowerShell 5.1，请确保使用 `-Encoding UTF8` 参数
读取文件。脚本已内置该参数。若问题仍存在，检查 `.tex` 文件是否以 UTF-8 编码保存。

### 编译很慢怎么办

- 初稿阶段可以跳过参考文献编译：`xelatex thesis.tex`（一次即可）
- 最终定稿再跑完整链：`xelatex → biber → xelatex → xelatex`

## 版本策略

- **v1.x**: 单学校模板 + Claude 技能（当前）
- **v2.x**: 多学校适配库 + 跨平台字体自动检测
- 每年 3 月 / 9 月底发布大版本，与毕业季对齐

## 贡献

欢迎通过 Issue 和 PR 参与贡献！请先阅读 [CONTRIBUTING.md](CONTRIBUTING.md)。

贡献方向：
- 适配你的学校格式，提交配置参数
- 补充学科特定模板（工科、理科、文科）
- 提供 Linux/macOS 字体兼容方案
- 改进 check_thesis 脚本

## 许可证

MIT License — 详见 [LICENSE](LICENSE)。

## 学习资源

- [LaTeX 项目官网](https://www.latex-project.org/) — 官方文档、发行版下载
- [TeX Live](https://tug.org/texlive/) / [MiKTeX](https://miktex.org/) — 两大主流发行版
- [《LaTeX 入门》B 站教学视频](https://www.bilibili.com/video/BV1Yq66Y3EFq/) — 适合零基础
- [TeX Stack Exchange](https://tex.stackexchange.com/) — 排版问题救命稻草

## 相关项目

| 项目 | 说明 |
|------|------|
| [HUSTPaperTemp](https://github.com/skinaze/HUSTPaperTemp) | 华中科技大学毕业论文模板 |
| [ZJUTeX](https://github.com/skashefy/ZJUTeX) | 浙江大学毕业论文模板 |
| [SEUThesis](https://github.com/TJ-CSCCG/TJThesis-Latex) | 同济大学毕业论文模板 |

（各高校 LaTeX 模板百花齐放，本项目定位为*通用模板框架 + AI 写作辅助*，不替代各校官方模板。）

# LaTeX 论文写作技能文档

> 通用中文学位/学术论文 LaTeX 写作规范与工具链指南。覆盖项目初始化、内容规范、文献检索、AI 痕迹去除、TikZ 绘图、修改检查、定稿复盘的全流程。
>
> 参考资料：`references/bishe-guider/`（中文学术论文规范细则与脚本，源自 LSTM-Kirigaya/jinhui-skills）

---

## 〇、启动检查

启用本技能后，先检查工具链是否配齐，再读取论文进度记忆，决定加载哪些章节。

### 0.1 工具链检查

```powershell
# ---- 1. 检查 TeX Live ----
try {
    $ver = & xelatex --version 2>$null
    if ($ver -match "XeTeX") {
        Write-Host "[OK] TeX Live 已安装" -ForegroundColor Green
    }
} catch {
    Write-Host "[MISS] TeX Live 未安装" -ForegroundColor Red
    Write-Host "  → 下载安装: https://tug.org/texlive/"
    Write-Host "  或使用包管理器: winget install TeXLive"
}

# ---- 2. 检查 VS Code + LaTeX Workshop ----
$codePath = Get-Command code -ErrorAction SilentlyContinue
if ($codePath) {
    Write-Host "[OK] VS Code 已安装" -ForegroundColor Green
    $exts = & code --list-extensions 2>$null
    if ($exts -match "latex-workshop") {
        Write-Host "[OK] LaTeX Workshop 插件已安装" -ForegroundColor Green
    } else {
        Write-Host "[MISS] LaTeX Workshop 插件未安装" -ForegroundColor Yellow
        Write-Host "  → 运行: code --install-extension latex-workshop"
    }
} else {
    Write-Host "[MISS] VS Code 未安装" -ForegroundColor Red
    Write-Host "  → 下载安装: https://code.visualstudio.com/"
}

# ---- 3. 检查 Git ----
$gitPath = Get-Command git -ErrorAction SilentlyContinue
if ($gitPath) {
    Write-Host "[OK] Git 已安装" -ForegroundColor Green
} else {
    Write-Host "[MISS] Git 未安装" -ForegroundColor Red
    Write-Host "  → 下载安装: https://git-scm.com/"
}

# ---- 4. 检查 tools/check_thesis.ps1 存在 ----
if (Test-Path "tools/check_thesis.ps1") {
    Write-Host "[OK] 预检脚本存在" -ForegroundColor Green
} else {
    Write-Host "[INFO] 预检脚本未创建（可忽略，按需创建）" -ForegroundColor Cyan
}

# ---- 5. 检查论文主文件 ----
if (Test-Path "thesis.tex") {
    Write-Host "[OK] thesis.tex 存在" -ForegroundColor Green
} else {
    Write-Host "[INFO] thesis.tex 不存在（新项目需先执行 §一 初始化）" -ForegroundColor Cyan
}
```

**缺啥补啥：**

| 缺失项 | Windows 安装命令 |
|--------|-----------------|
| TeX Live | `winget install TeXLive` 或手动下载 `install-tl-windows.exe` |
| VS Code | `winget install Microsoft.VisualStudioCode` |
| LaTeX Workshop | `code --install-extension latex-workshop` |
| Git | `winget install Git.Git` |

### 0.2 读取进度记忆并决定加载哪些章节

参考 §十"论文进度记忆系统"。根据当前任务阶段：

| 任务阶段 | 必读章节 |
|---------|---------|
| 项目未初始化 | §一 项目初始化 |
| 撰写新章节 | §三 内容规范 + §五 去 AI 痕迹 + §六 TikZ 绘图 |
| 文献调研 | §四 文献检索与引用 |
| 章节修改 | §三 + §五 + §七 修改/审查检查 |
| 定稿前 | §八 定稿前全面复盘（含全部检查清单） |

---

## 一、项目初始化

**触发条件：**
- 用户表示"开始写论文"但当前目录没有标准结构
- 用户要求"初始化论文项目"
- 检测到缺少 `thesis.tex` 或 `chapters/` 等核心文件夹

**关键约束：在生成任何 LaTeX 骨架之前，必须先获取用户所在学校/学院的官方 LaTeX 模板。** 未找到模板就拒绝推进，要求用户提供：

> 未找到你所在学校/学院的 LaTeX 模板。请提供学校官方模板文件（`.tex` 或 `.zip`），或提供模板下载链接。在获取到正式模板之前，无法继续初始化项目，以免生成的结构与学校要求不符。

### 1.1 标准项目目录结构

```
{project-name}/
├── README.md                       # 项目说明（编译命令、目录说明）
├── thesis.tex                      # LaTeX 主文件
├── Makefile                        # 一键编译
├── setup/
│   ├── package.tex                 # 宏包引入
│   ├── format.tex                  # 格式设定（§十一.2）
│   └── command.tex                 # 自定义命令（§十一.3-4）
├── chapters/                       # 章节文件
│   ├── 01_introduction.tex
│   ├── 02_related_work.tex
│   ├── 03_system_design.tex
│   ├── 04_method.tex
│   ├── 05_experiment.tex
│   └── 06_conclusion.tex
├── figures/                        # 插图（PDF 优先）
│   ├── tikz/                       # TikZ 源码（每张图独立文件）
│   └── data/                       # PGFPlots 数据 CSV
├── refs.bib                        # 参考文献数据库
├── references/                     # 参考文献调研资料
│   ├── from-proposal/              # 开题阶段原始文献
│   ├── from-scholar/
│   │   ├── pdfs/                   # Google Scholar 下载 PDF
│   │   ├── bibtex/                 # 导出的 .bib 条目
│   │   └── notes/                  # 阅读笔记（Markdown）
│   └── extracted/                  # 从文献提取的图表/代码/数据
├── proposal/                       # 开题资料
│   ├── report/                     # 开题报告
│   ├── slides/                     # 开题 PPT
│   └── materials/                  # 辅助材料
├── example-theses/                 # 参考范文（可选）
├── experiments/                    # 实验
│   ├── code/                       # 实验代码
│   ├── data/                       # 实验数据
│   ├── results/                    # 输出（日志/权重/评估）
│   ├── design/                     # 实验设计图
│   ├── figures/                    # 实验生成图表
│   └── server-access.md            # 服务器登录信息
├── tools/
│   └── check_thesis.ps1            # PowerShell 格式预检脚本（§七.3）
├── scripts/                        # 工具脚本
│   ├── compile_tikz_to_png.sh
│   ├── extract_figures_from_pdf.py
│   └── init_project.sh
├── .claude/
│   └── thesis_progress.md          # 论文进度记忆（§十）
└── .githooks/
    └── pre-commit                  # 预提交检查（§七.4）
```

### 1.2 各目录详细说明

| 目录 | 用途 |
|------|------|
| `setup/` | 拆分 LaTeX 配置，便于版本控制和定位修改 |
| `chapters/` | 各章节独立 `.tex`，主文件用 `\input{}` 引入 |
| `figures/tikz/` | TikZ 源码，每张图独立文件，可 `\input` 复用 |
| `figures/data/` | PGFPlots 读取的 CSV 数据 |
| `references/from-scholar/notes/` | 文献阅读笔记，每篇文献一个 `.md` |
| `proposal/` | 开题阶段所有材料，用于核对研究方向是否偏离 |
| `experiments/server-access.md` | 实验室服务器 SSH 信息、conda 环境、数据/代码/结果路径 |

### 1.3 LaTeX 主文件骨架（`thesis.tex`）

```latex
% !TEX program = xelatex
\documentclass[
    a4paper,
    12pt,
    oneside,
    openany
]{book}

% ---------- 宏包 ----------
\usepackage{fontspec}
\usepackage{xeCJK}                    % 中日韩文字
\usepackage{geometry}
\usepackage{graphicx}
\usepackage{caption}
\usepackage{subcaption}
\usepackage{booktabs}
\usepackage{listings}
\usepackage{hyperref}
\usepackage{biblatex}
\addbibresource{refs.bib}

% ---------- 中文字体 ----------
\setCJKmainfont{SimSun}               % 宋体正文
\setCJKsansfont{SimHei}               % 黑体标题
\setCJKmonofont{FangSong}             % 仿宋代码

% ---------- 英文字体 ----------
\setmainfont{Times New Roman}
\setsansfont{Arial}
\setmonofont{Courier New}

% ---------- 页面设置 ----------
\geometry{
    a4paper,
    top=2.54cm,
    bottom=2.54cm,
    left=3.17cm,
    right=3.17cm
}

\input{setup/format}
\input{setup/command}

\begin{document}
\input{chapters/01_introduction}
\input{chapters/02_related_work}
\input{chapters/03_system_design}
\input{chapters/04_method}
\input{chapters/05_experiment}
\input{chapters/06_conclusion}
\printbibliography
\end{document}
```

### 1.4 章节文件模板

每个 `.tex` 章节文件的开头应包含"修改记录"注释块：

```latex
%===============================================================================
% 第 X 章 章节标题
% 修改记录:
%   2026-05-05  创建
%   2026-05-06  修改 2.3 节，补充 xxx
%===============================================================================

\chapter{系统设计}
\label{ch:system_design}
```

### 1.5 参考文献数据库（`refs.bib`）

```bibtex
@article{key2026,
    author  = {Author, A. and Author, B.},
    title   = {Paper Title},
    journal = {Journal Name},
    year    = {2026},
    volume  = {42},
    pages   = {1--10}
}

@inproceedings{key2025,
    author    = {Author, C.},
    title     = {Conference Paper},
    booktitle = {Proc. of IEEE XXX},
    year      = {2025},
    pages     = {100--105}
}

@manual{chip_ds,
    title        = {Device Reference Manual},
    organization = {Manufacturer},
    year         = {2023}
}
```

### 1.6 文献笔记模板（`references/from-scholar/notes/*.md`）

```markdown
# 文献标题

- **作者：**
- **期刊/会议：**
- **年份：**
- **链接/PDF：**
- **数据 CID：**

## 核心贡献

## 与本文的关系

## 可借鉴之处

## 关键图表
```

### 1.7 服务器访问信息模板（`experiments/server-access.md`）

```markdown
# 实验室服务器访问信息

## SSH 登录
\`\`\`bash
ssh username@server-address
\`\`\`

## 实验环境
- Python 版本：
- PyTorch 版本：
- CUDA 版本：
- Conda 环境：

## 常用路径
- 代码目录：
- 数据目录：
- 结果目录：

## 运行实验
\`\`\`bash
conda activate env-name
python train.py --config configs/exp1.yaml
\`\`\`

## 注意事项
- GPU 使用规范
- 数据备份策略
```

### 1.8 初始化脚本

参考脚本位于 `references/bishe-guider/rule-05-project-init/scripts/init_project.sh`，可作为生成上述结构的起点。

---

## 二、工具链与编译

### 2.1 LaTeX 发行版

| 工具 | 说明 |
|------|------|
| **TeX Live** | 完整发行版，支持 `xelatex`，含 `ctex` 宏包中文支持 |

**安装检查：**
```bash
xelatex --version
# 输出应含 "XeTeX 3.141592653-..." 即正常
```

### 2.2 编辑器（VS Code + LaTeX Workshop）

```json
{
    "latex-workshop.latex.tools": [
        {
            "name": "xelatex",
            "command": "xelatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "%DOC%"
            ]
        },
        {
            "name": "biber",
            "command": "biber",
            "args": ["%DOC%"]
        }
    ],
    "latex-workshop.latex.recipes": [
        {
            "name": "xelatex -> biber -> xelatex -> xelatex",
            "tools": [
                "xelatex",
                "biber",
                "xelatex",
                "xelatex"
            ]
        }
    ],
    "latex-workshop.view.pdf.viewer": "tab",
    "latex-workshop.latex.clean.fileTypes": [
        "*.aux", "*.log", "*.out", "*.bbl",
        "*.bcf", "*.blg", "*.run.xml",
        "*.synctex.gz", "*.toc", "*.lof", "*.lot"
    ]
}
```

### 2.3 版本控制

```bash
# .gitignore
*.aux *.log *.out *.bbl *.bcf *.blg *.run.xml *.synctex.gz *.toc *.lof *.lot *.pdf
```

### 2.4 编译命令

```bash
# 单次编译（用于检查错误）
xelatex -interaction=nonstopmode thesis.tex

# 完整编译（含参考文献）
xelatex thesis.tex
biber thesis
xelatex thesis.tex
xelatex thesis.tex

# 一键编译（Windows PowerShell）
& xelatex thesis.tex; & biber thesis; & xelatex thesis.tex; & xelatex thesis.tex
```

### 2.5 Makefile（推荐）

```makefile
TARGET = thesis
LATEX  = xelatex -interaction=nonstopmode -file-line-error
BIB    = biber

all: $(TARGET).pdf

$(TARGET).pdf: $(TARGET).tex
	$(LATEX) $(TARGET)
	$(BIB) $(TARGET)
	$(LATEX) $(TARGET)
	$(LATEX) $(TARGET)

clean:
	rm -f *.aux *.log *.out *.bbl *.bcf *.blg *.run.xml *.synctex.gz *.toc *.lof *.lot

.PHONY: all clean
```

### 2.6 本地备份

```bash
# 将论文目录打包备份到指定位置
tar -czf thesis_backup_$(date +%Y%m%d_%H%M).tar.gz thesis/

# 或使用 git 本地仓库（推荐，详见 §九）
git add -A
git commit -m "backup: 论文进度 YYYY-MM-DD"
```

---

## 三、论文内容规范

> **总体要求：** 结构严谨系统，理论依据充分，研究方案合理，数据资料翔实可靠，测试结果真实可靠，论述逻辑清晰，图表清楚，语言表达符合科学论文特点，引用合理。

### 3.1 评审标准对照

#### 3.1.1 教育部平台学位论文评阅标准

| 评议项目 | 评价要素 | 检查要点 |
|---------|---------|---------|
| **论文选题** | 选题的前沿性与开放性；研究的理论意义与现实意义；对国内外该选题以及相关领域发展现状的归纳和总结情况 | 选题是否聚焦、有意义；综述是否全面 |
| **文献综述** | 了解本领域及相关领域研究状态与进展，评述得当 | 文献是否全面、新颖；评述是否客观准确 |
| **创新性及论文价值** | 是否有新规律的发现；是否有新命题新方法的提出；对解决重要问题是否有作用 | 创新点是否明确；贡献是否具体 |
| **基础知识和科研能力** | 科学理论基础的坚实宽广程度；专门知识的系统深入程度；研究方法的科学性；引用资料的翔实性；作者独立从事科学研究的能力 | 基础是否扎实；方法是否科学 |
| **论文规范性** | 引文的规范性；学风的严谨性；结构的逻辑性；文字表述的准确性和流畅性 | 格式是否规范；逻辑是否清晰 |
| **研究内容与学科相关性** | 学位论文所研究的内容与学科的相关程度 | 内容是否与专业高度相关 |

#### 3.1.2 工程类硕士专业学位论文评阅标准

| 一级指标 | 主要评价要素 | 检查要点 |
|---------|-------------|---------|
| **选题** | 选题来源于工程实际，系所属专业领域的研究范畴；目的明确，具有必要性，具有应用前景 | 工程背景是否明确；应用价值是否突出 |
| **国内外研究现状分析** | 文献资料的全面性、新颖性、前瞻性，总结归纳的客观性、准确性、全面性 | 综述深度；分析透彻度 |
| **内容** | 对国内外发展趋势判断合理，研究资料与数据全面、可靠；研究思路清晰，方案设计可行；工作量饱满；具有一定难度 | 方案科学性；工作量充实度 |
| **成果** | 具有工程应用价值；可产生经济或社会效益；体现作者的新思路或新见解 | 应用价值；创新性 |
| **论文写作** | 表述简洁、规范；能够反映专题研究的核心内容和结果；具有较强的系统性与逻辑性；文字表达清晰，图表、公式规范；引用文献的真实性、相关性、规范性、时效性 | 写作规范；逻辑严谨 |
| **研究内容与专业类别的相关性** | 学位论文所研究的内容与专业类别的相关程度 | 相关度 |

### 3.2 第一章 绪论规范

#### 3.2.1 文献总结要求

| 优先级 | 要求 | 检查项 |
|--------|------|--------|
| P0 | 增加本研究领域的最新进展及重点难点 | 是否包含近 2-3 年重要文献 |
| P0 | 国内外研究现状介绍完后应进行一段小结 | 是否有"小结/总结"段落归纳研究进展 |
| P1 | 文献资料的全面性、新颖性、前瞻性 | 是否覆盖核心文献；是否有最新文献 |
| P1 | 总结归纳的客观性、准确性、全面性 | 评述是否中肯；是否存在偏颇 |

#### 3.2.2 科学问题凝练

| 优先级 | 要求 | 检查项 |
|--------|------|--------|
| P0 | 科学问题必须具体明确，切忌大而笼统 | 问题是否可用一句话精确定义 |
| P0 | 避免空泛表述 | 是否出现"如何提高数据驱动方法的性能"、"如何突破知识模型方法的瓶颈"等 |
| P1 | 科学问题应该可操作、可验证 | 问题是否有明确的验证方案 |

**错误示例：**
- ❌ "如何提高数据驱动方法的性能？"
- ❌ "如何突破知识模型方法的瓶颈？"

**正确示例：**
- ✅ "如何在有限标注数据条件下，提升医学问答系统的答案准确性？"
- ✅ "如何设计一种轻量级的反馈验证机制，在保证实时性的同时提高智能体的回答质量？"

#### 3.2.3 研究框架图

| 优先级 | 要求 | 检查项 |
|--------|------|--------|
| P0 | 必须包含本文研究内容/框架图 | 第一章是否插入研究框架图 |
| P0 | 展示如何组织研究内容（可标注发表文章） | 图中是否清晰展示各章关系 |
| P1 | 内容之间要有衔接，体现系统性、完整性 | 各章内容是否逻辑连贯 |

**注意：** 如果内容之间缺乏衔接，评审意见常为：
> "论文显得松散，未展示其理论深度和应用优势，也不足以体现论文的系统性、完整性。"

研究框架图请用 TikZ 绘制，参考 §六.3 系统框图模板。

### 3.3 章节结构规范

#### 3.3.1 每章小结

| 优先级 | 要求 | 检查项 |
|--------|------|--------|
| P0 | 每一章要有小结（包括不足之处） | 每章末尾是否有"本章小结" |
| P1 | 小结应概括本章核心贡献 | 小结是否提炼了本章核心内容 |

#### 3.3.2 最后一章 总结与展望

| 优先级 | 要求 | 检查项 |
|--------|------|--------|
| P0 | 明确写出本文的创新点 | 是否有独立的"创新点"段落 |
| P1 | 展望部分提出未来研究方向 | 是否指出 2-3 个有意义的研究方向 |

**创新点写作要求：**
- 创新点必须具体，不能空泛
- 每个创新点用 1-2 句话概括
- 创新点必须与论文内容一一对应

### 3.4 实验规范

#### 3.4.1 实验设置

| 优先级 | 要求 | 检查项 |
|--------|------|--------|
| P0 | 模型架构详细描述 | 是否说明层数、卷积核大小、批次大小、迭代次数等 |
| P0 | 训练过程细节 | 是否说明优化器、学习率调整策略、早停策略等 |
| P1 | 增强研究的可重现性 | 是否提供了足够的复现信息 |

**细节可放附录，但正文中必须提及：**
- 模型架构的层数、卷积核大小
- 训练的批次大小和迭代次数
- 优化器的选择
- 学习率调整策略
- 早停策略

#### 3.4.2 实验内容

| 优先级 | 要求 | 检查项 |
|--------|------|--------|
| P0 | 指标及其意义说明 | 是否解释了每个指标的含义 |
| P0 | 本模型的实验结果 | 是否有主实验结果表/图 |
| P0 | 与现有模型的对比 | 是否有对比实验；对比方法是否有介绍 |
| P1 | 消融实验 | 是否有模块消融和超参数分析 |
| P1 | 鲁棒性测试 | 是否有加噪声等鲁棒性验证 |

**对比实验要求：**
- 每个对比方法必须有一段简要介绍
- 对比必须公平（相同数据集、相同评价指标）
- 必须说明对比方法的来源（引用）

### 3.5 用词规范

| 优先级 | 要求 | 检查项 |
|--------|------|--------|
| P0 | 使用"本论文"、"本章"、"本节" | 是否用"本论文"而非"本研究"/"本文章" |
| P0 | 禁止使用"我们" | 是否出现"我们认为"等表述 |
| P0 | 中英文缩写首次出现时，需给出英文全称 | 首次出现是否给出全称 |
| P1 | "基于"后面应该是方法、理论、手段或工具 | 用法是否正确 |
| P1 | "面向"后面是研究场景 | 用法是否正确 |

**用词正误对照表：**

| 错误 | 正确 |
|------|------|
| 本研究 | 本论文 |
| 本文章 | 本论文 |
| 我们认为 | 本文认为 / 该研究表明 |
| 基于临床数据 | 基于临床数据**的分析方法** |
| 面向医生 | 面向**医生辅助诊断**场景 |

**缩写规范示例：**
- ✅ 大语言模型（Large Language Model, LLM），后续使用 LLM
- ❌ 直接使用 LLM 而未给出全称

### 3.6 语言与文献规范

| 优先级 | 要求 | 检查项 |
|--------|------|--------|
| P0 | 中文首行空两格 | 段落首行是否缩进 |
| P0 | 不能有拼写错误或错别字 | 全文拼写检查 |
| P0 | 语句必须通顺 | 朗读检查 |
| P1 | 语言表达符合科学论文特点 | 是否客观、严谨、准确 |
| P0 | 参考文献按学校规定格式 | 是否符合 GB/T 7714 或学校自定义格式 |
| P1 | 引用的真实性、相关性、规范性、时效性 | 引用是否真实存在；是否相关；格式是否规范 |

### 3.7 其他要求

| 优先级 | 要求 | 说明 |
|--------|------|------|
| P1 | 算法代码建议在附件中提供 | 为其他开发者提供支持 |
| P1 | 工程类论文建议与实际系统/软件融合 | 改进现有系统，为应用场景提供价值 |

---

## 四、文献检索与引用

> **核心原则：** 真实可溯源 · 时效性优先 · 权威性保障 · 相关性严格

### 4.1 检索流程

#### 4.1.1 步骤 1：明确检索需求

在检索前必须明确：
- 检索主题（中英文关键词）
- 时间范围（建议近 5 年）
- 文献类型（期刊/会议/综述）
- 所需数量（根据章节需求确定）

#### 4.1.2 步骤 2：使用 Google Scholar 检索

**基础检索语法**（用于 scholar.google.com 搜索栏）：

```
"medical question answering" "large language model"
```

**高级检索过滤条件：**

| 过滤条件 | URL 参数 | 示例 |
|---------|---------|------|
| 作者 | `as_sauthors` | `as_sauthors="Yoshua Bengio"` |
| 期刊/会议 | `as_publication` | `as_publication=Nature` |
| 起始年份 | `as_ylo` | `as_ylo=2020` |
| 结束年份 | `as_yhi` | `as_yhi=2025` |
| 精确短语 | `as_epq` | `as_epq="chain of thought"` |
| 标题检索 | `as_occt=title` | 仅搜索标题 |

示例需求："搜索 2020 年以后 Nature 上关于 medical AI 的论文" → 用上述参数组合构造 Scholar URL。

#### 4.1.3 步骤 3：结果筛选与评估

| 评估维度 | 优秀标准 | 可接受标准 | 排除标准 |
|---------|---------|-----------|---------|
| 相关性 | 与论述主题直接相关 | 间接相关但提供背景 | 明显无关 |
| 时效性 | 近 3 年内发表 | 近 5 年内发表 | 超过 10 年（非经典） |
| 权威性 | 顶刊/顶会（Q1/CCF-A） | 知名期刊/会议 | 预警期刊/掠夺性期刊 |
| 被引量 | 高被引（>100） | 中等被引（>10） | 零被引且发表多年 |
| 可获取性 | 开放获取或机构订阅 | 可通过 Sci-Hub 获取 | 完全无法获取 |

#### 4.1.4 步骤 4：引用追踪

**正向追踪（被引文献）：** 在 Scholar 搜索结果中点击 "Cited by N" 链接，查找引用某篇论文的后续研究，用于了解研究方向最新进展。

**反向追踪（参考文献）：** 阅读目标论文的参考文献列表，追溯经典工作和理论基础。

#### 4.1.5 步骤 5：导出与管理

导出 BibTeX 条目应包含：
- 完整的作者列表
- 准确的论文标题
- 期刊/会议名称（使用标准缩写）
- 发表年份
- 卷号、期号、页码
- DOI（如有）

存放路径：`references/from-scholar/bibtex/`，PDF 存 `references/from-scholar/pdfs/`，阅读笔记存 `references/from-scholar/notes/`（模板见 §1.6）。

最终合并到论文工程的 `refs.bib`。

### 4.2 引用规范

#### 4.2.1 引用格式

严格遵循学校规定的引用格式（GB/T 7714 或学校自定义格式）。

#### 4.2.2 引用原则

| 原则 | 说明 | 示例 |
|------|------|------|
| 首次出现 | 首次引用需给出完整信息 | Zhang 等 [1] 首次提出了…… |
| 避免堆砌 | 同一观点引用 1-2 篇即可 | 禁止"A 认为 [1]，B 认为 [2]，C 认为 [3]" |
| 原始文献 | 尽量引用原始文献而非综述 | 引用提出该方法的原始论文 |
| 平衡引用 | 兼顾国内外研究 | 不能只引用中文或只引用英文 |
| 时效分布 | 经典+近期结合 | 既有奠基性文献，也有最新进展 |

#### 4.2.3 常见引用错误

| 错误类型 | 错误示例 | 正确做法 |
|---------|---------|---------|
| 二次引用 | 某某指出 [1]（实际 [1] 是综述） | 追溯并引用原始文献 |
| 断章取义 | 只引用支持自己观点的部分 | 客观呈现文献观点 |
| 虚假引用 | 编造或篡改引用信息 | 所有引用必须可验证 |
| 过度自引 | 大量引用自己未发表的工作 | 自引比例不超过 10% |

### 4.3 文献综述写作规范

#### 4.3.1 综述结构

1. **按时间线梳理** — 展示领域发展历程
2. **按方法分类** — 对比不同技术路线
3. **指出现有不足** — 为本文研究定位
4. **小结段落** — 归纳目前该领域研究进展

#### 4.3.2 综述写作禁忌

| 禁忌 | 说明 |
|------|------|
| 简单罗列 | 不能只是"A 做了 X，B 做了 Y，C 做了 Z" |
| 缺乏评述 | 必须对现有工作进行分析和评价 |
| 忽略最新进展 | 必须包含近 2-3 年的重要工作 |
| 忽视反面工作 | 也要提及与本文观点不一致的研究 |

### 4.4 CAPTCHA 处理

Google Scholar 可能触发 CAPTCHA 验证：
1. 停止所有自动化操作
2. 提示用户在浏览器中完成人工验证
3. 等待用户确认后再继续
4. 切勿自动重试

---

## 五、写作风格：去 AI 痕迹

> **目标：** 将 AI 生成的刻板痕迹去除，使论文读起来像一位严谨的科研工作者亲笔所写。
>
> **5 条核心原则：** ① 识别 AI 模式；② 重写问题段落；③ 保留原意；④ 维持学术语体；⑤ 注入真实研究者的思考节奏。

### 5.1 AI 写作痕迹检测清单（24 项）

#### 一、内容模式

**1. 过度强调意义、legacy、宏观趋势**

警示词：标志着、见证了、承载着、凸显了、反映了更广泛的、象征着、为……奠定基础、开启了、塑造了、代表了……的转变、关键的转折点、不断演进的格局、留下了不可磨灭的印记

- ❌ 本研究的提出标志着医学智能体领域进入了一个新的发展阶段，为后续研究奠定了基础。
- ✅ 本研究聚焦于医学智能体的反馈验证问题，提出了一种新的迭代优化方法。

**2. 宣传性、广告式语言**

警示词：得天独厚的、vibrant、丰富的（比喻义）、深刻的、提升其、展示、体现、致力于、自然美景、坐落于、心脏地带、开创性的、享誉、breathtaking、必访、stunning

- ❌ 本系统凭借得天独厚的架构优势，展示了卓越的性能表现。
- ✅ 本系统在标准测试集上取得了 92.3% 的准确率，优于现有方法 4.7 个百分点。

**3. superficial -ing 分析**

警示词：凸显了……、确保了……、反映了……、象征着……、为……做出贡献、培养/促进……、涵盖……、展示……

- ❌ 实验结果表明该方法有效，凸显了其在医学诊断中的潜在应用价值。
- ✅ 实验结果表明该方法在医学诊断任务中的准确率达到 91.2%。

**4. 模糊归因与 weasel words**

警示词：行业报告指出、观察者认为、专家认为、一些批评者认为、多个来源（实际引用很少）

- ❌ 专家认为，该方向具有重要的研究价值。
- ✅ Wang 等 [1] 指出，该方向具有重要的研究价值。

**5. 套路化的"挑战与展望"段落**

警示词：尽管其……面临若干挑战……、尽管存在这些挑战……、挑战与遗产、未来展望

- ❌ 尽管该方法取得了一定成果，但仍面临计算复杂度高、数据依赖性强等挑战。展望未来，随着技术的不断进步，这些问题有望得到解决。
- ✅ 该方法的主要局限在于计算复杂度较高（单次推理耗时约 3.2 秒），且对标注数据的质量较为敏感。

#### 二、语言与语法模式

**6. AI 高频词汇**

高频 AI 词：此外、与……对齐、crucial、深入探讨、强调、持久的、增强、促进、garner、highlight（动词）、interplay、intricate、关键的、landscape、pivotal、展示、tapestry、testament、underscore、valuable、vibrant

- ❌ 此外，该方法通过复杂的 interplay 提升了系统的整体 performance landscape。
- ✅ 该方法通过协调多个子模块的交互关系，提升了系统整体性能。

**7. 系动词回避**

警示词：作为、标志着、代表着 [一个]、拥有/具备/提供 [一个]

- ❌ 本系统作为一个高效的医学问答平台，具备快速响应能力。
- ✅ 本系统是高效的医学问答平台，响应速度可达 200ms。

**8. 否定性平行结构**

问题："不仅……而且……"、"这不只是……，这是……" 等结构过度使用。

- ❌ 该模块不仅提升了准确率，而且增强了系统的鲁棒性。
- ✅ 该模块将准确率从 85% 提升至 91%，同时将噪声容忍度提高了 12%。

**9. 三一律过度使用**

问题：AI 喜欢把内容硬凑成三点，以显得全面。

- ❌ 本研究的主要贡献包括：提出了新模型、设计了新算法、验证了新假设。
- ✅ 本研究提出了基于反馈验证的医学智能体优化框架，并在三个标准数据集上验证了其有效性。

**10. 同义词循环（Elegant Variation）**

问题：AI 的重复惩罚机制导致过度替换同义词。

- ❌ 该方法具有高效性。该算法具备快速性。本方案拥有迅捷性。
- ✅ 该方法计算效率高，单次推理仅需 0.3 秒。

**11. 虚假范围**

问题："从 X 到 Y" 结构中 X 和 Y 不在同一有意义的尺度上。

- ❌ 本研究从理论分析到实际应用，从算法设计到系统实现，全面探索了医学智能体的优化路径。
- ✅ 本研究在理论分析的基础上，设计了优化算法并完成了系统实现。

#### 三、风格模式

**12. 破折号过度使用**

问题：AI 比人类更频繁使用 em dash（——），模仿"有力"的营销写作。

- ❌ 该方法——虽然简单——但效果显著——值得进一步研究。
- ✅ 该方法虽然简单，但效果显著，值得进一步研究。

**13. 粗体过度使用**

问题：AI 机械地给短语加粗。

- ❌ 本系统融合了 **Transformer 架构**、**注意力机制** 和 **预训练技术**。
- ✅ 本系统融合了 Transformer 架构、注意力机制和预训练技术。

**14. 行内标题式垂直列表**

问题：列表项以加粗标题加冒号开头。

- ❌
  - **准确率：** 系统在测试集上达到 95% 的准确率。
  - **效率：** 推理速度提升了 40%。
- ✅ 系统在测试集上的准确率达到 95%，推理速度提升了 40%。

**15. 标题大小写问题**

问题：AI 把英文标题中所有实词首字母大写。中文无此问题，但英文标题需注意。

**16. 表情符号**

**绝对禁止在学术论文中使用任何表情符号。**

#### 四、填充与模糊表达

**17. 填充短语**

| 问题表达 | 修改为 |
|---------|--------|
| 为了实现这一目标 | 为此 |
| 由于下雨这一事实 | 因为下雨 |
| 在此时刻 | 现在 |
| 如果你需要帮助的事件发生 | 如果你需要帮助 |
| 系统具有处理……的能力 | 系统可以处理…… |
| 值得注意的是，数据显示 | 数据显示 |
| 通过……的方式 | 通过…… |

**18. 过度模糊化**

- ❌ 该策略可能对结果产生一定影响。
- ✅ 该策略将 F1 分数提升了 2.3 个百分点（p < 0.05）。

**19. 套路化的正面结尾**

- ❌ 展望未来，该方法具有广阔的应用前景，必将为医学智能体的发展注入新的活力。
- ✅ 未来工作将探索该方法在多模态医学数据上的扩展。

### 5.2 中文学术论文专属检查项

| 检查项 | 问题示例 | 修改示例 |
|--------|---------|---------|
| "本研究"/"本文章"/"我们" | 本研究提出了一种方法 | 本论文提出了一种方法 |
| 夸张词汇 | 首次提出、显著提升、重大突破 | 提出了一种、提升了 X%、取得了进展 |
| 口语化表达 | 效果不错、很有意思 | 效果显著、具有理论价值 |
| 长句堆砌 | 一句话超过 50 字 | 拆分为 2-3 个短句 |
| 被动语态滥用 | 被用于、被认为 | 可用于、研究者认为 |
| 空泛修饰 | 非常、十分、极其 | 删除或改为具体数据 |

### 5.3 修改流程

1. 通读待审查文本
2. 标记所有符合上述模式的表达
3. 逐句重写，保留核心语义
4. 检查修改后的文本：
   - 朗读是否自然
   - 句式是否有变化
   - 是否用具体数据替代模糊声称
   - 是否符合学术语体
5. 输出修改建议表格（见 §5.4）

### 5.4 审查结果输出表格

**所有形式的错误、警告、提示，最终都必须以表格形式返回。**

| 检查项 | 位置/上下文 | 严重级别 | 问题描述 | 修改建议 | 状态 |
|--------|-----------|---------|---------|---------|------|
| 夸张词汇 | 第 1 章第 3 段 | 错误 | 出现"首次提出" | 改为"提出了一种" | 待修改 |
| 人称使用 | 第 2 章第 5 段 | 错误 | 出现"我们认为" | 改为"本文认为" | 待修改 |
| 图表大小 | 图 4-1 | 警告 | 图中文字偏小 | 调整字号至 ≥8pt | 待修改 |
| 公式标点 | 式 (3.2) | 错误 | 公式后缺少标点 | 添加逗号 | 待修改 |
| 颜色一致性 | 图 5-2 | 警告 | 与整体画风差异较大 | 调整配色方案 | 待修改 |

**严重级别定义：**

| 级别 | 含义 | 处理方式 |
|------|------|---------|
| **错误（P0）** | 违反硬性规范，必须修改 | 不修改无法通过评审 |
| **警告（P1）** | 影响论文质量，建议修改 | 修改后提升论文水平 |
| **提示（P2）** | 优化建议，可酌情处理 | 时间允许时改进 |

**状态定义：**

| 状态 | 含义 |
|------|------|
| 待修改 | 发现问题，等待用户修改 |
| 已修改 | 用户已修改，建议复查 |
| 通过 | 检查项无问题 |
| 不适用 | 该检查项与当前内容无关 |

---

## 六、LaTeX 原生绘图

模板已加载 `tikz` + `pgfplots` + `circuitikz`，所有图都可以**用文本写出来**，编译产出矢量 PDF，永不糊。优先级：

```
原生绘图（TikZ/PGFPlots） > 矢量 PDF（Inkscape/Visio 导出） > PNG/JPG 位图
```

写论文时**首选 TikZ/PGFPlots**：可 diff、可改色改字号、缩放无损、与正文字体一致。

### 6.0 写作守则：主动配图（不要等用户提醒）

**这是行为约束，不是建议。** 每次写或修改任意章节时，先扫一遍内容，识别"应该有图"的位置，然后**主动画图，不要等用户开口要**。

**触发关键词→对应图表类型**对照表：

| 文本里出现这类词 | 必须配图（用模板里的样式） |
|---|---|
| "系统由……构成"、"整体架构"、"模块组成"、"层次结构" | TikZ 系统框图（`block/module` `block/bus`） |
| "流程"、"步骤"、"算法"、"先……再……"、"判断" | TikZ 流程图（`flow/start` `flow/proc` `flow/decide`） |
| "对比"、"提升 N%"、"不同 X 下的 Y"、"实验结果" | PGFPlots 折线/柱状图（`thesis` 样式） |
| "随……变化"、"曲线"、"趋势"、"函数关系" | PGFPlots 折线图或函数曲线 |
| "电路"、"信号链路"、"时序" | CircuiTikZ |
| "状态转移"、"协议交互" | TikZ 状态图 / 时序图 |
| "数据格式"、"报文结构"、"内存布局" | TikZ 矩阵 / `matrix` 库 |

**执行流程**（每写一节都跑一遍）：

```
[写完一节正文]
    │
    ├─ 1. 扫描刚写的内容，找触发关键词
    │      ├─ 命中 → 进入第 2 步
    │      └─ 未命中 → 跳过本节配图
    │
    ├─ 2. 在合适位置插入 \begin{figure} ... \end{figure}
    │      ├─ 优先用 §6.2-6.6 的模板（不要重新发明轮子）
    │      ├─ 标签前缀必须是 fig:，命名能反映内容（fig:system_arch 而非 fig:1）
    │      └─ caption 写完整中文短句，不超过 20 字
    │
    ├─ 3. 在正文里加交叉引用：「如图~\ref{fig:xxx}所示」
    │      └─ 注意是 `~` 不是空格，避免标号前换行
    │
    ├─ 4. 编译验证图能画出来（无报错 + 标签解析）
    │      └─ xelatex 跑两遍，第二遍 \ref 才能解析
    │
    └─ 5. 告诉用户："本节已配图 X 张，分别是 ……"
```

**反模式（必须避免）：**

- ❌ 写完整章正文却一张图都没有，让用户事后说"加张图吧"
- ❌ 在该用 TikZ 流程图的地方，让用户用 Visio 画完截图导入
- ❌ 用占位文字"（此处应有架构图）"代替真实绘图代码
- ❌ 自己重新写 `\tikzset{...}` 定义颜色/字号，而不是用模板里已有的 `flow/*` `block/*` `thesis` 样式
- ❌ 一个 `figure` 环境里塞 5 个不相干的图，应该拆成 5 个独立图或用 `subcaption`

**用户明确说"先不画图，只写文字"时**：跳过本守则，但在交付时提醒一句"以下位置建议后续配图：……"，列出触发点。

### 6.1 何时用哪种工具

| 场景 | 工具 | 文件位置 |
|------|------|---------|
| 流程图 / 算法流程 | TikZ + `flow/*` 样式 | 直接写在章节 `.tex` 里 |
| 系统架构图 / 模块框图 | TikZ + `block/*` 样式 | 同上 |
| 数据折线图 / 柱状图 / 散点图 | PGFPlots（读 csv） | csv 放 `figures/data/`，图代码内联 |
| 数学函数曲线 | PGFPlots `\addplot {expr}` | 同上 |
| 电路原理图 | CircuiTikZ | 内联 |
| 复杂示意图（含照片） | Inkscape 画完导出 PDF | `figures/*.pdf` |

**长图建议拆分到独立文件**，避免章节文件臃肿：
```
figures/
├── tikz/
│   ├── system_arch.tex      % \input{figures/tikz/system_arch}
│   └── flow_main.tex
└── data/
    └── exp_results.csv
```

### 6.2 流程图模板

```latex
\begin{figure}[htbp]
    \centering
    \begin{tikzpicture}[node distance=1.2cm and 1.6cm]
        \node[flow/start]                       (start)  {开始};
        \node[flow/proc, below=of start]        (init)   {初始化参数};
        \node[flow/decide, below=of init]       (cond)   {满足条件?};
        \node[flow/proc, below=of cond, yshift=-0.3cm] (calc) {执行计算};
        \node[flow/start, below=of calc]        (end)    {结束};

        \draw[flow/arrow] (start) -- (init);
        \draw[flow/arrow] (init)  -- (cond);
        \draw[flow/arrow] (cond)  -- node[right] {是} (calc);
        \draw[flow/arrow] (calc)  -- (end);
        \draw[flow/arrow] (cond.east) -- ++(1.5,0) |- node[near start, right] {否} (end.east);
    \end{tikzpicture}
    \caption{算法主流程}
    \label{fig:flow_main}
\end{figure}
```

### 6.3 系统框图模板

```latex
\begin{figure}[htbp]
    \centering
    \begin{tikzpicture}[node distance=0.8cm and 1.2cm]
        \node[block/module]                            (sensor) {传感器};
        \node[block/module, right=of sensor]           (adc)    {ADC};
        \node[block/module, right=of adc]              (mcu)    {MCU\\ 处理};
        \node[block/module, right=of mcu]              (out)    {输出};
        \node[block/bus, below=1cm of adc.south, xshift=2cm] (bus) {数据总线};

        \draw[block/signal] (sensor) -- (adc);
        \draw[block/signal] (adc)    -- (mcu);
        \draw[block/signal] (mcu)    -- (out);
        \draw[block/signal] (adc.south) -- (adc.south |- bus.north);
        \draw[block/signal] (mcu.south) -- (mcu.south |- bus.north);
    \end{tikzpicture}
    \caption{系统总体架构}
    \label{fig:system_arch}
\end{figure}
```

### 6.4 折线图（PGFPlots 读 CSV）

把实验数据存为 `figures/data/exp.csv`：

```
x,methodA,methodB
1,0.62,0.55
2,0.71,0.60
4,0.83,0.68
8,0.90,0.74
16,0.94,0.78
```

正文中：

```latex
\begin{figure}[htbp]
    \centering
    \begin{tikzpicture}
        \begin{axis}[thesis,
            xlabel={批大小 $N$}, ylabel={准确率},
            xmode=log, log basis x=2,
            legend pos=south east]
            \addplot table[x=x, y=methodA, col sep=comma] {figures/data/exp.csv};
            \addlegendentry{本文方法}
            \addplot table[x=x, y=methodB, col sep=comma] {figures/data/exp.csv};
            \addlegendentry{对比方法}
        \end{axis}
    \end{tikzpicture}
    \caption{不同批大小下的准确率对比}
    \label{fig:exp_acc}
\end{figure}
```

数据更新只改 csv，图自动重绘。

### 6.5 柱状图

```latex
\begin{tikzpicture}
    \begin{axis}[thesis,
        ybar, bar width=14pt,
        symbolic x coords={方案A, 方案B, 方案C, 本文},
        xtick=data, ymin=0,
        ylabel={延迟 (ms)},
        nodes near coords, nodes near coords style={font=\footnotesize}]
        \addplot coordinates {(方案A,120) (方案B,95) (方案C,110) (本文,68)};
    \end{axis}
\end{tikzpicture}
```

### 6.6 数学函数曲线

```latex
\begin{tikzpicture}
    \begin{axis}[thesis, xlabel={$x$}, ylabel={$y$},
                 domain=-3:3, samples=100, legend pos=north west]
        \addplot {sin(deg(x))};      \addlegendentry{$\sin x$}
        \addplot {x^2/9 - 1};        \addlegendentry{$x^2/9 - 1$}
    \end{axis}
\end{tikzpicture}
```

### 6.7 把 TikZ 图独立成文件

`figures/tikz/system_arch.tex`：

```latex
\begin{tikzpicture}[node distance=0.8cm and 1.2cm]
    % ... 节点和连线 ...
\end{tikzpicture}
```

正文引用：

```latex
\begin{figure}[htbp]
    \centering
    \input{figures/tikz/system_arch}
    \caption{系统总体架构}
    \label{fig:system_arch}
\end{figure}
```

### 6.8 加速编译：externalize

TikZ 图多了编译会变慢。`thesis.tex` 序言加：

```latex
\usetikzlibrary{external}
\tikzexternalize[prefix=figures/tikz/cache/]
```

首次编译每张图独立生成 PDF 并缓存，之后只重编修改过的。注意：使用前需在 `thesis.tex` 编译命令加 `-shell-escape`：

```bash
xelatex -shell-escape thesis.tex
```

### 6.9 绘图调试技巧

| 问题 | 排查 |
|------|------|
| 节点叠在一起 | `node distance=1.2cm and 1.6cm` 调间距（垂直 and 水平） |
| 连线穿过节点 | 改用 `|-` `-|` 折线，或用 `to[bend left=30]` |
| 中文不显示 | 确保用 xelatex 编译；TikZ 内中文照常写即可 |
| PGFPlots 报 compat | `\pgfplotsset{compat=1.18}` 已设；老版本 TeX Live 改成 `1.16` |
| 图过大超出页面 | `\resizebox{0.9\linewidth}{!}{...}` 包一层，或调 `width=` 参数 |
| externalize 后改了图没生效 | 删 `figures/tikz/cache/` 重编 |

### 6.10 让 Claude 帮你画图

让 Claude 生成 TikZ 时，提供这三样：

1. **目标**："画一个三层神经网络的示意图，输入 4 节点、隐藏 5 节点、输出 2 节点"
2. **风格**："用模板里的 `block/module` 样式" 或 "纯黑白线条"
3. **数据**（PGFPlots 才需要）：csv 路径或粘贴几行数据

Claude 应优先使用模板里已定义的 `flow/*`、`block/*`、`thesis` 样式，不要重新定义颜色和字号。

---

## 七、修改/审查检查

每次对论文 `.tex` 文件做实质性修改前，必须执行以下检查。

### 7.1 编译检查清单

```bash
# 1. 检查 LaTeX 语法错误
xelatex -interaction=nonstopmode thesis.tex 2>&1 | grep -E "^!|Error|Warning"

# 2. 检查未定义引用
grep -c "??" thesis.aux        # 应为 0

# 3. 检查过满/过宽盒子
grep -E "Overfull|Underfull" thesis.log
```

### 7.2 格式约束检查

| 检查项 | 规则 | 手动检查命令 |
|--------|------|-------------|
| 章节编号连续 | 不应跳过编号 | `grep -rE "\\\\chapter\{|\\\\section\{" chapters/` |
| 图表有 caption | 每幅图/表必含 `\caption{}` | 目视检查是否有图无标题 |
| 引用非空 | 无 `\cite{}` `\ref{}` 空括号 | `grep -rE "\\\\cite\{\s*\}|\\\\ref\{\s*\}" chapters/` |
| 中英文混排间距 | 中文与英文/数字间应有半角空格 | 目视检查 |

### 7.3 PowerShell 文档预检脚本（读取/编译前检查）

每次打开 `.tex` 文件进行修改前，先运行此脚本检查格式正确性。

创建 `tools/check_thesis.ps1`：

```powershell
<#
.SYNOPSIS
    LaTeX 论文格式预检脚本（PowerShell）
    在读取/编辑 .tex 文件前运行，确保文档格式正确。
.DESCRIPTION
    检查项：
      1. 文件编码（必须是 UTF-8）
      2. 花括号 {} 配对
      3. \begin{} / \end{} 环境配对
      4. 非法控制字符（退格符等）
      5. \label / \ref / \cite 格式规范
      6. 图表 caption 完整性
      7. 章节编号连续性
      8. 中英文混排间距检查
      9. 命令拼写白名单
.PARAMETER Path
    要检查的 .tex 文件或目录路径。默认递归扫描 ./chapters 和 thesis.tex。
.PARAMETER Fix
    开关。指定后自动修复部分可修复问题（如编码 BOM）。
.EXAMPLE
    .\tools\check_thesis.ps1
    .\tools\check_thesis.ps1 -Path .\chapters\03_method.tex
    .\tools\check_thesis.ps1 -Fix
#>

param(
    [string]$Path = ".",
    [switch]$Fix
)

# ---------- 辅助函数 ----------
$ErrorCount = 0
$WarnCount  = 0

function Write-ErrorMsg($file, $msg) {
    $ErrorCount++
    Write-Host "[FAIL] ${file}: $msg" -ForegroundColor Red
}
function Write-WarningMsg($file, $msg) {
    $WarnCount++
    Write-Host "[WARN] ${file}: $msg" -ForegroundColor Yellow
}
function Write-Pass($msg) {
    Write-Host "[PASS] $msg" -ForegroundColor Green
}

# ---------- 收集待查文件 ----------
$Files = @()
if (Test-Path -Path $Path -PathType Container) {
    $Files += Get-ChildItem -Path $Path -Filter "*.tex" -Recurse -File
    if (Test-Path "thesis.tex") { $Files += Get-Item "thesis.tex" }
} else {
    $Files += Get-Item $Path
}
$Files = $Files | Where-Object { $_.Extension -eq ".tex" -and $_.Name -notmatch "^_" } | Sort-Object FullName -Unique

if ($Files.Count -eq 0) {
    Write-Host "[SKIP] 未找到 .tex 文件." -ForegroundColor Cyan
    exit 0
}

Write-Host "`n========== LaTeX 格式预检 ==========" -ForegroundColor Cyan
Write-Host "文件数: $($Files.Count)`n" -ForegroundColor Cyan

# ---------- 逐文件检查 ----------
foreach ($File in $Files) {
    $RelPath = $File.FullName
    $Content = Get-Content -Path $File.FullName -Raw -ErrorAction SilentlyContinue

    if (-not $Content) {
        Write-ErrorMsg $RelPath "无法读取文件"
        continue
    }

    # ---- 1. 编码检查 ----
    try {
        $bytes = [System.IO.File]::ReadAllBytes($File.FullName)
        if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            Write-WarningMsg $RelPath "UTF-8 BOM 存在（不影响编译，但 git diff 会显示 ^M）"
            if ($Fix) {
                $trimmed = [System.Text.Encoding]::UTF8.GetString($bytes[3..($bytes.Length-1)])
                [System.IO.File]::WriteAllText($File.FullName, $trimmed, [System.Text.Encoding]::UTF8)
                Write-Pass "已移除 BOM"
            }
        } else {
            $isUtf8 = $true
            try {
                [System.Text.Encoding]::UTF8.GetString($bytes) | Out-Null
            } catch {
                $isUtf8 = $false
            }
            if (-not $isUtf8) {
                Write-ErrorMsg $RelPath "非 UTF-8 编码（可能为 GBK/ANSI），编译会乱码"
            }
        }
    } catch {
        Write-WarningMsg $RelPath "无法读取二进制编码: $_"
    }

    # ---- 2. 花括号 {} 配对检查 ----
    $openBraces = 0
    $inComment = $false
    for ($i = 0; $i -lt $Content.Length; $i++) {
        $ch = $Content[$i]
        if ($ch -eq '%') { $inComment = $true; continue }
        if ($inComment -and $ch -eq "`n") { $inComment = $false; continue }
        if ($inComment) { continue }
        if ($ch -eq '{') { $openBraces++ }
        elseif ($ch -eq '}') { $openBraces-- }
    }
    if ($openBraces -ne 0) {
        Write-ErrorMsg $RelPath "花括号未配对: 多出 $openBraces 个 }（或缺少 $(-$openBraces) 个 }）"
    }

    # ---- 3. \begin{} / \end{} 环境配对 ----
    $envStack = @()
    $envMatches = [Regex]::Matches($Content, '\\(begin|end)\{(\w+)\}')
    foreach ($m in $envMatches) {
        $keyword = $m.Groups[1].Value
        $envName = $m.Groups[2].Value
        if ($keyword -eq "begin") {
            $envStack += $envName
        } else {
            if ($envStack.Count -eq 0) {
                Write-ErrorMsg $RelPath "多余的 \end{$envName}（无对应 \begin）"
            } else {
                $last = $envStack[-1]
                if ($last -ne $envName) {
                    Write-ErrorMsg $RelPath "环境嵌套错误: \begin{$last} 被 \end{$envName} 关闭"
                }
                $envStack = $envStack[0..($envStack.Count-2)]
            }
        }
    }
    if ($envStack.Count -gt 0) {
        Write-ErrorMsg $RelPath "环境未关闭: $($envStack -join ', ')"
    }

    # ---- 4. 非法控制字符 ----
    $illegal = @()
    for ($i = 0; $i -lt $Content.Length; $i++) {
        $ch = $Content[$i]
        if ($ch -ge "`x00" -and $ch -le "`x08" -and $ch -ne "`n" -and $ch -ne "`r" -and $ch -ne "`t") {
            $illegal += "0x$([int]$ch.ToString('X2'))"
        }
    }
    if ($illegal.Count -gt 0) {
        Write-ErrorMsg $RelPath "包含非法控制字符: $($illegal -join ' ')"
    }

    # ---- 5. 标签格式检查 ----
    $labels = [Regex]::Matches($Content, '\\label\{([^}]+)\}')
    foreach ($lbl in $labels) {
        $name = $lbl.Groups[1].Value
        if ($name -notmatch '^(eq|fig|tab|ch|sec|lst|alg):') {
            Write-WarningMsg $RelPath "label 格式不规范（缺少 eq:/fig:/tab:/ch:/sec: 前缀）: $name"
        }
        $refCount = [Regex]::Matches($Content, "\\ref\{$name\}").Count
        if ($refCount -eq 0) {
            Write-WarningMsg $RelPath "label 已定义但从未引用: $name"
        }
    }

    # ---- 6. 空引用/空标签 ----
    $emptyCite = [Regex]::Matches($Content, '\\cite\{\s*\}')
    if ($emptyCite.Count -gt 0) {
        Write-ErrorMsg $RelPath "存在空 \cite{}: $($emptyCite.Count) 处"
    }
    $emptyRef = [Regex]::Matches($Content, '\\ref\{\s*\}')
    if ($emptyRef.Count -gt 0) {
        Write-ErrorMsg $RelPath "存在空 \ref{}: $($emptyRef.Count) 处"
    }

    # ---- 7. 检查是否有 \includegraphics 但无 \caption ----
    $figCount = [Regex]::Matches($Content, '\\includegraphics').Count
    $capCount = [Regex]::Matches($Content, '\\caption').Count
    if ($figCount -gt 0 -and $capCount -eq 0) {
        Write-WarningMsg $RelPath "存在 \includegraphics 但无 \caption"
    }
}

# ---------- 全局检查 ----------
Write-Host "`n========== 全局检查 ==========" -ForegroundColor Cyan

if (Test-Path "thesis.tex") {
    $MainContent = Get-Content "thesis.tex" -Raw

    # ---- 检查所有 \ref 都有对应 \label ----
    $allRefs = [Regex]::Matches($MainContent, '\\ref\{([^}]+)\}')
    $allLabels = [Regex]::Matches($MainContent, '\\label\{([^}]+)\}')
    $labelSet = @{}
    foreach ($l in $allLabels) { $labelSet[$l.Groups[1].Value] = $true }

    foreach ($r in $allRefs) {
        $refName = $r.Groups[1].Value
        if (-not $labelSet.ContainsKey($refName)) {
            $found = $false
            foreach ($File in $Files) {
                $subContent = Get-Content -Path $File.FullName -Raw -ErrorAction SilentlyContinue
                if ($subContent -match "\\label\{$refName\}") {
                    $found = $true
                    break
                }
            }
            if (-not $found) {
                Write-WarningMsg "thesis.tex" "\ref{$refName} 无对应 \label（可能在其他文件中）"
            }
        }
    }

    # ---- 检查章节编号 ----
    $chapters = [Regex]::Matches($MainContent, '\\chapter\{')
    Write-Pass "主文件包含 $($chapters.Count) 个 \chapter{}"

    # ---- 检查是否缺少 \end{document} ----
    if ($MainContent -notmatch '\\end\{document\}') {
        Write-ErrorMsg "thesis.tex" "缺少 \end{document}"
    }
} else {
    Write-WarningMsg "" "未找到 thesis.tex，跳过全局检查"
}

# ---------- 汇总 ----------
Write-Host "`n========== 检查汇总 ==========" -ForegroundColor Cyan
if ($ErrorCount -eq 0 -and $WarnCount -eq 0) {
    Write-Pass "全部通过，格式正确，可以开始修改"
} else {
    Write-Host "错误: $ErrorCount    警告: $WarnCount" -ForegroundColor $(
        if ($ErrorCount -gt 0) { "Red" } else { "Yellow" }
    )
    if ($ErrorCount -gt 0) {
        Write-Host "存在 $ErrorCount 个错误，请修复后再读取/编译" -ForegroundColor Red
        exit 1
    }
}
```

**用法：**

```powershell
# 全文检查
.\tools\check_thesis.ps1

# 检查指定文件
.\tools\check_thesis.ps1 -Path .\chapters\03_method.tex

# 检查并自动修复可修复项（如 BOM）
.\tools\check_thesis.ps1 -Fix
```

### 7.4 Git 预提交检查脚本

创建 `.githooks/pre-commit`：

```bash
#!/bin/bash
# 预提交检查：论文文件编译 + 引用完整性

ERRORS=0

CHANGED=$(git diff --cached --name-only --diff-filter=ACM | grep '\.tex$')

if [ -z "$CHANGED" ]; then
    exit 0
fi

# 运行 PowerShell 预检
if command -v pwsh &> /dev/null; then
    pwsh -NoProfile tools/check_thesis.ps1 -Path "$CHANGED"
    if [ $? -ne 0 ]; then
        echo "[FAIL] 格式预检未通过"
        ERRORS=$((ERRORS+1))
    fi
fi

# 编译检查
echo "=== 编译检查 ==="
xelatex -interaction=nonstopmode thesis.tex > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "[FAIL] xelatex 编译失败"
    ERRORS=$((ERRORS+1))
else
    echo "[PASS] 编译通过"
fi

# 检查未定义引用
echo "=== 引用检查 ==="
UNDEF=$(grep -c "??" thesis.aux 2>/dev/null)
if [ "$UNDEF" -gt 0 ]; then
    echo "[FAIL] 存在 $UNDEF 个未定义引用"
    ERRORS=$((ERRORS+1))
else
    echo "[PASS] 引用完整"
fi

# 检查过满盒子
echo "=== 版式检查 ==="
OVERFULL=$(grep -c "Overfull" thesis.log 2>/dev/null)
echo "[WARN] Overfull hbox 数量: $OVERFULL"

if [ $ERRORS -gt 0 ]; then
    echo "=== $ERRORS 个错误，禁止提交 ==="
    exit 1
fi
echo "=== 检查通过 ==="
```

安装 hook：
```bash
mv .githooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### 7.5 排版检查（每次修改后执行）

每次修改完成、提交前，打开生成的 PDF 逐页检查以下项目：

#### 7.5.1 大面积空白检查

```powershell
# 检查 log 中的页溢出警告（通常意味着内容被推到下一页）
Select-String -Path thesis.log -Pattern "Overfull"
# 若输出行含 \vskip 或 \vspace 相关，说明页面存在不合理空白
```

手动操作：逐页翻阅 PDF，寻找连续半页以上的空白区域。常见诱因及修复：

| 现象 | 原因 | 修复 |
|------|------|------|
| 页末大片空白 | `\newpage` 或 `\clearpage` 硬分页 | 改为 `\pagebreak` 或删掉 |
| 图表前后空白 | `[h]` 浮动约束导致无合适位置 | 改用 `[htbp]`，或调整图表前后文字量 |
| 公式独占一页上端 | 公式前 `\par` 过大间距 | 减少前文段落间距或用 `\vspace{-...}` |
| 节标题在页末 | 分页不佳 | 在标题前加 `\newpage` 或调整文本 |

#### 7.5.2 图片位置检查

检查点：
- **图是否跑到了不该在的章节**（例如"实验"的图跑到了"结论"页）
- **图是否隔断正文**：图插入后，图上剩两三行、图下剩两三行，正文被截断
- **图是否大面积覆盖文字**（多栏排版常见）

修复方案：

```latex
% 强制图片在当前位置（慎用，可能产生更差效果）
\usepackage{float}
\begin{figure}[H]  ... \end{figure}

% 允许图片浮动到下一页顶部（推荐）
\begin{figure}[tbp]

% 调整图片大小让页面更紧凑
\includegraphics[width=0.7\textwidth]{fig.png}
```

#### 7.5.3 序号干扰检查

除 1/2/3 级标题（`\chapter{}` / `\section{}` / `\subsection{}`）外，检查有无其他序号干扰排版：

| 干扰来源 | 检查方法 | 处理方式 |
|---------|---------|---------|
| 条目编号 (`enumerate`) 与标题序号样式冲突 | 目视检查 | 改用 `itemize`，或嵌套 `enumitem` 自定义编号格式 |
| 图表编号格式不统一 | `grep "\\label{fig:" *.tex` 查看前缀 | 统一为 `fig:章节号-序号` |
| 公式编号与正文编号混淆 | 检查 `\tag{}` 或 `\label{eq:}` | 确保公式编号不盖正文 |
| 列表嵌套导致的数字重复（如 1. → 1.1. → 1.） | 目视检查 | 嵌套列表深层改用字母/符号编号 |

**有参考格式文档时：**
若用户上传了学校/期刊的参考格式文档（`.pdf` 或 `.cls`），按以下流程处理：

```
1. 读取参考文档中关于标题编号、图表编号、公式编号的格式要求
2. 对比当前 thesis.tex 中的配置是否一致
3. 不一致则按参考文档修改 \titleformat / \captionsetup / \numberwithin 等配置
```

**无参考格式文档时：**

```latex
% 默认模板配置（已内置于 §十一.2 format.tex）
% 标题字号、编号格式、图表编号分隔符以 §十一.2 为准
% 如需上传参考文档，告知用户并提供路径
```

---

## 八、定稿前全面复盘

> **核心原则：** 系统性检查 · 逐条核对 · 问题可追溯 · 修改必复查
>
> **触发时机：** 论文定稿前、用户要求"检查一遍论文"、提交盲审前

### 8.1 检查项总览（14 项）

#### 一、结构检查

##### 1. 四级标题检查

| 优先级 | 要求 | 检查方法 |
|--------|------|---------|
| P0 | 避免使用四级标题 | 搜索 `\subsubsection` 或四级标题标记 |

**处理方式：**
- 如果确实需要分层，使用**加粗独立一行**代替四级标题

```latex
% 错误
\subsubsection{实验设置}

% 正确
\noindent\textbf{实验设置}
```

##### 2. 章节逻辑一致性检查

| 优先级 | 要求 | 检查方法 |
|--------|------|---------|
| P0 | 第一章/第二章末尾的文章提纲描述，必须与后文章节实际内容一致 | 逐条核对提纲中的描述与对应章节的实际内容 |

**常见问题：**
- 第二章末尾说"第四章做 X，第五章做 Y"
- 实际第四章做的是 Y，第五章做的是 X

**检查方法：**
1. 提取第一章/第二章末尾的提纲描述
2. 逐章核对实际内容
3. 标记所有不一致之处

#### 二、用词与表达检查

##### 3. 夸张词汇检查

| 优先级 | 要求 | 检查方法 |
|--------|------|---------|
| P0 | 避免使用"特大创新"、"首次"、"显著"、"重大突破"等夸张词语 | 全文关键词检索 |

**禁用词汇表：**

| 禁用词 | 替代方案 |
|--------|---------|
| 首次提出 | 提出了一种 |
| 显著提升 | 提升了 X% |
| 重大突破 | 取得了进展 |
| 特大创新 | 具有创新性 |
| 世界第一 | 在……方面表现优异 |
| 革命性 | 具有重要影响 |

**注意：** 盲审时夸张词汇容易引起评审反感，增加被挂风险。

##### 4. 人称与视角检查

| 优先级 | 要求 | 检查方法 |
|--------|------|---------|
| P0 | 使用"本论文"、"本章"、"本节" | 全文检索"本研究"、"本文章"、"我们" |

##### 5. 缩写规范检查

| 优先级 | 要求 | 检查方法 |
|--------|------|---------|
| P0 | 中英文缩写首次出现时，必须给出英文全称 | 逐个检查缩写的首次出现位置 |

**示例：**
- ✅ 大语言模型（Large Language Model, LLM）
- ❌ 直接使用 LLM 而未给出全称

#### 三、盲审合规性检查

##### 6. 匿名性检查

| 优先级 | 要求 | 检查方法 |
|--------|------|---------|
| P0 | 不能出现真实组织名字、学校名 | 全文检索学校名、导师名、个人姓名 |
| P0 | 不能透露任何个人信息 | 检查致谢、作者简介、页眉页脚 |
| P0 | 不能包含指向个人信息的网页链接 | 检查文中所有 URL |

**需删除/替换的内容：**
- 学校名称（用"本文所在高校"替代）
- 导师姓名（盲审版删除）
- 个人姓名（盲审版删除）
- 课题组名称
- 个人 GitHub 主页链接
- 个人博客链接
- 致谢中的具体人名（盲审版删除或替换为"导师""家人"等泛称）

**致谢处理：**
- 盲审版本删除致谢或仅保留"感谢导师和家人的支持"等泛称
- 正式版本保留完整致谢

#### 四、图表一致性检查

##### 7. 图片颜色分布一致性检查

| 优先级 | 要求 | 检查方法 |
|--------|------|---------|
| P1 | 所有图的颜色分布应尽可能接近，保证画风一致 | 使用脚本提取并比较颜色分布 |

**检查流程：**
1. 单独编译文章中的每个 TikZ 图，或提取插入的 PDF/PNG 图片
2. 将图片放入临时文件夹
3. 运行颜色分布分析脚本
4. 比较所有图的主色调分布
5. 标记颜色风格差异较大的图

**颜色一致性标准：**
- 主色调色相应在同一范围内（如都偏冷色或都偏暖色）
- 色相应避免剧烈跳跃
- 饱和度水平应大致相当
- 背景色应统一

**脚本使用**（脚本位于 `references/bishe-guider/rule-04-review-check/scripts/check_figure_colors.py`）：

```bash
# 依赖安装
pip install Pillow matplotlib numpy scikit-learn PyMuPDF

# 调用方式（脚本支持 PNG/JPG/PDF，递归扫描，输出 HTML 报告）
cd /path/to/thesis/figures
python /path/to/references/bishe-guider/rule-04-review-check/scripts/check_figure_colors.py \
    --input ./ --output ./color_report.html --recursive
```

脚本功能：提取所有图片的主色调、饱和度、明度；计算图片间的颜色相似度矩阵；生成 HTML 报告，标记颜色风格不一致的图片。

#### 五、排版细节检查

##### 8. 公式标点检查

| 优先级 | 要求 | 检查方法 |
|--------|------|---------|
| P0 | 公式是文字的一部分，公式后面要有标点符号 | 逐个检查行间公式后的标点 |

##### 9. 表格对齐检查

| 优先级 | 要求 | 检查方法 |
|--------|------|---------|
| P1 | 文字列左对齐、数字列右对齐 | 检查每个表格的列对齐方式 |

##### 10. 首行缩进检查

| 优先级 | 要求 | 检查方法 |
|--------|------|---------|
| P0 | 中文段落首行空两格 | 抽查段落首行缩进 |

##### 11. 图表 Caption 检查

| 优先级 | 要求 | 检查方法 |
|--------|------|---------|
| P0 | 图表编号连续；Caption 简洁明确 | 检查编号连续性；Caption 是否自明 |

#### 六、逻辑与内容检查

##### 12. 创新点一致性检查

| 优先级 | 要求 | 检查方法 |
|--------|------|---------|
| P0 | 最后一章列出的创新点，必须与前文章节内容一一对应 | 逐条核对 |

##### 13. 实验可复现性检查

| 优先级 | 要求 | 检查方法 |
|--------|------|---------|
| P0 | 实验设置描述足够详细，他人可以复现 | 检查是否缺少关键超参数 |

##### 14. 引用完整性检查

| 优先级 | 要求 | 检查方法 |
|--------|------|---------|
| P0 | 正文中引用的每一篇文献，都必须在参考文献列表中 | 交叉核对 |
| P0 | 参考文献列表中的每一篇文献，都必须在正文中被引用 | 交叉核对 |

### 8.2 复盘检查流程

```
Step 1: 结构检查
  ├─ 四级标题排查
  ├─ 章节逻辑一致性核对
  └─ 创新点一致性核对

Step 2: 用词检查
  ├─ 夸张词汇排查
  ├─ 人称视角排查
  └─ 缩写规范排查

Step 3: 盲审合规性检查
  ├─ 学校名/组织名排查
  ├─ 人名排查
  ├─ 个人信息链接排查
  └─ 致谢匿名化处理

Step 4: 图表检查
  ├─ 编号连续性检查
  ├─ Caption 规范性检查
  ├─ 颜色分布一致性检查（运行脚本）
  └─ 字体大小检查

Step 5: 排版检查
  ├─ 公式标点检查
  ├─ 表格对齐检查
  ├─ 首行缩进检查
  └─ 参考文献格式检查

Step 6: 逻辑与内容检查
  ├─ 实验可复现性检查
  ├─ 引用完整性检查
  └─ 摘要与正文一致性检查
```

### 8.3 盲审用词保守要求

- 避免"首次""开创性""革命性"等绝对化表述
- 避免过度自夸，用事实和数据说话
- 严格使用学校模板
- 图表编号连续
- 参考文献格式一致

### 8.4 优先级体系

| 优先级 | 含义 | 处理方式 |
|--------|------|---------|
| **P0** | 必须满足，硬性要求 | 立即修改，不通过无法毕业 |
| **P1** | 重要要求，影响质量 | 尽量满足，提升论文水平 |
| **P2** | 优化建议，锦上添花 | 时间允许时改进 |

在输出复盘结果时，必须在"严重级别"列体现优先级对应的级别（P0→错误，P1→警告，P2→提示），输出格式同 §5.4。

---

## 九、Git 版本管理

### 9.1 Git 分支策略

```bash
# 主分支（稳定版）
main          # 每次提交对应一个完整可编译的版本

# 功能分支
git checkout -b chapter/03_method         # 写某一章
git checkout -b fix/review_comment_01      # 修审稿意见
git checkout -b format/layout_update       # 格式调整

# 合入主分支前必须 rebase
git rebase main
git checkout main
git merge --no-ff chapter/03_method
```

### 9.2 导入代码/插图时的原子提交

```latex
% thesis.tex 中插图示例
\begin{figure}[htbp]
    \centering
    \includegraphics[width=0.8\textwidth]{figures/system_arch.pdf}
    \caption{系统架构图}
    \label{fig:system_arch}
\end{figure}
```

插图文件（`.pdf`/`.png`）必须单独 `git add`，不得放在 `.gitignore` 中。

### 9.3 大版本快照

里程碑节点（如送审前、答辩前）需要 tag：

```bash
git tag -a v1.0-submission -m "提交评审版本 2026-05-15"
git tag -a v1.1-revision -m "修改后重投 2026-06-01"
git tag -a v2.0-defense  -m "答辩终版 2026-06-10"
git push --tags
```

### 9.4 回退方案

```bash
# 单文件回退到某次提交
git checkout <commit-hash> -- chapters/03_method.tex

# 整个版本回退
git revert HEAD --no-edit       # 安全回退（生成新 commit）
# 或
git reset --hard <commit-hash>  # 危险（丢弃后续修改）
```

---

## 十、论文进度记忆系统

### 10.1 记忆文件位置

```
.claude/thesis_progress.md
```

每次会话结束时更新此文件，下次打开时 Claude 先读取它，避免每次重复问"写到哪了"。

### 10.2 记忆文件格式

```markdown
# 论文进度记忆

## 项目信息
- 论文标题：（填写）
- 目标期刊/学校：（填写）
- 参考格式文档：有 / 无（路径：xxx）

## 当前进度
- 总章节数：6 / 6
- 已完成：□ 01 绪论  □ 02 相关工作  □ 03 系统设计
- 进行中：■ 04 方法（当前工作）
- 未开始：□ 05 实验  □ 06 总结

## 当前工作阶段
阶段：写作 / 修改 / 格式调整 / 审稿回复

## 下一步待办
1. [ ] 完成 4.2 节算法描述
2. [ ] 绘制算法流程图（figures/algorithm_flow.pdf）
3. [ ] 补充 4.3 节伪代码
4. [ ] 运行 check_thesis.ps1 检查格式

## 待处理问题
- 格式问题：表格 caption 字号需要确认
- 引用缺失：第 2 章缺 3 篇参考文献
- 审稿意见：Reviewer#2 要求补充对比实验

## 会话记录
- 2026-05-05：创建 4.1 节，完成硬件描述
- 2026-05-06：编写 4.2 节，绘制图 4-1
```

### 10.3 技能加载时的行为

用户要求处理论文时，按此流程执行：

```
[用户："写论文" / "继续写" / "处理论文"]

    │
    ├─ 1. 读取 .claude/thesis_progress.md
    │      ├─ 文件存在 → 解析当前进度
    │      ├─ 文件不存在 → 提示用户初始化:
    │      │     "检测到未初始化论文进度，请提供以下信息：
    │      │       1. 论文标题
    │      │       2. 当前已完成章节
    │      │       3. 正在写的章节"
    │      │     按回答创建 thesis_progress.md
    │      └─ 文件损坏/格式不对 → 报错并重建
    │
    ├─ 2. 扫描 chapters/ 目录，对比实际文件内容与记忆
    │      ├─ 发现的 .tex 文件 → 读取各文件字数/节数
    │      ├─ 与记忆对比 → 若实际进度超前或落后则：
    │      │     "检测到 chapters/ 内容与记忆不符，已同步"
    │      └─ 更新记忆为真实状态
    │
    ├─ 3. 输出当前状态摘要给用户
    │      "当前进度：第 4 章（方法）写作中
    │        已完成：第1-3章 (共 xxx 字)
    │        下一步：完成 4.2 节算法描述"
    │
    ├─ 4. 询问用户意图
    │      "要继续写第 4 章，还是做别的？（例如：修改第 2 章、补参考文献、格式调整）"
    │
    └─ 5. 按答复进入对应工作流
           ★ 进入"写章节"或"修章节"工作流时，必须遵守 §6.0 主动配图守则 ★
```

### 10.4 每次修改后更新记忆

完成一轮修改后（无论长短），更新 `.claude/thesis_progress.md`：

| 字段 | 更新规则 |
|------|---------|
| 当前进度 | 标记刚修改的章节为已完成 |
| 进行中 | 实际内容不为空但未完成的章节 |
| 下一步待办 | 根据本次修改内容列出后续动作 |
| 会话记录 | 追加一行：`日期：做了什么` |
| 当前工作阶段 | 写作 / 修改 / 格式调整 / 审稿回复 |

```powershell
# 辅助命令：更新进度记忆中的会话记录
$date = Get-Date -Format "yyyy-MM-dd"
Add-Content -Path ".claude/thesis_progress.md" -Value "- $date：已完成 4.2 节"
```

### 10.5 初始化模板（首次使用）

用户第一次启用技能且 `thesis_progress.md` 不存在时，Claude 自动创建此内容：

```markdown
# 论文进度记忆

## 项目信息
- 论文标题：（待填写）
- 目标期刊/学校：（待填写）
- 参考格式文档：无

## 当前进度
- 总章节数：6 / 6
- 已完成：（无）
- 进行中：（无）
- 未开始：□ 01 绪论  □ 02 相关工作  □ 03 系统设计
          □ 04 方法  □ 05 实验  □ 06 总结

## 当前工作阶段
阶段：写作

## 下一步待办
1. [ ] 确认论文标题
2. [ ] 开始撰写第 1 章

## 待处理问题
（无）

## 会话记录
（无）
```

此文件需提交到 Git 仓库，供多设备共享进度。建议在 `.gitignore` 中排除敏感信息，但保留此文件本身。

---

## 十一、附录

### 11.1 快速检查参考

```bash
# 启用技能后先检查环境 + 读取进度记忆
pwsh -NoProfile -Command "检查 TeX Live、VS Code、Git 是否装齐"
# → 同时读取 .claude/thesis_progress.md，判断当前阶段和下一步

# 打开文件修改前，先运行格式预检：
pwsh -NoProfile tools/check_thesis.ps1   # PowerShell 格式检查

# 提交前执行完整编译检查：
make clean && make            # 确保零错误编译
grep "??" thesis.aux          # 无未定义引用
grep "Overfull" thesis.log    # 检查版式问题

# 排版检查（逐页翻阅 PDF）：
#   1. 大面积空白  — 检查 Overfull vbox 警告
#   2. 图片位置    — 图有无跑错章节、隔断正文
#   3. 序号干扰    — 除 chapter/section/subsection 外有无多余序号
#   4. 有参考格式  → 按文档修改
#   5. 无参考格式  → 用 §十一.2 默认模板

# 定稿前全面复盘（§八）：
#   1. 结构 / 用词 / 盲审 / 图表 / 排版 / 逻辑 六大维度
#   2. 运行 references/bishe-guider/.../check_figure_colors.py 检查图片画风

# 修改完成后更新进度记忆：
#   → 更新 .claude/thesis_progress.md
```

### 11.2 学位论文通用格式约束

```latex
% ------- setup/format.tex -------

% 页边距：上2.54cm 下2.54cm 左3.17cm 右3.17cm
\geometry{top=2.54cm, bottom=2.54cm, left=3.17cm, right=3.17cm}

% 行距：1.5倍（Word 默认）
\linespread{1.5}

% 首行缩进 2 字符
\setlength{\parindent}{2em}

% 标题格式
\usepackage{titlesec}
\titleformat{\chapter}{\centering\heiti\Large}{第\,\thechapter\,章}{1em}{}
\titleformat{\section}{\heiti\large}{\thesection}{1em}{}
\titleformat{\subsection}{\heiti\normalsize}{\thesubsection}{1em}{}

% 图表标题
\captionsetup[figure]{labelsep=space, font=small, position=bottom}
\captionsetup[table]{labelsep=space, font=small, position=top}

% 代码风格
\lstset{
    basicstyle=\ttfamily\footnotesize,
    numbers=left,
    numberstyle=\tiny,
    frame=single,
    breaklines=true,
    captionpos=b,
    tabsize=4
}
```

### 11.3 代码清单格式化

```latex
% ------- setup/command.tex -------

% 通用 C 代码风格
\lstdefinestyle{cStyle}{
    language=C,
    basicstyle=\ttfamily\small,
    keywordstyle=\bfseries\color{blue},
    commentstyle=\color{green!60!black},
    stringstyle=\color{red!60!black},
    numbers=left,
    numberstyle=\tiny\color{gray},
    frame=single,
    rulecolor=\color{black!30},
    breaklines=true,
    tabsize=4,
    showstringspaces=false,
    captionpos=b
}

% Python 代码风格
\lstdefinestyle{pyStyle}{
    language=Python,
    basicstyle=\ttfamily\small,
    keywordstyle=\bfseries\color{blue},
    stringstyle=\color{red!60!black},
    commentstyle=\color{green!60!black},
    numbers=left,
    numberstyle=\tiny\color{gray},
    frame=single,
    breaklines=true,
    tabsize=4,
    captionpos=b
}
```

### 11.4 通用三线表模板

```latex
\begin{table}[htbp]
    \centering
    \caption{实验参数对比}
    \label{tab:comparison}
    \begin{tabular}{lccc}
        \toprule
        参数 & 方案A & 方案B & 方案C \\
        \midrule
        指标一 & 0.95 & 0.87 & 0.92 \\
        指标二 & 120 & 95  & 110 \\
        指标三 & 45.2 & 51.7 & 48.3 \\
        \bottomrule
    \end{tabular}
\end{table}
```

### 11.5 自定义宏命令

```latex
% ------- setup/command.tex -------

% 常用缩写
\newcommand{\eg}{e.g.\xspace}
\newcommand{\ie}{i.e.\xspace}

% 测量单位
\newcommand{\mV}{mV}
\newcommand{\mA}{mA}

% 术语强调
\newcommand{\term}[1]{\textit{#1}}
```

### 11.6 学科特定格式约束

| 项目属性 | 格式要求 |
|---------|---------|
| 中文字体 | SimSun（宋体）正文，SimHei（黑体）标题 |
| 英文字体 | Times New Roman |
| 代码字体 | Courier New 或 Fira Code |
| 图表编号 | 按章："图 3-1"、"表 4-2" |
| 公式编号 | 按章："(3-1)" |
| 参考文献标注 | 右上角方括号上标 `\textsuperscript{[1]}` 或 `\cite{}` |
| 页眉页脚 | 奇数页：章名，偶数页：论文题目 |
| 打印要求 | 左侧装订，左页边距 > 右页边距 |

### 11.7 参考资料索引

本 skill 的内容规范、文献检索、AI 痕迹检测、复盘检查四大章节，来源于 `references/bishe-guider/`（源：LSTM-Kirigaya/jinhui-skills）。需要查阅原始更详细的规则文档或运行其配套脚本时，参考下表：

| 主题 | 本 skill 章节 | 原始 reference | 配套脚本 |
|------|------------|-----------|--------|
| 项目初始化标准目录 | §一 | `references/bishe-guider/rule-05-project-init/reference.md` | `rule-05-project-init/scripts/init_project.sh` |
| AI 写作痕迹检测 | §五 | `references/bishe-guider/rule-01-humanizer/reference.md` | — |
| 文献检索与引用 | §四 | `references/bishe-guider/rule-02-reference-search/reference.md` | — |
| 论文内容规范 | §三 | `references/bishe-guider/rule-03-thesis-writing/reference.md` | — |
| 定稿前全面复盘 | §八 | `references/bishe-guider/rule-04-review-check/reference.md` | `rule-04-review-check/scripts/check_figure_colors.py` |
| TikZ 转 PNG | §六 | — | `references/bishe-guider/rule-05-project-init/scripts/compile_tikz_to_png.sh` |
| PDF 抽图 | §六 | — | `references/bishe-guider/rule-05-project-init/scripts/extract_figures_from_pdf.py` |

# LaTeX 论文写作技能文档

> 通用学位/学术论文 LaTeX 写作规范与工具链指南。

---

## 〇、启用检查

启用本技能后，首先检查项目环境工具链是否配齐，缺则引导安装。

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
    Write-Host "[INFO] thesis.tex 不存在（新项目需创建）" -ForegroundColor Cyan
}
```

**缺啥补啥：**

| 缺失项 | Windows 安装命令 |
|--------|-----------------|
| TeX Live | `winget install TeXLive` 或手动下载 `install-tl-windows.exe` |
| VS Code | `winget install Microsoft.VisualStudioCode` |
| LaTeX Workshop | `code --install-extension latex-workshop` |
| Git | `winget install Git.Git` |

---

## 一、工具链前置

### 1.1 LaTeX 发行版

| 工具 | 说明 |
|------|------|
| **TeX Live** | 完整发行版，支持 `xelatex`，含 `ctex` 宏包中文支持 |

**安装检查：**
```bash
xelatex --version
# 输出应含 "XeTeX 3.141592653-..." 即正常
```

### 1.2 编辑器

| 工具 | 用途 | 配置文件 |
|------|------|---------|
| VS Code + LaTeX Workshop | 编译/预览/Bib 管理 | `.vscode/settings.json` |

**VS Code 编译方案配置：**

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

### 1.3 版本控制

```bash
# .gitignore
*.aux *.log *.out *.bbl *.bcf *.blg *.run.xml *.synctex.gz *.toc *.lof *.lot *.pdf
```

---

## 二、工具链调用

### 2.1 编译命令

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

### 2.2 Makefile（推荐）

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

### 2.3 本地备份

```bash
# 将论文目录打包备份到指定位置
tar -czf thesis_backup_$(date +%Y%m%d_%H%M).tar.gz thesis/

# 或使用 git 本地仓库（推荐）
git add -A
git commit -m "backup: 论文进度 YYYY-MM-DD"
```

---

## 三、论文格式要求

### 3.1 模板结构

```
thesis/
├── thesis.tex              # 主文件
├── setup/
│   ├── package.tex          # 宏包载入
│   ├── format.tex           # 格式设定
│   └── command.tex          # 自定义命令
├── chapters/
│   ├── 01_introduction.tex
│   ├── 02_related_work.tex
│   ├── 03_system_design.tex
│   ├── 04_method.tex
│   ├── 05_experiment.tex
│   └── 06_conclusion.tex
├── figures/
├── refs.bib
├── tools/
│   └── check_thesis.ps1     # PowerShell 格式预检脚本
└── .githooks/
    └── pre-commit           # 预提交检查
```

### 3.2 主文件框架 (`thesis.tex`)

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
```

### 3.3 章节内容模板

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

### 3.4 参考文献格式 (`refs.bib`)

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

---

## 四、修改时的编码检查

每次对论文 `.tex` 文件做实质性修改前，必须执行以下检查：

### 4.1 编译检查清单

```bash
# 1. 检查 LaTeX 语法错误
xelatex -interaction=nonstopmode thesis.tex 2>&1 | grep -E "^!|Error|Warning"

# 2. 检查未定义引用
grep -c "??" thesis.aux        # 应为 0

# 3. 检查过满/过宽盒子
grep -E "Overfull|Underfull" thesis.log
```

### 4.2 格式约束检查

| 检查项 | 规则 | 手动检查命令 |
|--------|------|-------------|
| 章节编号连续 | 不应跳过编号 | `grep -rE "\\\\chapter\{|\\\\section\{" chapters/` |
| 图表有 caption | 每幅图/表必含 `\caption{}` | 目视检查是否有图无标题 |
| 引用非空 | 无 `\cite{}` `\ref{}` 空括号 | `grep -rE "\\\\cite\{\s*\}|\\\\ref\{\s*\}" chapters/` |
| 中英文混排间距 | 中文与英文/数字间应有半角空格 | 目视检查 |

### 4.3 PowerShell 文档预检脚本（读取/编译前检查）

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

### 4.4 Git 预提交检查脚本

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

### 4.5 排版检查（每次修改后执行）

每次修改完成、提交前，打开生成的 PDF 逐页检查以下项目：

#### 4.5.1 大面积空白检查

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

#### 4.5.2 图片位置检查

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

#### 4.5.3 序号干扰检查

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
% 默认模板配置（已内置于 6.1 节 format.tex）
% 标题字号、编号格式、图表编号分隔符以 6.1 节为准
% 如需上传参考文档，告知用户并提供路径
```

---

## 五、每次修改的内容备份

### 5.1 Git 分支策略

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

### 5.2 导入代码/插图时的原子提交

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

### 5.3 大版本快照

里程碑节点（如送审前、答辩前）需要 tag：

```bash
git tag -a v1.0-submission -m "提交评审版本 2026-05-15"
git tag -a v1.1-revision -m "修改后重投 2026-06-01"
git tag -a v2.0-defense  -m "答辩终版 2026-06-10"
git push --tags
```

### 5.4 回退方案

```bash
# 单文件回退到某次提交
git checkout <commit-hash> -- chapters/03_method.tex

# 整个版本回退
git revert HEAD --no-edit       # 安全回退（生成新 commit）
# 或
git reset --hard <commit-hash>  # 危险（丢弃后续修改）
```

---

## 六、根据格式模板定制化 LaTeX 格式约束

### 6.1 学位论文通用约束（适用于中国高校）

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

### 6.2 代码清单格式化

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

### 6.3 通用三线表模板

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

### 6.4 自定义宏命令

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

### 6.5 学科特定格式约束

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

---

## 七、附录

### 7.1 论文目录结构

```
thesis/
├── thesis.tex                # 主文件（编译入口）
├── Makefile                  # 一键编译
├── setup/
│   ├── package.tex           # 宏包引入
│   ├── format.tex            # 格式设定（6.1节）
│   └── command.tex           # 自定义命令（6.2+6.4节）
├── chapters/
│   ├── 01_introduction.tex   # 绪论
│   ├── 02_related_work.tex   # 相关工作
│   ├── 03_system_design.tex  # 系统设计
│   ├── 04_method.tex         # 方法/实现
│   ├── 05_experiment.tex     # 实验与结果分析
│   └── 06_conclusion.tex     # 总结与展望
├── figures/                  # 插图（PDF 优先）
├── refs.bib                  # 参考文献数据库
├── tools/
│   └── check_thesis.ps1      # PowerShell 格式预检脚本（4.3节）
├── .claude/
│   └── thesis_progress.md    # 论文进度记忆（八）
└── .githooks/
    └── pre-commit            # 预提交检查（4.4节）
```

### 7.2 快速检查参考

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
#   5. 无参考格式  → 用 6.1 节默认模板

# 修改完成后更新进度记忆：
#   → 更新 .claude/thesis_progress.md
```

---

## 八、论文进度记忆系统

### 8.1 记忆文件位置

```
.claude/thesis_progress.md
```

每次会话结束时更新此文件，下次打开时 Claude 先读取它，避免每次重复问"写到哪了"。

### 8.2 记忆文件格式

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

### 8.3 技能加载时的行为

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
           ★ 进入"写章节"或"修章节"工作流时，必须遵守 §9.0 主动配图守则 ★
```

### 8.4 每次修改后更新记忆

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

### 8.5 初始化模板（首次使用）

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

## 九、LaTeX 原生绘图

模板已加载 `tikz` + `pgfplots` + `circuitikz`，所有图都可以**用文本写出来**，编译产出矢量 PDF，永不糊。优先级：

```
原生绘图（TikZ/PGFPlots） > 矢量 PDF（Inkscape/Visio 导出） > PNG/JPG 位图
```

写论文时**首选 TikZ/PGFPlots**：可 diff、可改色改字号、缩放无损、与正文字体一致。

### 9.0 写作守则：主动配图（不要等用户提醒）

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
    │      ├─ 优先用 §9.2-9.6 的模板（不要重新发明轮子）
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

### 9.1 何时用哪种工具

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

### 9.2 流程图模板

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

### 9.3 系统框图模板

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

### 9.4 折线图（PGFPlots 读 CSV）

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

### 9.5 柱状图

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

### 9.6 数学函数曲线

```latex
\begin{tikzpicture}
    \begin{axis}[thesis, xlabel={$x$}, ylabel={$y$},
                 domain=-3:3, samples=100, legend pos=north west]
        \addplot {sin(deg(x))};      \addlegendentry{$\sin x$}
        \addplot {x^2/9 - 1};        \addlegendentry{$x^2/9 - 1$}
    \end{axis}
\end{tikzpicture}
```

### 9.7 把 TikZ 图独立成文件

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

### 9.8 加速编译：externalize

TikZ 图多了编译会变慢。`thesis.tex` 序言加：

```latex
\usetikzlibrary{external}
\tikzexternalize[prefix=figures/tikz/cache/]
```

首次编译每张图独立生成 PDF 并缓存，之后只重编修改过的。注意：使用前需在 `thesis.tex` 编译命令加 `-shell-escape`：

```bash
xelatex -shell-escape thesis.tex
```

### 9.9 绘图调试技巧

| 问题 | 排查 |
|------|------|
| 节点叠在一起 | `node distance=1.2cm and 1.6cm` 调间距（垂直 and 水平） |
| 连线穿过节点 | 改用 `|-` `-|` 折线，或用 `to[bend left=30]` |
| 中文不显示 | 确保用 xelatex 编译；TikZ 内中文照常写即可 |
| PGFPlots 报 compat | `\pgfplotsset{compat=1.18}` 已设；老版本 TeX Live 改成 `1.16` |
| 图过大超出页面 | `\resizebox{0.9\linewidth}{!}{...}` 包一层，或调 `width=` 参数 |
| externalize 后改了图没生效 | 删 `figures/tikz/cache/` 重编 |

### 9.10 让 Claude 帮你画图

让 Claude 生成 TikZ 时，提供这三样：

1. **目标**："画一个三层神经网络的示意图，输入 4 节点、隐藏 5 节点、输出 2 节点"
2. **风格**："用模板里的 `block/module` 样式" 或 "纯黑白线条"
3. **数据**（PGFPlots 才需要）：csv 路径或粘贴几行数据

Claude 应优先使用模板里已定义的 `flow/*`、`block/*`、`thesis` 样式，不要重新定义颜色和字号。

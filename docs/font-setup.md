# 字体配置指南

## 概述

本模板默认使用 Windows 平台自带的中文字体。Linux 和 macOS 用户需要替换
为开源字体或手动安装对应字体。

## 默认字体方案

| 用途 | Windows | 字号 | 备注 |
|------|---------|------|------|
| 正文 | SimSun（宋体） | 小四 (12pt) | Windows 自带 |
| 标题 | SimHei（黑体） | 三号/四号 (16/14pt) | Windows 自带 |
| 封面校名 | STZhongsong（华文中宋） | 一号 (26pt) | Windows 自带（部分版本可能需安装） |
| 英文正文 | Times New Roman | 12pt | 系统自带 |
| 英文无衬线 | Arial | — | 系统自带 |
| 等宽字体 | Courier New | — | 系统自带 |

## 一键自检

直接跑 `pwsh tools/setup_env.ps1`，脚本会枚举系统已装字体并列出哪些缺失，
然后按下文方案对症处理。

## Windows 缺字体怎么办

**SimSun / SimHei** — 几乎所有 Windows 都自带，缺失通常是装了精简/魔改版系统。
可以改用同源开源字体（思源宋体 Noto Serif CJK SC、思源黑体 Noto Sans CJK SC）。

**FangSong / STZhongsong** — 这两个**不是 Windows 核心字体**，常随 Microsoft Office
一起装。如果没装 Office，有三种办法：

1. **装 Office** — 一劳永逸，FangSong / STKaiti / STZhongsong 等"华文系列"会一起到位。
2. **临时改字体** — 编辑 `setup/format.tex`，把缺的那一行改成已有字体（最省事）：
   ```latex
   % 缺 FangSong 时
   \newCJKfontfamily{\fangsong}{SimSun}
   % 缺 STZhongsong 时（封面校名会变成宋体，可读但视觉略变）
   \newCJKfontfamily{\huawenzhongsong}{SimSun}
   ```
3. **单独下载字体文件** — 网上能找到 `STZHONGS.TTF` / `simfang.ttf`，下载后双击安装。
   注意版权：仅个人学习使用，不要随论文 PDF 二次分发字体源文件。

**Times New Roman / Arial / Courier New** — Windows 默认都有；只在极少数 N 版系统
（不含媒体功能包）会缺，装一下「媒体功能包」即可。

## 跨平台字体方案

### Linux (Ubuntu/Debian)

```bash
# 安装开源 CJK 字体
sudo apt install fonts-noto-cjk fonts-noto-cjk-extra

# 安装 Times New Roman 替代字体
sudo apt install fonts-freefont-ttf
```

然后在 `setup/format.tex` 中使用开源字体：

```latex
% 开源 CJK 字体替代方案
\setCJKmainfont{Noto Serif CJK SC}[AutoFakeBold=2.5]     % 思源宋体 → 替代 SimSun
\setCJKsansfont{Noto Sans CJK SC}[AutoFakeBold=2.5]      % 思源黑体 → 替代 SimHei
\newCJKfontfamily{\heiti}{Noto Sans CJK SC}[AutoFakeBold=2.5]
\newCJKfontfamily{\songti}{Noto Serif CJK SC}
\newCJKfontfamily{\fangsong}{Noto Sans CJK SC}           % 无对应，用黑体替代
\newCJKfontfamily{\huawenzhongsong}{Noto Serif CJK SC}   % 无对应，用宋体替代

\setmainfont{FreeSerif}                                   % 替代 Times New Roman
\setsansfont{FreeSans}                                    % 替代 Arial
\setmonofont{FreeMono}                                    % 替代 Courier New
```

### macOS

macOS 自带华文宋体等字体，通常直接使用模板即可。如需安装额外字体：

```bash
# macOS 通常已有华文字体
# 如缺少 STZhongsong，可下载华文字体包或改用其他字体
```

macOS 字体方案：

```latex
\setCJKmainfont{Songti SC}[AutoFakeBold=2.5]             % 系统宋体
\setCJKsansfont{Heiti SC}[AutoFakeBold=2.5]              % 系统黑体
\newCJKfontfamily{\heiti}{Heiti SC}[AutoFakeBold=2.5]
\newCJKfontfamily{\songti}{Songti SC}
\newCJKfontfamily{\fangsong}{STFangsong}                  % macOS 自带仿宋
\newCJKfontfamily{\huawenzhongsong}{STZhongsong}          % macOS 自带
```

## 检查已安装字体

### Windows

```powershell
# PowerShell 查看已安装字体
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
(New-Object System.Drawing.Text.InstalledFontCollection).Families | Where-Object { $_.Name -like "*Sim*" -or $_.Name -like "*Hei*" -or $_.Name -like "*Song*" -or $_.Name -like "*Zhong*" } | ForEach-Object { $_.Name }
```

### Linux

```bash
fc-list :lang=zh | grep -i "song\|hei\|noto\|CJK"
```

### macOS

```bash
fc-list :lang=zh | grep -i "song\|hei\|ST\|CJK"
```

## 常见字体问题

### "Missing character" 编译警告

某个字符在所选字体中不存在。常见原因：
- 简体中文/繁体中文混用
- 使用了生僻字
- 英文花体/希腊字母未配置

### 字体无法找到 "font not found"

检查字体名称是否正确（区分大小写、空格）：

```bash
# 列出系统所有中文字体
fc-list :lang=zh
```

### PDF 中中文显示为方框

- 确保使用 `xelatex` 编译（不是 `pdflatex`）
- 确保 `\setCJKmainfont{}` 指定的字体名称与系统一致

### Overleaf 上字体问题

Overleaf 使用 Linux 环境，Windows 字体不可用。建议：
- 上传字体文件到 `fonts/` 目录
- 使用 `\setCJKmainfont[Path=./fonts/]{SimSun.ttf}` 指定路径

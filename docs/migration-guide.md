# 从 Word 迁移到 LaTeX — 论文写作指南

如果你之前用 Word 写论文，第一次接触 LaTeX，本指南帮你快速上手。

## 心态转换

| Word | LaTeX |
|------|-------|
| 所见即所得 | 编写代码 → 编译 → PDF |
| 拖动调整格式 | 代码控制格式 |
| 手动更新编号 | 自动编号、自动交叉引用 |
| 参考文献手动排版 | `.bib` 数据库自动格式化 |

**核心理念：** 用 LaTeX 写论文，你只需关注_内容_，格式由模板统一处理。

## 快速上手

### Compile → Preview 周期

```
编辑 .tex 文件 → 保存 → make（或 Ctrl+S 触发自动编译）→ 查看 PDF
```

### 常用元素写法

```latex
% 章节层级
\chapter{绪论}              % 第 1 章
\section{研究背景}           % 1.1
\subsection{国内外现状}      % 1.1.1

% 正文段落（直接写，段间空一行即分段）
这是一段内容。段落之间空一行即自动分段。每段首行自动缩进两字符。

% 数学公式
\begin{equation}
    f(x) = \frac{1}{\sqrt{2\pi}\sigma} e^{-\frac{(x-\mu)^2}{2\sigma^2}}
    \label{eq:gaussian}
\end{equation}

% 交叉引用
如公式~\ref{eq:gaussian} 所示，图~\ref{fig:arch} 展示了……

% 插入图片（占位符 → 后续替换为真实图片）
\begin{figure}[H]
    \centering
    \fbox{\begin{minipage}{0.82\textwidth}
    \centering
    \vspace{2.5cm}
    {\fontsize{16pt}{24pt}\selectfont 系统架构图}\\[1em]
    {\fontsize{12pt}{18pt}\selectfont （待补充示意图）}
    \vspace{2.5cm}
    \end{minipage}}
    \caption{系统架构}
    \label{fig:arch}
\end{figure}

% 三线表
\begin{table}[H]
    \centering
    \caption{实验参数对比}
    \label{tab:comparison}
    \begin{tabular}{lcc}
        \toprule
        参数 & 方案A & 方案B \\
        \midrule
        准确率 & 95.8\% & 93.5\% \\
        \bottomrule
    \end{tabular}
\end{table}

% 参考文献引用
\cite{krizhevsky2012imagenet}    % 引用一篇
\cite{he2016deep, hu2018squeeze} % 引用多篇
```

## 避坑指南

### 不要做的事

- **不要用 itemize/enumerate 列表** — 中文论文正文段落内不应有项目符号
  - 改用流畅段落："首先……其次……最后……"
- **不要用 lstlisting 代码块** — 格式突兀
  - 改写为自然语言描述关键逻辑
- **不要在图片中使用英文标签** — 中文学位论文图内文字应为中文
- **不要用 `\maketitle`** — 本模板已自定义 titlepage

### 常见报错

| 报错 | 原因 | 解决 |
|------|------|------|
| `Undefined control sequence` | 拼写错误的命令 | 检查 LaTeX 命令名 |
| `Missing \begin{document}` | `\begin{document}` 之前有输出 | 检查是否在 document 前误写了文字 |
| `There were undefined references` | 引用了不存在的 label | 运行第二次 xelatex；检查 label 名 |
| `Overfull \hbox` | 文字超出了行宽 | 检查是否有过长的英文词/URL |

## 排版理念

让 LaTeX 自己决定分页和图片位置，不要过早手动干预：

- 初稿阶段：用 `[H]` 固定位置便于写作
- 定稿阶段：改用 `[htbp]` 让 LaTeX 自动优化布局
- 如有大面积空白，优先调整文字量而非 `\vspace` 强制定位

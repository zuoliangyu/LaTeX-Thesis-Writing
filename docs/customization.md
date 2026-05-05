# 学校格式适配指南

不同高校在学位论文格式上可能有细微差异。本指南说明如何修改模板以匹配
你所在学校的格式要求。

## 适配步骤

### 1. 获取学校官方格式文档

从学校教务处或研究生院网站下载学位论文格式要求（通常为 Word 模板或 PDF）。

### 2. 修改封面信息

编辑 `setup/titlepage.tex`：

- 替换「大学名字」为实际学校名
- 修改学院、专业、班级等字段名称
- 调整字体和字号（如果与模板不同）

### 3. 修改页面设置

编辑 `setup/format.tex`，按需调整以下参数：

```latex
% 页边距（常见差异：3.17cm vs 3.0cm 左边距）
\geometry{top=2.54cm, bottom=2.54cm, left=3.17cm, right=3.17cm}

% 行距（常见差异：1.25倍 vs 1.5倍）
\linespread{1.5}

% 正文字号（常见差异：小四号 12pt vs 四号 14pt）
% 修改 \documentclass 中的 12pt 参数
```

### 4. 修改标题格式

```latex
% 章标题：居中/左对齐、字号大小可能有差异
\titleformat{\chapter}{\centering\heiti\fontsize{18pt}{27pt}\selectfont}
  {第\,\thechapter\,章}{1em}{}
\titlespacing*{\chapter}{0pt}{2.8mm}{2.8mm}
```

### 5. 修改页眉

```latex
% 替换页眉文字为你的学校名
\fancyhead[C]{\fontsize{10.5pt}{15.75pt}\selectfont 大学名字毕业设计（论文）}
```

## 常见格式差异速查

| 格式项 | 默认值 | 常见变体 | 修改位置 |
|--------|--------|---------|----------|
| 左边距 | 3.17cm | 3.0cm、3.5cm | `\geometry{}` |
| 行距 | 1.5 倍 | 1.25 倍、2 倍 | `\linespread{}` |
| 章标题对齐 | 居中 | 左对齐 | `\titleformat{\chapter}` |
| 封面字体 | 华文中宋 | 黑体、宋体 | `titlepage.tex` |
| 页眉文字 | 大学名字 | 学校全称 | `\fancyhead[C]{}` |
| 摘要标题 | 两字间空一格 | 不空格 | `abstract.tex` |
| 声明页 | 有 | 无（合并为一页） | `titlepage.tex` |
| 图表编号 | 按章（图3.1） | 按节（图3.1.1） | `\counterwithin` |
| 参考文献样式 | numeric | gb7714-2015 | `\usepackage{biblatex}` |

## 多学校配置文件示例

建议在 `setup/` 目录下为每个学校创建独立配置文件：

```
setup/
├── format.tex              # 默认格式
├── format_hust.tex         # 华中科技大学
├── format_zju.tex          # 浙江大学
└── format_seu.tex          # 东南大学
```

使用时在 `thesis.tex` 中切换 `\input{setup/format_xxx.tex}`。

## 贡献你的学校格式

如果你的学校有特殊格式要求并已成功适配，欢迎提交 PR 添加你的配置。

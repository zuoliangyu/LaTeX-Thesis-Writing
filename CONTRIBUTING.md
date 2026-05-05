# 贡献指南

感谢你对本项目的兴趣！本项目欢迎各种形式的贡献。

## 如何贡献

### 报告问题

- 使用 [Issue 模板](https://github.com/your-org/latex-thesis-package/issues/new?template=bug_report.md) 报告 Bug
- 提供操作系统、TeX Live 版本、编译日志（`.log` 文件）

### 功能建议

- 使用 [Feature Request 模板](https://github.com/your-org/latex-thesis-package/issues/new?template=feature_request.md)
- 说明你的学校/专业格式要求差异

### 提交代码

1. Fork 本仓库
2. 创建功能分支：`git checkout -b feature/my-feature`
3. 确保模板可编译（`make clean && make`）
4. 提交前运行格式检查：`pwsh tools/check_thesis.ps1`
5. 提交 PR，描述改动内容和动机

### 适配你的学校格式

如果你想让本模板支持你所在学校的格式，请提供以下资料：

1. 学校官方论文格式要求文档（如 `.pdf`、`.docx`）
2. 修改后的 `setup/format.tex` 参数
3. 封面样式截图
4. 在 `docs/customization.md` 中添加你的学校条目

### 提交规范

- commit message 使用中文，遵循 `<类型>: <简述>` 格式
- 类型：`feat`（新功能）、`fix`（修复）、`docs`（文档）、`style`（格式）
- 示例：`feat: 添加南京大学封面格式支持`

## 开发环境

```bash
# 安装依赖
# Windows
winget install TeXLive

# Linux
sudo apt install texlive-full

# 验证编译
cd thesis-template
make
```

## 代码审查

所有 PR 需要：
- CI 编译通过（GitHub Actions 自动检查）
- `check_thesis.ps1` 或 `check_thesis.sh` 检查通过
- 至少一位维护者批准

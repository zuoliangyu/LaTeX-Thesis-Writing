# 更新日志

## [Unreleased]

### Added
- `claude_skills/latex_thesis_writing.md` 新增 4 大写作辅助章节，参考自 [bishe-guider](https://kirigaya.cn/ktools/skillmanager/skill/1776952526866)（源仓库 [LSTM-Kirigaya/jinhui-skills](https://github.com/LSTM-Kirigaya/jinhui-skills)）：
  - §三 论文内容规范（评审标准 / 绪论 / 章节结构 / 实验规范 / 用词规范）
  - §四 文献检索与引用（Google Scholar 检索流程 / 文献评估 / 引用规范 / 综述写作）
  - §五 去 AI 痕迹（24 项检测清单 + 中文学术专属检查）
  - §八 定稿前全面复盘（14 项系统性检查清单 + 盲审合规性 + 图片颜色一致性）
- `references/bishe-guider/` 保留原始参考素材，含脚本：
  - `rule-04-review-check/scripts/check_figure_colors.py` — 图片颜色分布分析与一致性检查
  - `rule-05-project-init/scripts/init_project.sh` — 标准学术论文项目目录初始化
  - `rule-05-project-init/scripts/compile_tikz_to_png.sh` — TikZ 转 PNG
  - `rule-05-project-init/scripts/extract_figures_from_pdf.py` — 从 PDF 抽图
- 初始模板发布
- 通用高校学位论文格式模板
- 封面页（含声明页、版权授权页）
- 中英文摘要模板
- 致谢模板
- PowerShell 预检脚本 `check_thesis.ps1`
- Bash 预检脚本 `check_thesis.sh`
- Git 预提交 hook
- VS Code + LaTeX Workshop 配置
- Claude Code 技能文档 `latex_thesis_writing.md`
- 论文进度记忆系统
- GitHub Actions CI 自动编译

### Changed
- `claude_skills/latex_thesis_writing.md` 全文重组：1350 → 2188 行，按写论文生命周期重新组织为 11 大章节（〇启动 → 一初始化 → 二工具链 → 三内容规范 → 四文献 → 五去 AI 痕迹 → 六 TikZ 绘图 → 七修改检查 → 八定稿复盘 → 九 Git → 十进度记忆 → 十一附录）
- 原 §9.0 主动配图守则编号变更为 §6.0（其余 TikZ 子节同步迁移）

## [1.0.0] - 2026-05-05

### 首次发布
- 基于 `book` 文档类的论文模板
- xeCJK 中文支持
- 格式规范：A4、1.5 倍行距、小四号正文
- 三线表、fbox 占位图模板
- `titlesec` 章节标题格式化
- `biblatex` 参考文献管理
- 孤行控制、浮动间距控制
- Windows 字体配置（SimSun、SimHei、STZhongsong）

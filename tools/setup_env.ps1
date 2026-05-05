<#
.SYNOPSIS
    LaTeX 论文环境一键部署脚本。
    检查依赖、复制模板、初始化 Git、安装 hook、创建进度记忆。
.PARAMETER TargetDir
    目标目录，默认当前目录。
.PARAMETER SkipEnvCheck
    跳过环境检查。
.PARAMETER InstallMiKTeX
    检测到缺 LaTeX 时直接调用 winget 安装 MiKTeX，不再交互询问。
#>

param(
    [string]$TargetDir = ".",
    [switch]$SkipEnvCheck,
    [switch]$InstallMiKTeX
)

function Write-OK   ($m) { Write-Host "[  OK  ] $m" -ForegroundColor Green }
function Write-MISS ($m) { Write-Host "[ MISS ] $m" -ForegroundColor Yellow }
function Write-ERR  ($m) { Write-Host "[ FAIL ] $m" -ForegroundColor Red }
function Write-INFO ($m) { Write-Host "[ INFO ] $m" -ForegroundColor Cyan }
function Write-STEP ($m) { Write-Host "`n>>> $m <<<" -ForegroundColor Magenta }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ========== 学习资源（缺东西时统一指向这里） ==========
$ResourceLatexProject = "https://www.latex-project.org/"
$ResourceTeXLive      = "https://tug.org/texlive/"
$ResourceMiKTeX       = "https://miktex.org/download"
$ResourceTutorialBili = "https://www.bilibili.com/video/BV1Yq66Y3EFq/"
$ResourceFontDoc      = "docs/font-setup.md"

function Show-LatexInstallGuide {
    Write-Host ""
    Write-INFO "LaTeX 安装指引："
    Write-Host "  Windows  推荐 MiKTeX：winget install --id MiKTeX.MiKTeX -e" -ForegroundColor Gray
    Write-Host "           或 TeX Live：$ResourceTeXLive  (体积大但更全)" -ForegroundColor Gray
    Write-Host "  macOS    MacTeX：     https://tug.org/mactex/" -ForegroundColor Gray
    Write-Host "  Linux    apt install texlive-full  /  pacman -S texlive-most" -ForegroundColor Gray
    Write-Host "  官网     $ResourceLatexProject" -ForegroundColor Gray
    Write-Host "  教学视频 $ResourceTutorialBili" -ForegroundColor Gray
}

function Test-CommandExists($name) {
    return [bool](Get-Command $name -ErrorAction SilentlyContinue)
}

function Invoke-MiKTeXWingetInstall {
    if (-not (Test-CommandExists "winget")) {
        Write-ERR "未找到 winget，无法自动安装。请手动从 $ResourceMiKTeX 下载安装。"
        return $false
    }
    Write-INFO "正在通过 winget 安装 MiKTeX（可能需要几分钟）……"
    & winget install --id MiKTeX.MiKTeX -e --accept-source-agreements --accept-package-agreements
    if ($LASTEXITCODE -eq 0) { Write-OK "MiKTeX 安装命令已完成（重开终端后生效）"; return $true }
    Write-ERR "winget 安装失败（exit=$LASTEXITCODE），请手动从 $ResourceMiKTeX 下载。"
    return $false
}

# ========== 1. 环境检查 ==========
if (-not $SkipEnvCheck) {
    Write-STEP "环境检查"

    # ---- LaTeX (xelatex) ----
    $hasXelatex = $false
    try {
        $ver = & xelatex --version 2>$null
        if ($ver -match "XeTeX") { Write-OK "TeX 引擎已安装（xelatex）"; $hasXelatex = $true }
        else { throw }
    } catch {
        Write-MISS "未检测到 xelatex（TeX Live / MiKTeX 都未装）"
        Show-LatexInstallGuide

        $shouldInstall = $InstallMiKTeX
        if (-not $shouldInstall) {
            $resp = Read-Host "现在用 winget 自动安装 MiKTeX？[y/N]"
            $shouldInstall = ($resp -match '^[Yy]')
        }
        if ($shouldInstall) { Invoke-MiKTeXWingetInstall | Out-Null }
        else { Write-INFO "已跳过自动安装。装好后重开终端再次运行本脚本。" }
    }

    # ---- biber（参考文献编译需要） ----
    if ($hasXelatex) {
        if (Test-CommandExists "biber") { Write-OK "biber 已安装（参考文献可正常编译）" }
        else {
            Write-MISS "未检测到 biber，参考文献链路 (\\cite) 会失败"
            Write-INFO "  -> MiKTeX 默认即装即用；TeX Live：tlmgr install biber"
        }
    }

    # ---- 中文字体 ----
    Write-Host ""
    Write-INFO "检查中文字体（模板默认使用 SimSun/SimHei/FangSong/STZhongsong）……"
    $required = @("SimSun", "SimHei", "FangSong", "STZhongsong")
    try {
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        $installed = (New-Object System.Drawing.Text.InstalledFontCollection).Families | ForEach-Object { $_.Name }
        $missing = @()
        foreach ($f in $required) {
            if ($installed -contains $f) { Write-OK "字体 $f" }
            else { Write-MISS "字体 $f 未安装"; $missing += $f }
        }
        if ($missing.Count -gt 0) {
            Write-Host ""
            Write-INFO "缺字体怎么办："
            Write-Host "  1. 详细方案见 $ResourceFontDoc（含 Linux/macOS 替代字体）" -ForegroundColor Gray
            Write-Host "  2. STZhongsong / FangSong 在精简版 Windows 常缺，可装 Office 自动补齐，" -ForegroundColor Gray
            Write-Host "     或临时把 setup/format.tex 里对应行替换为 SimSun / SimHei。" -ForegroundColor Gray
            Write-Host "  3. 只想凑合编译过：把缺失字体改成 SimSun，封面字号视觉略变但不影响内容。" -ForegroundColor Gray
        }
    } catch {
        Write-MISS "无法枚举系统字体（$($_.Exception.Message)）；跳过字体检查"
    }

    # ---- VS Code ----
    Write-Host ""
    if (Test-CommandExists "code") {
        Write-OK "VS Code 已安装"
        $exts = & code --list-extensions 2>$null
        if ($exts -match "latex-workshop") { Write-OK "LaTeX Workshop 插件已安装" }
        else { Write-MISS "LaTeX Workshop 插件未安装"; Write-INFO "  -> code --install-extension James-Yu.latex-workshop" }
    } else { Write-MISS "VS Code 未安装"; Write-INFO "  -> winget install --id Microsoft.VisualStudioCode -e" }

    # ---- Git ----
    if (Test-CommandExists "git") { Write-OK "Git 已安装" }
    else { Write-MISS "Git 未安装"; Write-INFO "  -> winget install --id Git.Git -e" }

    Write-Host ""
    Write-INFO "新手推荐先看 B 站教学视频：$ResourceTutorialBili"
} else { Write-INFO "跳过环境检查" }

# ========== 2. 确定目标目录 ==========
$Target = Resolve-Path -Path $TargetDir -ErrorAction SilentlyContinue
if (-not $Target) { New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null; $Target = Resolve-Path $TargetDir }
Write-STEP "部署到: $Target"

# ========== 3. 复制 thesis-template ==========
$TemplateDir = Resolve-Path (Join-Path $ScriptDir "..\thesis-template")
if (-not (Test-Path $TemplateDir)) { Write-ERR "未找到 thesis-template 目录（预期: $TemplateDir）"; exit 1 }

Write-STEP "复制论文模板文件"
Copy-Item -Path "$TemplateDir\*" -Destination $Target -Recurse -Force
Write-OK "模板文件已复制"

# ========== 4. 初始化 Git ==========
Write-STEP "Git 初始化"
if (-not (Test-Path (Join-Path $Target ".git"))) {
    Push-Location $Target; git init | Out-Null; Pop-Location
    Write-OK "Git 仓库已初始化"
} else { Write-INFO "Git 仓库已存在，跳过" }

# ========== 5. 论文进度记忆 ==========
Write-STEP "论文进度记忆"
$MemoryFile = Join-Path $Target ".claude\thesis_progress.md"
if (Test-Path $MemoryFile) { Write-INFO "进度记忆文件已存在，保留现有记录" }
else { Write-OK "进度记忆文件已创建（.claude/thesis_progress.md）" }

# ========== 6. 安装 pre-commit hook ==========
Write-STEP "安装 Git pre-commit hook"
$HookSrc = Join-Path $ScriptDir "..\.githooks\pre-commit"
$HookDst = Join-Path $Target ".git\hooks\pre-commit"
if (Test-Path $HookSrc) { Copy-Item $HookSrc $HookDst -Force; Write-OK "pre-commit 已安装" }
else { Write-MISS "未找到 pre-commit: $HookSrc" }

# ========== 7. 复制 VS Code 配置 ==========
Write-STEP "VS Code 配置"
$VscodeSrc = Join-Path $ScriptDir "..\.vscode"
$VscodeDst = Join-Path $Target ".vscode"
if (Test-Path $VscodeSrc) {
    if (-not (Test-Path $VscodeDst)) { New-Item -Path $VscodeDst -ItemType Directory -Force | Out-Null }
    Copy-Item "$VscodeSrc\*" $VscodeDst -Force; Write-OK "VS Code 配置已复制"
} else { Write-MISS "未找到 .vscode 目录" }

# ========== 完成 ==========
Write-STEP "部署完成"
Write-OK "目标目录: $Target"
Write-OK "接下来: cd $Target && code ."
Write-OK "每次修改 .tex 前: pwsh tools/check_thesis.ps1"
Write-INFO "教学视频：$ResourceTutorialBili"

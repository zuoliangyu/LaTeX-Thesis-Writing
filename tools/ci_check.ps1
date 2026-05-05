<#
.SYNOPSIS
    在本机 Docker 里跑 GitHub Actions compile-check.yml 的全部步骤，
    用来在 push 前提早发现 CI 会挂的字体/编码/引用问题。

.DESCRIPTION
    首次运行会构建一个名为 latex-thesis-ci:latest 的镜像（基于 ubuntu:24.04 +
    .github/workflows/compile-check.yml 里的 apt 包列表），后续运行复用 Docker
    层缓存，只跑编译，几十秒级。

.PARAMETER Rebuild
    强制重建镜像（apt 源/包列表更新后用）。

.PARAMETER KeepArtifacts
    不在容器退出后清理 thesis-template/ 下的 .aux/.log 等中间产物。
    默认会清理，避免污染本地工作树。

.EXAMPLE
    pwsh tools/ci_check.ps1
    pwsh tools/ci_check.ps1 -Rebuild
#>

param(
    [switch]$Rebuild,
    [switch]$KeepArtifacts
)

$ErrorActionPreference = 'Stop'

function Write-OK   ($m) { Write-Host "[  OK  ] $m" -ForegroundColor Green }
function Write-ERR  ($m) { Write-Host "[ FAIL ] $m" -ForegroundColor Red }
function Write-INFO ($m) { Write-Host "[ INFO ] $m" -ForegroundColor Cyan }
function Write-STEP ($m) { Write-Host "`n>>> $m <<<" -ForegroundColor Magenta }

# ---------- 1. 检查 docker ----------
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-ERR "未找到 docker。请先安装 Docker Desktop：https://www.docker.com/products/docker-desktop/"
    exit 1
}
try { docker info --format '{{.ServerVersion}}' | Out-Null } catch {
    Write-ERR "docker 命令存在但 daemon 没跑。打开 Docker Desktop 后再试。"
    exit 1
}

# ---------- 2. 定位仓库根 ----------
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = Resolve-Path (Join-Path $ScriptDir "..")
Write-STEP "仓库根: $RepoRoot"

# ---------- 3. 构建镜像 ----------
$ImageTag = "latex-thesis-ci:latest"
$NeedBuild = $Rebuild -or -not (docker images -q $ImageTag)

if ($NeedBuild) {
    Write-STEP "构建镜像 $ImageTag（首次约 5-10 分钟，之后命中缓存秒级）"
    $Dockerfile = @'
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    texlive-xetex \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-fonts-extra \
    texlive-lang-chinese \
    texlive-bibtex-extra \
    biber \
    fonts-noto-cjk \
    fonts-noto-cjk-extra \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /repo/thesis-template
'@
    $tmp = New-TemporaryFile
    Set-Content -Path $tmp -Value $Dockerfile -Encoding ASCII
    try {
        docker build -t $ImageTag -f $tmp $ScriptDir
        if ($LASTEXITCODE -ne 0) { Write-ERR "镜像构建失败"; exit 1 }
        Write-OK "镜像就绪"
    } finally { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
} else {
    Write-INFO "镜像 $ImageTag 已存在，跳过构建（要重建用 -Rebuild）"
}

# ---------- 4. 容器内执行 CI 步骤 ----------
Write-STEP "容器内编译 thesis.tex（复刻 .github/workflows/compile-check.yml）"

$ciScript = @'
set -e
echo "=== 1) xelatex pass 1 ==="
xelatex -interaction=nonstopmode -file-line-error thesis.tex >/tmp/p1.log 2>&1 || { tail -50 /tmp/p1.log; exit 1; }
echo "=== 2) biber ==="
biber thesis
echo "=== 3) xelatex pass 2 ==="
xelatex -interaction=nonstopmode -file-line-error thesis.tex >/tmp/p2.log 2>&1 || { tail -50 /tmp/p2.log; exit 1; }
echo "=== 4) xelatex pass 3 ==="
xelatex -interaction=nonstopmode -file-line-error thesis.tex >/tmp/p3.log 2>&1 || { tail -50 /tmp/p3.log; exit 1; }

echo ""
echo "=== font picks (thesis-fonts package log) ==="
grep "thesis-fonts" thesis.log || echo "(no font-picker messages — using defaults)"

echo ""
echo "=== undefined references check ==="
if grep -q "??" thesis.aux; then
  echo "ERROR: undefined references"
  grep "??" thesis.aux
  exit 1
fi
echo "all references resolved"

echo ""
echo "=== Overfull boxes: $(grep -c Overfull thesis.log || echo 0) ==="
echo "=== Font warnings: $(grep -c 'Font Warning' thesis.log || echo 0) ==="

if [ -f thesis.pdf ]; then
  echo "OK: thesis.pdf size=$(du -h thesis.pdf | cut -f1)"
else
  echo "ERROR: thesis.pdf not generated"; exit 1
fi
'@

# 多行 bash 字符串经 Windows 命令行传给 docker 会丢换行，把脚本落到临时文件
# 后挂进容器再执行，更稳。脚本必须用 LF（容器里 bash 不接受 CRLF）。
$scriptHostPath = Join-Path $env:TEMP "thesis_ci_$(Get-Random).sh"
$lfScript = $ciScript -replace "`r`n", "`n" -replace "`r", "`n"
[System.IO.File]::WriteAllText($scriptHostPath, $lfScript, (New-Object System.Text.UTF8Encoding($false)))
try {
    docker run --rm `
        -v "${RepoRoot}:/repo" `
        -v "${scriptHostPath}:/ci.sh:ro" `
        -w /repo/thesis-template `
        $ImageTag `
        bash /ci.sh
    $exit = $LASTEXITCODE
} finally { Remove-Item $scriptHostPath -Force -ErrorAction SilentlyContinue }

# ---------- 5. 清理中间产物 ----------
if (-not $KeepArtifacts) {
    Write-STEP "清理编译中间产物（保留 thesis.pdf）"
    $junk = @('*.aux','*.bbl','*.bcf','*.blg','*.log','*.out','*.run.xml','*.synctex.gz','*.toc','*.lof','*.lot')
    Get-ChildItem -Path "$RepoRoot\thesis-template" -Recurse -Include $junk -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-OK "已清理"
}

# ---------- 6. 总结 ----------
if ($exit -eq 0) {
    Write-STEP "CI 模拟通过 ✓"
    Write-OK "本地 Docker 跑了一遍 .github/workflows/compile-check.yml 的所有步骤，结果与 GitHub Actions 一致。"
    exit 0
} else {
    Write-STEP "CI 模拟失败 ✗"
    Write-ERR "退出码 $exit。修完后再 push，避免 GitHub Actions 红灯。"
    exit $exit
}

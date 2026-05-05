<#
.SYNOPSIS
    LaTeX thesis format pre-check script
    Run before editing .tex files to ensure formatting is correct.
.PARAMETER Path
    .tex file or directory to check. Default: recursive scan of ./chapters + thesis.tex.
.PARAMETER Fix
    If specified, auto-fix fixable issues (e.g. BOM removal).
#>

param(
    [string]$Path = ".",
    [switch]$Fix
)

$ErrorCount = 0
$WarnCount  = 0

function Write-ErrorMsg($file, $msg) {
    $script:ErrorCount++
    Write-Host "[FAIL] ${file}: $msg" -ForegroundColor Red
}

function Write-WarningMsg($file, $msg) {
    $script:WarnCount++
    Write-Host "[WARN] ${file}: $msg" -ForegroundColor Yellow
}

function Write-Pass($msg) {
    Write-Host "[PASS] $msg" -ForegroundColor Green
}

# ---------- Collect files ----------
$Files = @()
if (Test-Path -Path $Path -PathType Container) {
    $Files += Get-ChildItem -Path $Path -Filter "*.tex" -Recurse -File
    if (Test-Path "thesis.tex") {
        $Files += Get-Item "thesis.tex"
    }
} else {
    $Files += Get-Item $Path
}

$Files = $Files | Where-Object { $_.Extension -eq ".tex" -and $_.Name -notmatch "^_" } | Sort-Object FullName -Unique

if ($Files.Count -eq 0) {
    Write-Host "[SKIP] No .tex files found." -ForegroundColor Cyan
    exit 0
}

Write-Host "`n========== LaTeX Format Pre-check ==========" -ForegroundColor Cyan
Write-Host "Files: $($Files.Count)`n" -ForegroundColor Cyan

foreach ($File in $Files) {
    $RelPath = $File.FullName
    $Content = Get-Content -Path $File.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue

    if (-not $Content) {
        Write-ErrorMsg $RelPath "Cannot read file"
        continue
    }

    # ---- 1. Encoding check ----
    try {
        $bytes = [System.IO.File]::ReadAllBytes($File.FullName)
        if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            Write-WarningMsg $RelPath "UTF-8 BOM detected"
            if ($Fix) {
                $trimmed = [System.Text.Encoding]::UTF8.GetString($bytes[3..($bytes.Length-1)])
                [System.IO.File]::WriteAllText($File.FullName, $trimmed, [System.Text.Encoding]::UTF8)
                Write-Pass "BOM removed"
            }
        }
    } catch {
        Write-WarningMsg $RelPath "Encoding check failed"
    }

    # ---- 2. Brace matching ----
    $openBraces = 0
    $inComment = $false
    for ($i = 0; $i -lt $Content.Length; $i++) {
        $ch = $Content[$i]
        if ($ch -eq '%' -and -not ($i -gt 0 -and $Content[$i-1] -eq '\')) {
            $inComment = $true; continue
        }
        if ($inComment -and $ch -eq "`n") { $inComment = $false; continue }
        if ($inComment) { continue }
        if ($ch -eq '{' -and -not ($i -gt 0 -and $Content[$i-1] -eq '\')) {
            $openBraces++
        }
        elseif ($ch -eq '}' -and -not ($i -gt 0 -and $Content[$i-1] -eq '\')) {
            $openBraces--
        }
    }
    if ($openBraces -gt 0) {
        Write-ErrorMsg $RelPath "Unmatched braces: ${openBraces} excess {"
    } elseif ($openBraces -lt 0) {
        Write-ErrorMsg $RelPath "Unmatched braces: $([Math]::Abs($openBraces)) excess }"
    }

    # ---- 3. Environment matching ----
    $envStack = @()
    $envMatches = [Regex]::Matches($Content, '\\(begin|end)\{(\w+)\}')
    foreach ($m in $envMatches) {
        $keyword = $m.Groups[1].Value
        $envName = $m.Groups[2].Value
        if ($keyword -eq "begin") {
            $envStack += $envName
        } else {
            if ($envStack.Count -eq 0) {
                Write-ErrorMsg $RelPath "Extra \end{$envName}"
            } else {
                $last = $envStack[-1]
                if ($last -ne $envName) {
                    Write-ErrorMsg $RelPath "Nesting error: \begin{$last} closed by \end{$envName}"
                }
                if ($envStack.Count -le 1) { $envStack = @() } else { $envStack = $envStack[0..($envStack.Count-2)] }
            }
        }
    }
    if ($envStack.Count -gt 0) {
        Write-ErrorMsg $RelPath "Unclosed environments: $($envStack -join ', ')"
    }

    # ---- 4. Label format ----
    $labels = [Regex]::Matches($Content, '\\label\{([^}]+)\}')
    foreach ($lbl in $labels) {
        $name = $lbl.Groups[1].Value
        if ($name -notmatch '^(eq|fig|tab|ch|sec|lst|alg):') {
            Write-WarningMsg $RelPath "Label missing prefix: $name"
        }
        $refPath = [regex]::Escape($name)
        $refCount = [Regex]::Matches($Content, "\\ref\{${refPath}\}").Count
        if ($refCount -eq 0) {
            Write-WarningMsg $RelPath "Label defined but never referenced: $name"
        }
    }

    # ---- 5. Empty cite/ref ----
    $emptyCite = [Regex]::Matches($Content, '\\cite\{\s*\}')
    if ($emptyCite.Count -gt 0) {
        Write-ErrorMsg $RelPath "Empty cite found: $($emptyCite.Count) occurrence(s)"
    }
    $emptyRef = [Regex]::Matches($Content, '\\ref\{\s*\}')
    if ($emptyRef.Count -gt 0) {
        Write-ErrorMsg $RelPath "Empty ref found: $($emptyRef.Count) occurrence(s)"
    }

    # ---- 6. Missing caption check ----
    $figCount = [Regex]::Matches($Content, '\\includegraphics').Count
    $capCount = [Regex]::Matches($Content, '\\caption').Count
    if ($figCount -gt 0 -and $capCount -eq 0) {
        Write-WarningMsg $RelPath "Has \includegraphics but no \caption"
    }
}

# ---------- Global check ----------
Write-Host "`n========== Global Check ==========" -ForegroundColor Cyan

if (Test-Path "thesis.tex") {
    $MainContent = Get-Content "thesis.tex" -Raw -Encoding UTF8

    $allRefs = [Regex]::Matches($MainContent, '\\ref\{([^}]+)\}')
    $allLabels = [Regex]::Matches($MainContent, '\\label\{([^}]+)\}')
    $labelSet = @{}
    foreach ($l in $allLabels) { $labelSet[$l.Groups[1].Value] = $true }

    foreach ($r in $allRefs) {
        $refName = $r.Groups[1].Value
        if (-not $labelSet.ContainsKey($refName)) {
            $found = $false
            foreach ($f in $Files) {
                $subContent = Get-Content -Path $f.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                if ($subContent -match "\\label\{$([regex]::Escape($refName))\}") {
                    $found = $true
                    break
                }
            }
            if (-not $found) {
                Write-WarningMsg "thesis.tex" "\ref{$refName} has no matching \label"
            }
        }
    }

    Write-Pass "Main file has $($allLabels.Count) labels"

    if ($MainContent -notmatch '\\end\{document\}') {
        Write-ErrorMsg "thesis.tex" "Missing \end{document}"
    }
} else {
    Write-WarningMsg "" "thesis.tex not found"
}

# ---------- Summary ----------
Write-Host "`n========== Summary ==========" -ForegroundColor Cyan
if ($ErrorCount -eq 0 -and $WarnCount -eq 0) {
    Write-Pass "All checks passed"
} else {
    $color = if ($ErrorCount -gt 0) { "Red" } else { "Yellow" }
    Write-Host "Errors: $ErrorCount    Warnings: $WarnCount" -ForegroundColor $color
    if ($ErrorCount -gt 0) {
        exit 1
    }
}

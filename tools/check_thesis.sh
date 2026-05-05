#!/bin/bash
#===============================================================================
# LaTeX 论文格式预检脚本 (Bash)
# 检查: 花括号配对、环境配对、空引用、主文件完整性
# 用法: ./check_thesis.sh [path]
#===============================================================================
set -euo pipefail

ERRORS=0
WARNS=0

# ---------- 收集 .tex 文件 ----------
TARGET="${1:-thesis-template}"
FILES=()

if [ -d "$TARGET" ]; then
    while IFS= read -r -d '' f; do
        FILES+=("$f")
    done < <(find "$TARGET" -name "*.tex" -type f -print0 2>/dev/null)
else
    FILES+=("$TARGET")
fi

if [ ${#FILES[@]} -eq 0 ]; then
    echo "[SKIP] 未找到 .tex 文件"
    exit 0
fi

echo ""
echo "========== LaTeX 格式预检 =========="
echo "文件数: ${#FILES[@]}"
echo ""

# ---------- 逐文件检查 ----------
for FILE in "${FILES[@]}"; do
    if [ ! -r "$FILE" ]; then
        echo "[FAIL] $FILE: 无法读取"
        ERRORS=$((ERRORS + 1))
        continue
    fi

    CONTENT=$(cat "$FILE")

    # ---- 1. 花括号 {} 配对 ----
    # 简化版：去除注释行和 \{ \} 转义后计数
    CLEANED=$(echo "$CONTENT" | sed 's/%.*$//g' | sed 's/\\{//g' | sed 's/\\}//g')
    OPEN=$(echo "$CLEANED" | grep -o '{' | wc -l)
    CLOSE=$(echo "$CLEANED" | grep -o '}' | wc -l)
    if [ "$OPEN" -ne "$CLOSE" ]; then
        DIFF=$((OPEN - CLOSE))
        if [ "$DIFF" -gt 0 ]; then
            echo "[FAIL] $FILE: 花括号未配对 — 多出 $DIFF 个 {"
        else
            echo "[FAIL] $FILE: 花括号未配对 — 多出 $((0 - DIFF)) 个 }"
        fi
        ERRORS=$((ERRORS + 1))
    fi

    # ---- 2. begin/end 环境配对 ----
    BEGINS=$(echo "$CONTENT" | grep -oP '\\begin\{(\w+)\}' | wc -l)
    ENDS=$(echo "$CONTENT" | grep -oP '\\end\{(\w+)\}' | wc -l)
    if [ "$BEGINS" -ne "$ENDS" ]; then
        echo "[FAIL] $FILE: begin/end 环境不匹配"
        ERRORS=$((ERRORS + 1))
    fi

    # ---- 3. 空引用检查 ----
    EMPTY_CITE=$(echo "$CONTENT" | grep -cP '\\cite\{\s*\}' || true)
    if [ "$EMPTY_CITE" -gt 0 ]; then
        echo "[FAIL] $FILE: 存在 $EMPTY_CITE 个空 \\cite{}"
        ERRORS=$((ERRORS + 1))
    fi

    EMPTY_REF=$(echo "$CONTENT" | grep -cP '\\ref\{\s*\}' || true)
    if [ "$EMPTY_REF" -gt 0 ]; then
        echo "[FAIL] $FILE: 存在 $EMPTY_REF 个空 \\ref{}"
        ERRORS=$((ERRORS + 1))
    fi

    # ---- 4. \end{document} 检查 ----
    if echo "$FILE" | grep -q "thesis.tex"; then
        if ! echo "$CONTENT" | grep -qP '\\end\{document\}'; then
            echo "[FAIL] $FILE: 缺少 \\end{document}"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

# ---------- 汇总 ----------
echo ""
echo "========== 检查汇总 =========="
if [ "$ERRORS" -eq 0 ] && [ "$WARNS" -eq 0 ]; then
    echo "[PASS] 全部通过，格式正确"
else
    echo "错误: $ERRORS    警告: $WARNS"
    if [ "$ERRORS" -gt 0 ]; then
        echo "存在 $ERRORS 个错误，请修复后重新编译"
        exit 1
    fi
fi

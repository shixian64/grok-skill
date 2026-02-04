#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SKILL_NAME="grok-search"

# 默认安装目标
TARGET="claude"

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --codex)
            TARGET="codex"
            shift
            ;;
        --claude)
            TARGET="claude"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--claude|--codex]"
            echo ""
            echo "Options:"
            echo "  --claude    Install to ~/.claude/skills/ (default)"
            echo "  --codex     Install to ~/.codex/skills/"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# 根据目标设置路径
if [[ "$TARGET" == "codex" ]]; then
    DEST_ROOT="$HOME/.codex/skills"
else
    DEST_ROOT="$HOME/.claude/skills"
fi

DEST="$DEST_ROOT/$SKILL_NAME"

mkdir -p "$DEST_ROOT"

# 保留现有配置文件（兼容 Bash 3.x，不使用关联数组）
PRESERVE_CONFIG=""
PRESERVE_LOCAL=""

if [[ -f "$DEST/config.json" ]]; then
    PRESERVE_CONFIG="$(cat "$DEST/config.json")"
fi
if [[ -f "$DEST/config.local.json" ]]; then
    PRESERVE_LOCAL="$(cat "$DEST/config.local.json")"
fi

# 删除旧安装
if [[ -d "$DEST" ]]; then
    rm -rf "$DEST"
fi

mkdir -p "$DEST"

# 根据操作系统选择 SKILL.md
if [[ -f "$REPO_ROOT/SKILL.linux.md" ]]; then
    cp -f "$REPO_ROOT/SKILL.linux.md" "$DEST/SKILL.md"
else
    cp -f "$REPO_ROOT/SKILL.md" "$DEST/"
fi
cp -f "$REPO_ROOT/README.md" "$DEST/"
cp -f "$REPO_ROOT/install.sh" "$DEST/"
cp -f "$REPO_ROOT/configure.sh" "$DEST/" 2>/dev/null || true
cp -f "$REPO_ROOT/install.ps1" "$DEST/" 2>/dev/null || true
cp -f "$REPO_ROOT/configure.ps1" "$DEST/" 2>/dev/null || true
cp -f "$REPO_ROOT/config.json" "$DEST/"
cp -rf "$REPO_ROOT/scripts" "$DEST/"

# 恢复保留的配置文件（使用安全权限）
if [[ -n "$PRESERVE_CONFIG" ]]; then
    (
        umask 077
        echo "$PRESERVE_CONFIG" > "$DEST/config.json"
    )
    chmod 600 "$DEST/config.json"
fi
if [[ -n "$PRESERVE_LOCAL" ]]; then
    (
        umask 077
        echo "$PRESERVE_LOCAL" > "$DEST/config.local.json"
    )
    chmod 600 "$DEST/config.local.json"
fi

echo "Installed to: $DEST"
echo ""
echo "Next steps:"
echo "  1. Run: $DEST/configure.sh"
echo "  2. Or set environment variables: GROK_BASE_URL, GROK_API_KEY"

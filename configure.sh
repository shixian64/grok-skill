#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GLOBAL=false
TARGET=""

# 自动检测当前安装位置
detect_target() {
    if [[ "$SCRIPT_DIR" == *"/.claude/"* ]]; then
        echo "claude"
    elif [[ "$SCRIPT_DIR" == *"/.codex/"* ]]; then
        echo "codex"
    else
        echo "claude"  # 默认
    fi
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -g|--global)
            GLOBAL=true
            shift
            ;;
        --codex)
            TARGET="codex"
            shift
            ;;
        --claude)
            TARGET="claude"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [-g|--global] [--claude|--codex]"
            echo ""
            echo "Options:"
            echo "  -g, --global    Write to user-level config"
            echo "  --claude        Use ~/.claude/ paths"
            echo "  --codex         Use ~/.codex/ paths"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# 如果未指定目标，自动检测
if [[ -z "$TARGET" ]]; then
    TARGET="$(detect_target)"
fi

# 确定配置文件路径
resolve_config_path() {
    if [[ -n "${GROK_CONFIG_PATH:-}" ]]; then
        echo "${GROK_CONFIG_PATH}"
        return
    fi

    local base_dir
    if [[ "$TARGET" == "codex" ]]; then
        base_dir="$HOME/.codex"
    else
        base_dir="$HOME/.claude"
    fi

    if [[ "$GLOBAL" == "true" ]]; then
        echo "$base_dir/config/grok-search.json"
    else
        echo "$SCRIPT_DIR/config.json"
    fi
}

CONFIG_PATH="$(resolve_config_path)"
CONFIG_DIR="$(dirname "$CONFIG_PATH")"
mkdir -p "$CONFIG_DIR"

# 读取现有配置
EXISTING_BASE_URL=""
EXISTING_API_KEY=""
EXISTING_MODEL=""
EXISTING_TIMEOUT=""

if [[ -f "$CONFIG_PATH" ]]; then
    EXISTING_BASE_URL="$(grep -o '"base_url"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_PATH" 2>/dev/null | sed 's/.*"\([^"]*\)"$/\1/' || true)"
    EXISTING_API_KEY="$(grep -o '"api_key"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_PATH" 2>/dev/null | sed 's/.*"\([^"]*\)"$/\1/' || true)"
    EXISTING_MODEL="$(grep -o '"model"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_PATH" 2>/dev/null | sed 's/.*"\([^"]*\)"$/\1/' || true)"
    EXISTING_TIMEOUT="$(grep -o '"timeout_seconds"[[:space:]]*:[[:space:]]*[0-9]*' "$CONFIG_PATH" 2>/dev/null | sed 's/.*:[[:space:]]*//' || true)"
fi

# 带默认值的输入函数
read_default() {
    local prompt="$1"
    local default="$2"
    local suffix=""
    if [[ -n "$default" ]]; then
        suffix=" [$default]"
    fi
    read -rp "$prompt$suffix: " value
    if [[ -z "$value" ]]; then
        echo "$default"
    else
        echo "$value"
    fi
}

# JSON 字符串转义函数
json_escape() {
    local str="$1"
    # 转义反斜杠、双引号、控制字符
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    str="${str//$'\n'/\\n}"
    str="${str//$'\r'/\\r}"
    str="${str//$'\t'/\\t}"
    echo "$str"
}

# 验证数字
validate_number() {
    local value="$1"
    local default="$2"
    # 移除非数字字符，只保留数字
    local num
    num="$(echo "$value" | tr -cd '0-9')"
    if [[ -z "$num" ]]; then
        echo "$default"
    else
        echo "$num"
    fi
}

# 交互式配置
echo "Grok Search Configuration"
echo "========================="
echo "Target: $TARGET"
echo ""

BASE_URL="$(read_default "Grok base URL" "$EXISTING_BASE_URL")"
if [[ -z "$BASE_URL" ]]; then
    BASE_URL="https://your-grok-endpoint.example"
fi

API_KEY="$(read_default "Grok API key" "$EXISTING_API_KEY")"

MODEL="$(read_default "Model" "$EXISTING_MODEL")"
if [[ -z "$MODEL" ]]; then
    MODEL="grok-2-latest"
fi

TIMEOUT_INPUT="$(read_default "Timeout seconds" "$EXISTING_TIMEOUT")"
TIMEOUT="$(validate_number "$TIMEOUT_INPUT" "60")"

# 转义字符串值
BASE_URL_ESCAPED="$(json_escape "$BASE_URL")"
API_KEY_ESCAPED="$(json_escape "$API_KEY")"
MODEL_ESCAPED="$(json_escape "$MODEL")"

# 设置安全的 umask 并写入配置文件
(
    umask 077
    cat > "$CONFIG_PATH" << EOF
{
  "base_url": "$BASE_URL_ESCAPED",
  "api_key": "$API_KEY_ESCAPED",
  "model": "$MODEL_ESCAPED",
  "timeout_seconds": $TIMEOUT,
  "extra_body": {},
  "extra_headers": {}
}
EOF
)

# 确保文件权限安全
chmod 600 "$CONFIG_PATH"

echo ""
echo "Wrote config: $CONFIG_PATH"

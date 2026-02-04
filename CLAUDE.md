# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

grok-search 是一个 Codex/Claude 技能插件，通过 OpenAI 兼容的 Grok API 端点实现实时网络搜索。输出结构化 JSON，包含 `content`（综合答案）和 `sources`（来源 URL 列表）。

## Commands

### 执行搜索
```bash
python scripts/grok_search.py --query "搜索内容"
```

### 可选参数
- `--config`: 指定配置文件路径
- `--base-url`: 覆盖 API 端点
- `--api-key`: 覆盖 API 密钥
- `--model`: 覆盖模型名称
- `--timeout-seconds`: 请求超时时间
- `--extra-body-json`: 额外的请求体 JSON
- `--extra-headers-json`: 额外的请求头 JSON

## Architecture

核心实现在 `scripts/grok_search.py`，是一个独立的 Python 脚本，无外部依赖（仅使用标准库）。

### 配置优先级（从高到低）
1. 命令行参数
2. 环境变量 (`GROK_BASE_URL`, `GROK_API_KEY`, `GROK_MODEL`, `GROK_TIMEOUT_SECONDS`)
3. `config.local.json`（gitignored，用于存储敏感信息）
4. `config.json`（默认配置模板）
5. `~/.codex/config/grok-search.json`（用户级配置）

### API 调用
- 端点: `POST {base_url}/v1/chat/completions`
- 脚本会自动处理 base_url 末尾的 `/v1` 后缀

### 输出格式
```json
{
  "ok": true,
  "content": "综合答案",
  "sources": [{"url": "...", "title": "...", "snippet": "..."}],
  "raw": "原始响应（解析失败时）"
}
```

## Configuration

敏感信息（如 `api_key`）应放在 `config.local.json` 中，该文件已被 gitignore。

环境变量：
- `GROK_BASE_URL`: API 端点
- `GROK_API_KEY`: API 密钥
- `GROK_MODEL`: 模型名称（默认 `grok-2-latest`）
- `GROK_TIMEOUT_SECONDS`: 超时秒数（默认 60）
- `GROK_EXTRA_BODY_JSON`: 额外请求体
- `GROK_EXTRA_HEADERS_JSON`: 额外请求头

# grok-search (Codex skill)

Aggressive web research tool for Codex via your OpenAI-compatible Grok endpoint (2api).

---

## English

### What it does

- Runs a web research query through `POST /v1/chat/completions`
- Returns machine-readable JSON: `content` + `sources` (URLs when available)

### Install

Copy this repo to your Codex skills directory:

- `C:\Users\<you>\.codex\skills\grok-search\`

Or run:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### Configure

Edit the skill config:

- `C:\Users\<you>\.codex\skills\grok-search\config.json`

Fields:

- `base_url`: your endpoint base URL (e.g. `https://your-grok-endpoint.example`)
- `api_key`: your key (DO NOT commit real keys)
- `model`: model name

Optional (recommended for secrets): create `config.local.json` next to `config.json` (it is gitignored) and put your real `api_key` there.

You can also configure via env vars:

```powershell
$env:GROK_BASE_URL="https://your-grok-endpoint.example"
$env:GROK_API_KEY="YOUR_API_KEY"
$env:GROK_MODEL="grok-2-latest"
```

### Use

```bash
python scripts/grok_search.py --query "Search the web: latest stable version of <package> and release notes. Return sources."
```

### Make Codex call it

Add a global rule in `C:\Users\<you>\.codex\AGENTS.md` to call `grok-search` whenever info might be outdated/uncertain.

---

## 中文

### 这是什么

- 通过你自己的 OpenAI 兼容 Grok 接口（2api）做“激进联网检索”
- 输出结构化 JSON（`content` + `sources`），主要给 Codex 内部作为证据/上下文使用

### 安装

把本仓库复制到你的 Codex skills 目录：

- `C:\Users\<你>\.codex\skills\grok-search\`

或者运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### 配置

直接编辑：

- `C:\Users\<你>\.codex\skills\grok-search\config.json`

字段含义：

- `base_url`：你的接口地址（例如 `https://your-grok-endpoint.example`）
- `api_key`：你的密钥（不要提交到 Git）
- `model`：模型名

更安全的做法：在同目录创建 `config.local.json`（已在 `.gitignore` 里忽略），把真实 `api_key` 放进去。

也可以用环境变量：

```powershell
$env:GROK_BASE_URL="https://your-grok-endpoint.example"
$env:GROK_API_KEY="YOUR_API_KEY"
$env:GROK_MODEL="grok-2-latest"
```

### 使用

```bash
python scripts/grok_search.py --query "用英文描述检索任务，并要求返回来源链接"
```

### 让 Codex 自动用它

在 `C:\Users\<你>\.codex\AGENTS.md` 加一条全局规则：只要信息可能过时/不确定，就先调用 `grok-search` 再继续推理/写代码。

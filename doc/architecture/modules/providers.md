# Providers 模块

> 职责：统一 LLM 后端接入，按配置自动选择 Provider，屏蔽模型差异。

## 关键文件

- `providers/base.py`
- `providers/registry.py`
- `providers/factory.py`
- `providers/openai_compat_provider.py`
- `providers/anthropic_provider.py`
- `providers/azure_openai_provider.py`
- `providers/bedrock_provider.py`
- `providers/github_copilot_provider.py`
- `providers/openai_codex_provider.py`
- `providers/fallback_provider.py`

## 核心抽象

| 类 / 结构 | 职责 |
|---|---|
| `LLMProvider` | 统一 Provider 基类，定义 `chat`、`stream`、`get_default_model` |
| `LLMResponse` | 模型返回：content、tool_calls、usage、reasoning |
| `ToolCallRequest` | 模型请求的工具调用 |
| `ProviderRegistry` | Provider 元数据注册表，按名称/backend 查找 |
| `ProviderFactory` | 从 `Config` 创建具体 Provider 实例 |
| `FallbackProvider` | 主 Provider 失败时自动切换到备用 |

## Provider 选择流程

1. 读取 `agents.defaults.provider` 或 preset provider
2. 匹配 `ProviderRegistry` 中的 spec
3. 按 API Key 前缀、api_base 推断 provider
4. 本地 provider fallback（api_base 配置时）
5. Gateway fallback（可路由的模型族）

## 关键设计

- **统一接口**：所有 Provider 都实现 `LLMProvider.chat`，Runner 不感知后端差异。
- **配置驱动**：`config/schema.py` 中 `ProviderConfig` 描述每个后端的 apiKey、apiBase、extraHeaders 等。
- **Fallback 支持**：`FallbackProvider` 包装主 Provider，失败时自动切换，提升可用性。

## 代表实现

| Provider | 特点 |
|---|---|
| `OpenAICompatProvider` | 兼容 OpenAI 接口，支持 spec 定制 |
| `AnthropicProvider` | 原生 Anthropic 协议 |
| `AzureOpenAIProvider` | Azure AD / Key 认证 |
| `BedrockProvider` | AWS Bedrock，支持 region / profile |
| `GitHubCopilotProvider` | Copilot 专用路由 |
| `OpenAICodexProvider` | Codex CLI 协议 |

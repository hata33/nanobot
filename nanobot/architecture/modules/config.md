# Config 模块

> 职责：配置加载、校验、环境变量插值与路径管理。

## 关键文件

- `config/schema.py`
- `config/loader.py`
- `config/paths.py`

## 核心类

| 类 | 职责 |
|---|---|
| `Config` | Pydantic 根配置模型，camelCase / snake_case 兼容 |
| `AgentDefaults` | Agent 默认参数（maxIterations、contextWindow 等） |
| `ProviderConfig` | 单个 Provider 配置 |
| `ChannelsConfig` | 渠道配置 |
| `ToolsConfig` | 工具配置 |
| `ConfigLoader` | 从文件 / 环境变量加载配置 |

## 配置路径

| 配置 | 默认位置 |
|---|---|
| 主配置 | `~/.nanobot/config.json` |
| Workspace | `~/.nanobot/workspace/` |
| 会话 | `<workspace>/sessions/*.jsonl` |
| 记忆 | `<workspace>/memory/` |
| Cron | `<workspace>/cron/jobs.json` |
| WebUI 数据 | config 目录下 `webui/`、`media/`、`logs/` |

## 关键设计

- **双格式键**：JSON 用 camelCase，Python 代码用 snake_case，Pydantic 自动映射。
- **环境变量插值**：`${ENV_VAR}` 语法支持在配置中引用环境变量。
- **配置即代码**：`Config` 对象驱动 Provider、Channel、Tool 的实例化。

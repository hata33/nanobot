# Tools 模块

> 职责：把文件、Shell、Web、MCP、Cron 等能力封装为工具，注册并暴露给 LLM。

## 关键文件

- `agent/tools/base.py`
- `agent/tools/registry.py`
- `agent/tools/schema.py`
- `agent/tools/shell.py`
- `agent/tools/filesystem.py`
- `agent/tools/web.py`
- `agent/tools/mcp.py`
- `agent/tools/cron.py`
- `agent/tools/spawn.py`
- `agent/tools/self.py`
- `agent/tools/long_task.py`

## 核心抽象

| 类 / 结构 | 职责 |
|---|---|
| `BaseTool` | 工具基类，定义 `execute`、`to_schema`、`cast_params` |
| `ToolRegistry` | 注册 / 发现 / 调用工具，生成 schema 列表 |
| `ToolDefinition` | 工具元数据：名称、描述、参数 schema |

## 工具分类

| 类别 | 代表工具 | 说明 |
|---|---|---|
| 文件系统 | `read_file`、`write_file`、`edit_file`、`list_dir` | 工作区内文件操作 |
| Shell | `exec` | 命令执行，支持 sandbox 后端 |
| 网络 | `web_search`、`web_fetch` | 搜索与抓取，带 SSRF 防护 |
| MCP | `mcp_*` | 通过 MCP 协议接入外部服务 |
| 调度 | `cron` | 定时任务管理 |
| 子代理 | `spawn` | 派发子 Agent |
| 自我修改 | `self` | 运行时自检与修改 |
| 长任务 | `long_task` | 长时间运行的后台任务 |

## 注册机制

- 内置扫描：`agent/tools/__init__.py` 或 `loader.py`
- 插件入口：`entry_points` 发现第三方工具
- `ToolRegistry.get_definitions()` 返回稳定排序的 schema 列表，供 Provider 调用

## 关键设计

- **工具即契约**：`tool.execute(args, context)` 是唯一定点，schema 是模型侧契约。
- **上下文注入**：`RequestContext` 把 session、workspace、channel 等运行时信息传入工具。
- **安全沙箱**：Shell 工具支持 `sandbox` 后端，限制执行环境。

## 对外接口

```python
class ToolRegistry:
    def register(self, tool: BaseTool) -> None: ...
    def get(self, name: str) -> BaseTool | None: ...
    def get_definitions(self) -> list[dict[str, Any]]: ...
    def prepare_call(self, name: str, params: Any) -> tuple[Tool | None, Any, str | None]: ...
```

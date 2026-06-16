# AgentRunner 模块

> 职责：LLM 对话循环，负责 provider 调用、tool call 执行、streaming 与重试。

## 关键文件

- `agent/runner.py`

## 核心类 / 结构

| 类 / 结构 | 职责 |
|---|---|
| `AgentRunner` | 无产品逻辑的纯执行循环 |
| `AgentRunSpec` | 单次执行的配置对象（消息、工具、模型、限制等） |
| `AgentRunResult` | 执行结果（最终内容、工具列表、用量、停止原因） |

## 执行骨架

```text
runner.run(spec)
  ├─ provider.chat(messages, tools)
  ├─ if tool_call:
  │   ├─ tool_registry.get(name)
  │   ├─ tool.execute(args, context)
  │   └─ append result → 继续循环
  └─ else:
      └─ 返回 final_content
```

## 关键行为

- **迭代控制**：`max_iterations` 限制 tool_call 循环次数。
- **注入机制**：支持 `injection_callback` 在迭代中插入系统/用户消息。
- **错误恢复**：`provider_retry_mode` 控制重试策略；超限时生成 `EMPTY_FINAL_RESPONSE_MESSAGE`。
- **进度回调**：`progress_callback` 支持前端实时 streaming。
- **文件编辑追踪**：`StreamingFileEditTracker` 把工具执行中的文件变更转化为可展示事件。

## 对外接口

```python
class AgentRunner:
    def __init__(self, provider: LLMProvider): ...
    async def run(self, spec: AgentRunSpec) -> AgentRunResult: ...
```

## 设计要点

- Runner 不感知 channel / session / workspace，只吃 spec、吐 result。
- 工具执行结果会回填到 messages，形成多轮对话上下文。
- 支持 `concurrent_tools` 并行执行独立工具调用。

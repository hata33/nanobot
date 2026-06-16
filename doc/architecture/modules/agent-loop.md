# AgentLoop 模块

> 职责：单次消息的编排入口，管理 session、context、hooks、outbound 发布。

## 关键文件

- `agent/loop.py`
- `agent/context.py`
- `agent/hook.py`
- `agent/progress_hook.py`

## 核心类

| 类 | 职责 |
|---|---|
| `AgentLoop` | 接收 inbound 消息，驱动状态机，协调 Runner、Session、Memory |
| `TurnContext` | 单次 turn 的运行时上下文，携带消息、历史、状态、回调 |
| `TurnState` | 状态枚举：RESTORE / COMPACT / COMMAND / BUILD / RUN / SAVE / RESPOND / DONE |
| `ContextBuilder` | 组装 system prompt、历史、skills、memory 片段 |
| `AgentHook` / `CompositeHook` | 生命周期钩子：before_run / after_run / on_tool 等 |

## 状态流转

```text
RESTORE → COMPACT → COMMAND → BUILD → RUN → SAVE → RESPOND → DONE
```

- `RESTORE`：从 Session 加载历史
- `COMPACT`：自动压缩上下文
- `COMMAND`：检查斜杠命令
- `BUILD`：构建完整上下文
- `RUN`：交给 AgentRunner 执行
- `SAVE`：落盘会话
- `RESPOND`：发布 outbound

## 对外接口

```python
class AgentLoop:
    async def process_direct(self, message: str, session_key: str) -> OutboundMessage: ...
    async def start(self) -> None: ...
    def from_config(config: Config, ...) -> AgentLoop: ...
```

## 设计要点

- 状态机驱动单次 turn，每个状态职责单一。
- Hook 机制支持横切关注点（日志、审计、进度、重试策略）。
- `process_direct` 给 SDK / 测试提供同步风格入口。

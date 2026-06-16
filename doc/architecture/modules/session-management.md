# Session 管理模块

> 职责：近期会话历史的读写、TTL 压缩、继续标记、fork 与元数据管理。

## 关键文件

- `session/manager.py`
- `session/keys.py`
- `session/goal_state.py`
- `session/turn_continuation.py`

## 核心类

| 类 | 职责 |
|---|---|
| `SessionManager` | 会话 CRUD、历史追加、压缩、TTL 清理 |
| `Session` | 单次会话数据：key、messages、metadata、last_consolidated |
| `GoalState` | 长期目标状态（sustained goal） |
| `TurnContinuation` | 中断后继续执行的标记 |

## 存储布局

```text
<workspace>/sessions/*.jsonl   ← 会话历史
<workspace>/memory/MEMORY.md   ← 长期记忆
<workspace>/cron/jobs.json     ← 定时任务
```

## 关键行为

- **原子写入**：JSONL 文件使用原子写 + fsync，避免断电丢失。
- **自动压缩**：TTL 或消息数达到阈值时触发 `compact`，保留近期消息，归档旧消息。
- **会话隔离**：`session_key_for_channel` 按 channel + chat_id 生成唯一 key。
- **Fork 支持**：`fork` 操作复制会话，保留可变的运行时元数据与不变的历史。

## 对外接口

```python
class SessionManager:
    def get_or_create(self, session_key: str) -> Session: ...
    def save_turn(self, session: Session, turn: dict) -> None: ...
    def compact(self, session: Session) -> None: ...
    def delete(self, session_key: str) -> None: ...
    def list_sessions(self) -> list[dict]: ...
```

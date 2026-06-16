# MessageBus 与 Channels 模块

> 职责：消息接入与解耦，把外部平台消息转为统一 InboundMessage，再把 Agent 响应发回平台。

## 关键文件

- `bus/queue.py`
- `bus/events.py`
- `bus/progress.py`
- `channels/base.py`
- `channels/manager.py`
- `channels/websocket.py`（含 WebUI）

## 核心类

| 类 | 职责 |
|---|---|
| `MessageBus` | 异步 inbound / outbound 队列 |
| `InboundMessage` / `OutboundMessage` | 统一消息事件 |
| `BaseChannel` | 渠道抽象：接收外部事件，调用 `publish_inbound`，监听 outbound 并发送 |
| `ChannelManager` | 渠道发现、生命周期管理 |

## 消息流

```text
External Event
  → Channel.on_event(...)
  → MessageBus.publish_inbound(InboundMessage)
  → AgentLoop.run_turn(...)
  → MessageBus.publish_outbound(OutboundMessage)
  → Channel.deliver(response)
  → External Platform
```

## 渠道发现机制

- 内置扫描：`pkgutil` 遍历 `nanobot/channels/`
- 插件入口：`entry_points` 发现第三方 channel

## 关键设计

- **发布-订阅**：Channel 只知 bus，不知 agent；agent 只知 bus，不知 channel。
- **协议统一**：无论来源是 Telegram、Discord 还是 CLI，进入 Agent 的都是同一份 `InboundMessage`。
- **WebSocket 多路复用**：WebUI 通过 WebSocket 同时承载聊天、媒体、进度、命令。

## 代表渠道

| 渠道 | 文件 | 特点 |
|---|---|---|
| CLI | `cli/commands.py` | 交互式 prompt + streaming |
| WebUI | `channels/websocket.py` | WebSocket 多路复用，前端 SPA |
| Telegram | `channels/telegram.py` | polling / webhook |
| Discord | `channels/discord.py` | gateway + interactions |
| WhatsApp | `channels/whatsapp.py` | 通过 bridge/ TypeScript 服务 |

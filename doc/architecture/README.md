# nanobot 架构总览

> 版本：2026-06-16
> 视角：源码级架构，按核心能力抽取模块，统一分层、边界、职责与调用关系。

---

## 1. 产品一句话定位

nanobot 是一个轻量级开源 AI Agent 框架，用异步消息总线把“多端消息接入”与“LLM 执行循环”解耦，让用户输入能在统一管道里完成上下文构建、工具调用、记忆持久化，并以最小耦合适配多种聊天平台与模型后端。

---

## 2. 技术栈

| 层级 | 技术 / 语言 | 作用 |
|---|---|---|
| Python 运行时 | Python 3.11+ + asyncio | 核心 Agent、Provider、Channel、Tools |
| 前端 | React + TypeScript + Vite + Tailwind | WebUI 聊天界面 |
| 消息协议 | WebSocket（自定义多路复用） | WebUI / Gateway 通信 |
| 模型协议 | OpenAI 兼容 / Anthropic / Azure / Bedrock / Copilot / Codex 等 | 统一 LLM 接入 |
| 配置 | Pydantic | `~/.nanobot/config.json` |
| 构建与打包 | pyproject.toml / hatch / force-include | 把 WebUI 打包进 Python Wheel |
| 可选桥接 | TypeScript（bridge/） | WhatsApp 等外部桥接服务 |

---

## 3. 分层架构（从入口到执行）

```text
Channel（消息接入）
  ↓ publish_inbound
MessageBus（队列解耦）
  ↓ consume_inbound
AgentLoop（会话编排）
  ├─ ContextBuilder（上下文构造）
  ├─ SessionManager（会话读写 / 压缩）
  ├─ ToolRegistry（工具发现与执行）
  ├─ AgentRunner（LLM 主循环）
  └─ Memory / Dream（长期记忆）
  ↓ publish_outbound
Channel（回传响应）
```

- **接入层**：Channel 负责把 Telegram / Discord / WebUI / CLI 等转换成统一 `InboundMessage`。
- **调度层**：`MessageBus` 提供 inbound / outbound 队列，实现生产消费解耦。
- **编排层**：`AgentLoop` 处理 session 归属、context 构建、hook 挂载、工具调度、outbound 发布。
- **执行层**：`AgentRunner` 与 Provider 形成“请求 → tool_call → 执行 → 结果回填”的迭代循环。
- **存储层**：`SessionManager` 负责近期会话；`Memory` 负责长期记忆；`Config` 负责配置持久化。

---

## 4. 模块目录总览

| 目录 | 能力 | 关键入口 / 类 |
|---|---|---|
| `nanobot/__main__.py` | Python 模块入口 | `app()` → `cli/commands.py` |
| `cli/commands.py` | CLI 与 Gateway 主入口 | `typer.App`、`gateway()` |
| `bus/` | 消息总线与进度事件 | `MessageBus`、`RuntimeEventBus` |
| `channels/` | 多平台接入 | `BaseChannel`、`ChannelManager` |
| `agent/loop.py` | 会话编排核心 | `AgentLoop`、`TurnState` |
| `agent/runner.py` | LLM 主循环 | `AgentRunner`、`AgentRunSpec` |
| `agent/context.py` | 上下文构建 | `ContextBuilder` |
| `agent/tools/` | 工具生态 | `ToolRegistry`、`BaseTool` |
| `agent/memory.py` | 长期记忆 | `Consolidator` |
| `agent/hook.py` | 生命周期钩子 | `AgentHook` |
| `session/` | 会话管理 | `SessionManager` |
| `config/` | 配置加载与 Schema | `Config`、`loader` |
| `providers/` | LLM 后端 | `LLMProvider`、`ProviderFactory` |
| `security/` | 工作区与网络安全 | `WorkspacePolicy`、`NetworkGuard` |
| `cron/` | 定时任务 | `CronService` |
| `webui/` | 前端与网关服务 | `GatewayServices` |
| `api/server.py` | OpenAI 兼容 API | `/v1/chat/completions` |

---

## 5. 核心调用链（骨架）

```text
CLI / WebUI / Channel.send(message)
  → MessageBus.publish_inbound(InboundMessage)
  → AgentLoop.run_turn(msg, session)
      ├─ SessionManager.get_or_create(session_key)
      ├─ ContextBuilder.build(messages, workspace, skills)
      ├─ AgentRunner.run(spec)
      │   ├─ provider.chat(messages, tools)
      │   ├─ tool_registry.get(name)
      │   ├─ tool.execute(args, context)
      │   └─ （循环：provider → tool → provider → ...）
      ├─ Memory.consolidate(...)
      └─ SessionManager.save_turn(...)
  → MessageBus.publish_outbound(OutboundMessage)
  → channel.deliver(response)
```

---

## 6. 核心设计决策

1. **消息总线解耦通道与 Agent**
   用 `MessageBus` 的 inbound/outbound 队列把“谁发的消息”与“怎么处理消息”彻底分开，新增聊天平台只需实现 `BaseChannel` 并调用 `publish_inbound`。

2. **Loop / Runner 职责二分**
   `AgentLoop` 管 session、workspace、context、outbound；`AgentRunner` 管 provider 调用、tool 循环、streaming 与重试。边界清晰，调试时可按“会话问题找 Loop，模型/工具问题找 Runner”快速定位。

3. **Provider 抽象 + 注册表**
   所有 LLM 后端统一继承 `LLMProvider`，通过 `ProviderFactory` + `ProviderRegistry` 按配置、API Key、base URL 自动选择。新增后端只需加一个 Provider 实现和一个 schema 字段。

4. **工具即插件，按需发现**
   工具目录 + entry point 双路发现，`ToolRegistry` 统一管理。工具签名即模型契约，`tool.execute(args, context)` 是唯一定点。

5. **Session 与 Memory 分层持久化**
   Session JSONL 保存近期对话；`MEMORY.md` + `history.jsonl` 做长期记忆；Dream 任务异步做两阶段整合。时间维度分层，避免“近期上下文”和“长期知识”互相污染。

---

## 7. 模块阅读路线图

| 目标 | 建议阅读顺序 |
|---|---|
| 理解一次完整消息流转 | `bus/queue.py` → `agent/loop.py` → `agent/runner.py` |
| 新增 LLM 后端 | `providers/base.py` → `providers/registry.py` → `providers/factory.py` → 任一现有 Provider |
| 新增聊天渠道 | `channels/base.py` → `channels/manager.py` → 任一现有 Channel |
| 新增工具 | `agent/tools/base.py` → `agent/tools/registry.py` → 任一现有 Tool |
| 理解会话与记忆 | `session/manager.py` → `agent/memory.py` |
| 理解配置加载 | `config/schema.py` → `config/loader.py` |

---

## 8. 实现思路总结

nanobot 的核心实现思路可以概括为：

1. **统一消息协议**：所有通道都映射到 `InboundMessage` / `OutboundMessage`，Agent 核心不感知平台细节。
2. **配置驱动实例化**：Provider、Channel、Tool 都通过配置 + 注册表自动发现与装配，减少硬编码分支。
3. **状态机编排**：`AgentLoop` 用 `TurnState` 枚举驱动单次 turn 的状态流转，保证每个阶段职责单一。
4. **可插拔生命周期**：`AgentHook` 让外部代码可以介入任意执行阶段，支持日志、审计、进度、重试策略。
5. **分层持久化**：近期会话、长期记忆、配置、Cron 任务各自落盘，互不干扰，支持 TTL 与异步整合。

---

> 详细模块文档见 `architecture/modules/`。

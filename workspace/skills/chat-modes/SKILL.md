---
name: chat-modes
description: "聊天模式切换：普通聊天 vs 深度聊天。触发词：深度聊天、聊聊、随便聊聊。"
metadata: {"nanobot":{"emoji":"💬"}}
---

# 聊天模式 Skill

管理不同的聊天会话模式，通过 `session_key` 隔离上下文。

## 模式

| 模式 | session_key | 特点 |
|------|-------------|------|
| 普通聊天 | `chat:default` | 轻量、即时、记忆短 |
| 深度聊天 | `chat:deep` | 保持更长上下文、更深入探讨 |
| 心理陪伴 | `psych:session` | 共情模式，见 psych-support |

## 切换方式

- 自然语言："我们深度聊聊"
- 斜杠命令：`/mode deep` / `/mode chat`
- 新会话自动使用默认模式

## 规则

1. 深度聊天保留更多历史，适合复杂话题
2. 心理陪伴模式启用 psych-support Skill
3. 不同模式的会话历史独立存储

## 触发条件

- "深度聊聊"、"认真聊一下"
- "切换到深度模式"
- "随便聊聊"（普通模式）

---
name: learning-planner
description: "制定和跟踪学习计划。触发词：学习计划、制定计划、学习目标、进度跟踪。"
metadata: {"nanobot":{"emoji":"📈"}}
---

# 学习计划 Skill

帮用户制定可执行的学习计划，跟踪进度，调整节奏。

## 工作流

1. **明确目标**：具体、可衡量、有时限
2. **拆解任务**：按周/天拆成可执行块
3. **设置检查点**：每周回顾，调整计划
4. **记录进度**：写入 `knowledge/plans/`

## 计划文件格式

```markdown
---
title: 学习计划：主题
created: YYYY-MM-DD
goal: 一句话目标
duration: 预计时长
status: active|paused|completed
---

## 目标

具体描述

## 周计划

- 第 1 周：...
- 第 2 周：...

## 每日任务

- [ ] 任务 1
- [ ] 任务 2

## 进度记录

- YYYY-MM-DD：完成情况、心得
```

## 触发条件

- "我想学 XX"、"帮我做个学习计划"
- "本周进度"、"检查一下我的计划"
- "学习目标"

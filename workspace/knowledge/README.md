# 知识库

用户个人知识库，按领域组织，供各 Skill 共享读写。

## 目录

- `notes/` — 需求梳理、学习笔记、认知校准、口才练习记录
- `reading/` — 名句、文章摘要、书摘
- `plans/` — 学习计划、目标追踪
- `state/` — 各 Skill 运行时状态（不纳入版本控制）

## 约定

- 一个文件一个主题，Markdown 格式，文件名使用 kebab-case
- 日期使用 ISO 8601：`YYYY-MM-DD`
- 知识条目使用统一 frontmatter：

```markdown
---
title: 主题
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [标签1, 标签2]
source: 来源（可选）
---

# 正文
```

## 跨引用

使用相对路径引用其他知识文件：

```markdown
参见：[学习计划](../plans/2025-06-study-plan.md)
```

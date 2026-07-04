---
name: knowledge-manager
description: "记录、检索和整理知识。用于梳理需求、记录笔记、名句摘录、知识检索。触发词：记录、记一下、记下来、检索、查找知识、名句、总结。"
metadata: {"nanobot":{"emoji":"📚"}}
---

# 知识管理 Skill

负责将信息结构化存入 `knowledge/`，并在需要时检索。

## 目录

- `knowledge/notes/` — 原子笔记
- `knowledge/reading/` — 名句、文章摘要
- `knowledge/plans/` — 计划与目标

## 记录规则

1. 使用 `write` 或 `edit` 写入 Markdown 文件
2. 文件名使用 kebab-case，日期前缀：`YYYY-MM-DD-主题.md`
3. 必须包含 frontmatter（title, created, updated, tags）
4. 内容聚焦一个主题，不混合多个议题

## 检索规则

1. 先用 `grep` 按标签或关键词搜索
2. 根据结果读取相关文件
3. 返回时注明来源路径和日期

## 触发条件

- "记一下"、"记录下来"、"帮我梳理"
- "查找我之前记的"、"检索知识"
- "总结这段"、"提取名句"

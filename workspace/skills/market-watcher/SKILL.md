---
name: market-watcher
description: "实时美股和黄金价格。触发词：美股、黄金、价格、行情、股价、金价。"
metadata: {"nanobot":{"emoji":"📈"}}
---

# 市场观察 Skill

获取实时或近期美股/黄金价格，不提供投资建议。

## 数据源

1. **美股**：使用 web_search 或 web_fetch 查询 Yahoo Finance、Google Finance
2. **黄金**：查询国际金价（XAU/USD）或国内金价
3. **A股/港股**：按需扩展

## 返回格式

```
标的：AAPL（Apple Inc.）
最新价：$XXX.XX
涨跌幅：+X.XX%
更新时间：YYYY-MM-DD HH:MM

数据来源：Yahoo Finance
```

## 规则

1. 明确标注数据来源和延迟（实时/15分钟延迟）
2. 不预测走势，不给出买卖建议
3. 如果查询失败，说明原因并建议替代来源

## 触发条件

- "AAPL 现在多少钱"
- "黄金价格"
- "帮我看看美股/黄金行情"

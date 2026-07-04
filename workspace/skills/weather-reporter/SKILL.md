---
name: weather-reporter
description: "天气查询。触发词：天气、下雨、温度、天气预报。"
metadata: {"nanobot":{"emoji":"🌤️"}}
---

# 天气 Skill

查询实时天气和预报，无需 API Key。

## 数据源

1. **wttr.in**（主）：`curl -s "wttr.in/City?format=3"`
2. **Open-Meteo**（备）：JSON 格式，适合程序化处理

## 返回格式

```
地点：City
天气：⛅️
温度：+XX°C
湿度：XX%
风速：XX km/h
```

## 规则

1. 城市名需要 URL 编码（空格转 +）
2. 支持机场代码（如 JFK）
3. 默认公制单位，用户要求时切换

## 触发条件

- "今天天气怎么样"
- "北京天气"
- "会下雨吗"

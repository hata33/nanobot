# Security 模块

> 职责：工作区访问控制、Shell 沙箱、网络边界防护、PTH 启动安全。

## 关键文件

- `security/workspace_access.py`
- `security/workspace_policy.py`
- `security/network.py`
- `agent/tools/sandbox.py`
- `agent/tools/shell.py`

## 核心能力

| 边界 | 防护措施 |
|---|---|
| 工作区访问 | `WorkspaceScopeResolver` 限制工具只能访问授权路径 |
| Shell 执行 | `sandbox.py` 提供 Docker / Firecracker / 本地沙箱 |
| 网络请求 | `network.py` 做 SSRF 防护，校验域名 / IP |
| 启动安全 | PTH 文件保护，防止权限提升 |

## 关键设计

- **最小权限**：工具默认只能读写当前 workspace，除非显式配置允许。
- **沙箱分级**：Shell 工具支持不同 sandbox 后端，按安全需求选择。
- **网络白名单**：Web 工具默认校验目标 URL，防止内网探测。

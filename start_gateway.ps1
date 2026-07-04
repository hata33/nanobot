# Requires -Version 5.1

<#
.SYNOPSIS
    加载 .env 中的密钥并启动 nanobot 网关

.DESCRIPTION
    该脚本从 .env 文件中读取环境变量，并将其注入当前进程环境，
    然后执行 `uv run nanobot gateway`。密钥不会出现在命令行中。

.USAGE
    .\start_gateway.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# 获取脚本所在目录（仓库根目录）
$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $ROOT

$envFile = Join-Path $ROOT ".env"
if (-not (Test-Path $envFile)) {
    Write-Error "错误：在 $envFile 找不到 .env 文件 — 请创建并设置 DEEPSEEK_API_KEY=..."
    exit 1
}

# 逐行加载 .env 文件
Get-Content $envFile | ForEach-Object {
    $line = $_.Trim()
    # 跳过空行和注释
    if ($line -eq '' -or $line.StartsWith('#')) {
        return
    }
    # 按第一个 '=' 分割
    $parts = $line -split '=', 2
    if ($parts.Count -eq 2) {
        $name = $parts[0].Trim()
        $value = $parts[1].Trim()
        # 去掉可能存在的引号
        if ($value -match '^"(.*)"$' -or $value -match "^'(.*)'$") {
            $value = $matches[1]
        }
        Set-Item -Path "env:$name" -Value $value
    } else {
        Write-Warning "跳过 .env 中的无效行: $line"
    }
}

# 检查必要变量
if (-not $env:DEEPSEEK_API_KEY) {
    Write-Error "错误：$envFile 中的 DEEPSEEK_API_KEY 为空"
    exit 1
}

Write-Host "正在启动 nanobot 网关（从 .env 加载 DeepSeek 密钥）..."
# 执行命令（若 uv 不在 PATH 中，请使用完整路径）
uv run nanobot gateway
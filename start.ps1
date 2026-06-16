<#
.SYNOPSIS
    nanobot 启动 / 微信登录脚本（PowerShell 版）。
    对应原 start_gateway.sh 的 Windows 版本。

.USAGE
    .\start.ps1               # 默认启动 gateway（同 start_gateway.sh）
    .\start.ps1 gateway       # 启动 gateway
    .\start.ps1 login weixin  # 微信扫码登录
    .\start.ps1 login          # 进入登录子菜单
#>

param(
    [Parameter(Position = 0)]
    [string]$Command = "gateway",

    [Parameter(Position = 1)]
    [string]$Target
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---------- 工具函数 ----------
function Write-Step { param([string]$Msg) Write-Host "`n[STEP] $Msg" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Msg) Write-Host "[OK]   $Msg" -ForegroundColor Green }
function Write-Err  { param([string]$Msg) Write-Host "[ERR]  $Msg" -ForegroundColor Red }
function Write-Info { param([string]$Msg) Write-Host "[INFO] $Msg" -ForegroundColor Yellow }

# ---------- 加载 .env ----------
function Import-EnvFile {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        Write-Err ".env 文件不存在: $Path"
        exit 1
    }
    Get-Content $Path -Encoding UTF8 | ForEach-Object {
        $line = $_.Trim()
        if (-not $line -or $line.StartsWith('#')) { return }
        if ($line -match '^([^=]+)=(.*)$') {
            $name  = $matches[1].Trim()
            $value = $matches[2].Trim()
            # 去除首尾引号（若有）
            if (($value.StartsWith('"') -and $value.EndsWith('"')) -or
                ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
}

# ---------- 检查 uv ----------
function Assert-Uv {
    try {
        $v = uv --version 2>&1
        Write-Ok "uv 版本: $v"
    } catch {
        Write-Err "未找到 uv，请先安装: https://docs.astral.sh/uv/"
        exit 1
    }
}

# ---------- 检查 DEEPSEEK_API_KEY ----------
function Assert-DeepSeekKey {
    $key = [Environment]::GetEnvironmentVariable("DEEPSEEK_API_KEY", "Process")
    if (-not $key) {
        Write-Err "DEEPSEEK_API_KEY 为空（已从 .env 加载但值为空）"
        exit 1
    }
    Write-Ok "DEEPSEEK_API_KEY 已加载（长度: $($key.Length)）"
}

# ---------- 命令：gateway ----------
function Start-Gateway {
    param([string]$Root)

    Write-Step "启动 nanobot gateway"
    Write-Info "工作目录: $Root"

    Push-Location $Root
    try {
        uv run nanobot gateway
    } finally {
        Pop-Location
    }
}

# ---------- 命令：login weixin ----------
function Start-LoginWeixin {
    param([string]$Root)

    Write-Step "微信渠道登录（nanobot channels login weixin）"
    Write-Info "工作目录: $Root"

    Push-Location $Root
    try {
        uv run nanobot channels login weixin
    } finally {
        Pop-Location
    }
}

# ---------- 主流程 ----------
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root

Write-Host ""
Write-Host "========================================" -ForegroundColor Magenta
Write-Host "  nanobot 启动脚本 (PowerShell)" -ForegroundColor Magenta
Write-Host "  项目目录: $Root" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Magenta
Write-Host ""

# 加载 .env
$envPath = Join-Path $Root ".env"
Import-EnvFile -Path $envPath
Write-Ok ".env 已加载"

# 检查 uv
Assert-Uv

# 如果启动 gateway，需要检查 key
if ($Command -eq "gateway") {
    Assert-DeepSeekKey
}

# 路由命令
switch ($Command.ToLower()) {
    "gateway" {
        Start-Gateway -Root $Root
    }
    "login" {
        if ($Target -eq "weixin") {
            Start-LoginWeixin -Root $Root
        } else {
            Write-Info "可用登录目标: weixin"
            Write-Host "用法: .\start.ps1 login weixin" -ForegroundColor Yellow
        }
    }
    default {
        Write-Err "未知命令: $Command"
        Write-Host "用法: .\start.ps1 [gateway|login weixin]" -ForegroundColor Yellow
        exit 1
    }
}

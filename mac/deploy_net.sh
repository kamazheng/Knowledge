# --- 用户配置区 ---
[string]$debug_folder = "\\MLXCDUVWPFILE01.molex.com\FileService\Applications\Development"
[string]$release_folder = "\\MLXCDUVWPFILE01.molex.com\FileService\Applications\Production"
[string]$macMountRootDebug = "$HOME/mnt/FileService_Debug"
[string]$macMountRootRelease = "$HOME/mnt/FileService_Release"
[string]$dev_url = "https://mlxcduvwpfile01.molex.com:60010/"
[string]$prod_url = "https://mlxcduvwpfile02.molex.com:60000/"

# --- 自动识别平台 ---
$isMac = [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::OSX)
Write-Host "Platform detected: macOS=$isMac" -ForegroundColor Cyan

# --- 工具函数 ---

function Get-SmbMountPathFromUnc {
    param([string]$uncPath)
    # 提取服务器和完整共享路径（包括子目录）
    if ($uncPath -match '^\\\\([^\\]+)\\(.+)$') {
        $server = $matches[1]
        $sharePath = $matches[2] -replace '\\', '/'
        return "$server/$sharePath"
    }
    throw "Invalid UNC path: $uncPath"
}

function Initialize-Directory {
    param([string]$path)
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "Created directory: $path" -ForegroundColor Cyan
    }
}

function Get-KerberosUser {
    try {
        $klistOutput = klist 2>&1
        $match = $klistOutput | Select-String -Pattern 'Default principal:\s*(.+?)@'
        if ($match) {
            $principal = $match.Matches[0].Groups[1].Value
            if ($principal) {
                return $principal
            }
        }
    }
    catch {
        Write-Host "获取 Kerberos 用户时出错: $_" -ForegroundColor Yellow
    }
    return $null
}

function Mount-SmbShare {
    param([string]$smbPath, [string]$mountPoint)

    Write-Host "准备挂载 SMB 路径: $smbPath" -ForegroundColor Cyan
    
    # 检查是否已经正确挂载
    $escapedMountPoint = [regex]::Escape($mountPoint)
    $mountOutput = mount | Select-String -Pattern "on\s+$escapedMountPoint\s+\("
    
    if ($mountOutput) {
        $line = $mountOutput.Line
        if ($line -match [regex]::Escape($smbPath)) {
            Write-Host "✅ 已正确挂载: $mountPoint -> $smbPath" -ForegroundColor Green
            return
        }
        else {
            Write-Host "🔄 挂载点被占用，正在卸载..." -ForegroundColor Yellow
            umount "$mountPoint" 2>&1
        }
    }

    # 尝试无用户挂载
    $cmd = "mount_smbfs '//$smbPath' '$mountPoint'"
    Write-Host "执行挂载命令: $cmd" -ForegroundColor Yellow
    Invoke-Expression $cmd
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 挂载成功: $mountPoint" -ForegroundColor Green
        return
    }

    # 挂载失败，尝试使用 Kerberos 用户
    Write-Host "Mount failed. Trying with Kerberos user..." -ForegroundColor Yellow
    
    $kerberosUser = Get-KerberosUser
    if (-not $kerberosUser) {
        $kerberosUser = Read-Host "Enter Kerberos username (without @domain)"
    }
    
    if ([string]::IsNullOrWhiteSpace($kerberosUser)) {
        Write-Host "❌ 用户名不能为空" -ForegroundColor Red
        exit 1
    }

    # 构造带用户名的挂载路径
    $serverAndPath = $smbPath
    $cmd = "mount_smbfs '//$kerberosUser@$serverAndPath' '$mountPoint'"
    Write-Host "执行挂载命令: $cmd" -ForegroundColor Yellow
    Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ 挂载失败" -ForegroundColor Red
        Write-Host "请检查:" -ForegroundColor Yellow
        Write-Host "1. 网络连接是否正常" -ForegroundColor Yellow
        Write-Host "2. Kerberos ticket 是否有效 (运行 klist 检查)" -ForegroundColor Yellow
        Write-Host "3. 服务器地址是否正确: $serverAndPath" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "✅ 挂载成功: $mountPoint" -ForegroundColor Green
}

function Test-DeploymentPaths {
    Write-Host "`n=== 路径验证 ===" -ForegroundColor Magenta
    Write-Host "构建配置: $buildConfiguration" -ForegroundColor Cyan
    Write-Host "UNC路径: $destinationUnc" -ForegroundColor Cyan
    Write-Host "挂载点: $macMountPoint" -ForegroundColor Cyan
    Write-Host "实际部署路径: $destinationFolder" -ForegroundColor Cyan
    
    if ($isMac) {
        $smbPath = Get-SmbMountPathFromUnc -uncPath $destinationUnc
        Write-Host "SMB挂载路径: $smbPath" -ForegroundColor Cyan
    }
    
    Write-Host "================`n" -ForegroundColor Magenta
}

# --- 用户输入构建配置 ---
$buildConfiguration = (Read-Host "请输入构建配置 (Debug/Release)").Trim().ToLower()
if ($buildConfiguration -notin @("debug", "release")) {
    Write-Host "无效的构建配置，请输入 Debug 或 Release" -ForegroundColor Red
    exit 1
}

# --- 路径选择 ---
if ($buildConfiguration -eq "debug") {
    $destinationUnc = $debug_folder
    $destUrl = $dev_url
    $macMountPoint = $macMountRootDebug
}
else {
    $destinationUnc = $release_folder
    $destUrl = $prod_url
    $macMountPoint = $macMountRootRelease
}

# --- 设置目标路径 ---
$destinationFolder = if ($isMac) { $macMountPoint } else { $destinationUnc }

# --- HTML 内容 ---
$appOfflineContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>App Offline</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333;
            text-align: center;
            padding: 50px;
        }
        h1 {
            color: #e74c3c;
        }
        p {
            font-size: 18px;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <h1>Application is offline for maintenance.</h1>
    <p>We'll be back soon. Thank you for your patience!</p>
</body>
</html>
"@

# --- 找到项目文件 ---
$projectFile = Get-ChildItem -Path $PSScriptRoot -Filter *.csproj | Select-Object -First 1 -ExpandProperty FullName
if (-not $projectFile) {
    Write-Host "未找到 .csproj 文件，请确认执行路径" -ForegroundColor Red
    exit 1
}
Write-Host "项目文件: $projectFile" -ForegroundColor Green

# --- 挂载逻辑（仅 macOS）---
if ($isMac) {
    Initialize-Directory -path $macMountPoint
    $smbFullPath = Get-SmbMountPathFromUnc -uncPath $destinationUnc
    Write-Host "完整SMB路径: $smbFullPath" -ForegroundColor Cyan
    
    Mount-SmbShare -smbPath $smbFullPath -mountPoint $macMountPoint
    
    # 验证挂载是否成功
    if (-not (Test-Path $destinationFolder)) {
        Write-Host "❌ 目标部署路径不存在: $destinationFolder" -ForegroundColor Red
        Write-Host "请检查挂载是否正确或路径权限" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ 目标部署路径可访问: $destinationFolder" -ForegroundColor Green
}

# --- 等待路径可用 ---
for ($i = 0; $i -lt 3; $i++) {
    if (Test-Path $destinationFolder) { break }
    Start-Sleep -Seconds 2
}
if (-not (Test-Path $destinationFolder)) {
    Write-Host "无法访问目标路径: $destinationFolder" -ForegroundColor Red
    exit 1
}

# --- 路径验证 ---
Test-DeploymentPaths
Read-Host -Prompt "按 Enter 键继续"


# --- 创建 app_offline.htm ---
$offlineFile = Join-Path $destinationFolder "app_offline.htm"
$appOfflineContent | Out-File -FilePath $offlineFile -Encoding UTF8
Write-Host "创建 app_offline.htm 成功" -ForegroundColor Green

# --- 临时发布目录 ---
$tempPublishFolder = Join-Path ([System.IO.Path]::GetTempPath()) "dotnet_publish_temp"
if (Test-Path $tempPublishFolder) { Remove-Item $tempPublishFolder -Recurse -Force }
Initialize-Directory -path $tempPublishFolder

# --- NuGet 还原和发布 ---
Write-Host "正在还原 NuGet 包..." -ForegroundColor Cyan
dotnet restore $projectFile
if ($LASTEXITCODE -ne 0) {
    Write-Host "NuGet 还原失败" -ForegroundColor Red
    exit 1
}

Write-Host "开始发布项目..." -ForegroundColor Cyan
dotnet publish $projectFile -c $buildConfiguration -o $tempPublishFolder
if ($LASTEXITCODE -ne 0) {
    Write-Host "发布失败" -ForegroundColor Red
    exit 1
}

# --- 同步文件 ---
if ($isMac) {
    $rsyncArgs = "-avh --progress '$tempPublishFolder/' '$destinationFolder/'"
    $bashCommand = "rsync $rsyncArgs"
    Write-Host "执行 rsync 命令: $bashCommand" -ForegroundColor Yellow
    bash -c "$bashCommand"
    if ($LASTEXITCODE -ne 0) {
        Write-Host "rsync 执行失败" -ForegroundColor Red
        exit 1
    }
}
else {
    Copy-Item -Path "$tempPublishFolder/*" -Destination $destinationFolder -Recurse -Force
}

# --- 清理离线文件 ---
Remove-Item $offlineFile -ErrorAction SilentlyContinue
Write-Host "已移除 app_offline.htm" -ForegroundColor Green

# --- 完成提示 ---
Write-Host "✅ 部署已完成!" -ForegroundColor Green
Write-Host "部署目标路径: $destUrl" -ForegroundColor Green

Read-Host -Prompt "按 Enter 键继续"
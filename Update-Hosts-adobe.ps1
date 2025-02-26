# 檢查目前腳本是否以管理員權限執行
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # 如果不是，則重新啟動腳本並要求提升權限
    Start-Process powershell.exe -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 設定 hosts 檔案的路徑
$hostsFilePath = "$env:SystemRoot\System32\drivers\etc\hosts"

# 設定備份檔案的路徑
$backupFilePath = "$env:SystemRoot\System32\drivers\etc\hosts.bak"

# 取得腳本所在的目錄
$scriptDirectory = $PSScriptRoot

# 建構 hosts.txt 的完整路徑
$hostsTxtPath = Join-Path -Path $scriptDirectory -ChildPath "hosts.txt"

# 檢查 hosts 檔案是否存在
if (Test-Path -Path $hostsFilePath) {
    # 備份現有的 hosts 檔案
    Copy-Item -Path $hostsFilePath -Destination $backupFilePath -Force
    Write-Host "已備份 hosts 檔案至 $backupFilePath" -ForegroundColor Green

    # 讀取封鎖清單檔案 (使用絕對路徑)
    if (Test-Path -Path $hostsTxtPath) {
        $blockList = Get-Content -Path $hostsTxtPath
        # 將封鎖清單附加到 hosts 檔案
        Add-Content -Path $hostsFilePath -Value $blockList
        Write-Host "已將封鎖清單更新至 hosts 檔案" -ForegroundColor Green
    } else {
        Write-Host "錯誤：找不到封鎖清單檔案 ($hostsTxtPath)" -ForegroundColor Red
    }

    # 清除 DNS 快取 (確保變更立即生效)
    ipconfig /flushdns
    Write-Host "已清除 DNS 快取" -ForegroundColor Green
} else {
    Write-Host "錯誤：找不到 hosts 檔案 ($hostsFilePath)" -ForegroundColor Red
}

# 暫停腳本執行，讓使用者查看結果
Pause

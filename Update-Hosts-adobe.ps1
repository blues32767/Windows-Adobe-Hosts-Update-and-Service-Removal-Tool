# 檢查腳本是否以管理員權限運行 (Check if script is running with administrator privileges)
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # 如果不是，則重新啟動程式並要求管理員權限 (If not, restart the script with admin rights)
    Start-Process powershell.exe -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 設置 hosts 檔案的路徑 (Set the path for hosts file)
$hostsFilePath = "$env:SystemRoot\System32\drivers\etc\hosts"

# 設置備份檔案的路徑 (Set the path for backup file)
$backupFilePath = "$env:SystemRoot\System32\drivers\etc\hosts.bak"

# 獲取腳本所在的目錄 (Get the directory where script is located)
$scriptDirectory = $PSScriptRoot

# 構建 hosts.txt 檔案的完整路徑 (Build the full path for hosts.txt file)
$hostsTxtPath = Join-Path -Path $scriptDirectory -ChildPath "hosts.txt"

# 檢查 hosts 檔案是否存在 (Check if hosts file exists)
if (Test-Path -Path $hostsFilePath) {
    # 備份原始的 hosts 檔案 (Backup the original hosts file)
    Copy-Item -Path $hostsFilePath -Destination $backupFilePath -Force
    Write-Host "已備份 hosts 檔案至 $backupFilePath (Hosts file backed up to $backupFilePath)" -ForegroundColor Green

    # 讀取新的封鎖清單檔案 (使用絕對路徑) (Read blocklist file using absolute path)
    if (Test-Path -Path $hostsTxtPath) {
        # 讀取現有的 hosts 檔案內容
        $existingHosts = Get-Content -Path $hostsFilePath
        
        # 讀取封鎖清單內容
        $blockList = Get-Content -Path $hostsTxtPath
        
        # 合併兩個清單
        $combinedList = $existingHosts + $blockList
        
        # 使用哈希表來去除重複項目，同時保留註釋行
        $uniqueEntries = @{}
        $commentLines = @()
        $headerLines = @()
        $seenDomains = @{}
        
        foreach ($line in $combinedList) {
            # 跳過空行
            if ([string]::IsNullOrWhiteSpace($line)) {
                continue
            }
            
            # 保留註釋行
            if ($line.Trim().StartsWith("#")) {
                if (-not $commentLines.Contains($line)) {
                    $commentLines += $line
                }
                continue
            }
            
            # 處理非註釋行
            $parts = $line.Trim() -split '\s+', 2
            if ($parts.Count -ge 2) {
                $ip = $parts[0]
                $domain = $parts[1]
                
                # 如果域名包含註釋，則分離它們
                if ($domain.Contains("#")) {
                    $domainParts = $domain -split '#', 2
                    $domain = $domainParts[0].Trim()
                    $comment = "#" + $domainParts[1]
                }
                
                # 檢查域名是否已經存在
                if (-not $seenDomains.ContainsKey($domain)) {
                    $seenDomains[$domain] = $true
                    $uniqueEntries[$line] = $true
                }
            } else {
                # 保留不符合標準格式的行
                if (-not $headerLines.Contains($line)) {
                    $headerLines += $line
                }
            }
        }
        
        # 構建最終的 hosts 檔案內容
        $finalContent = $headerLines + $commentLines + $uniqueEntries.Keys
        
        # 寫入到 hosts 檔案
        $finalContent | Out-File -FilePath $hostsFilePath -Encoding ASCII
        
        Write-Host "已將封鎖清單內容新增至 hosts 檔案，並移除重複項目 (Blocklist content added to hosts file with duplicates removed)" -ForegroundColor Green
    } else {
        Write-Host "錯誤：找不到封鎖清單檔案 ($hostsTxtPath) (Error: Blocklist file not found ($hostsTxtPath))" -ForegroundColor Red
    }

    # 清除 DNS 緩存 (確保變更立即生效) (Clear DNS cache to ensure changes take effect immediately)
    ipconfig /flushdns
    Write-Host "已清除 DNS 緩存 (DNS cache cleared)" -ForegroundColor Green
} else {
    Write-Host "錯誤：找不到 hosts 檔案 ($hostsFilePath) (Error: Hosts file not found ($hostsFilePath))" -ForegroundColor Red
}

# 功能1：禁用 AGSService 服務 (Feature 1: Disable AGSService)
Write-Host "正在禁用 AGSService 服務... (Disabling AGSService...)" -ForegroundColor Yellow
try {
    $service = Get-Service -Name "AGSService" -ErrorAction SilentlyContinue
    if ($service) {
        Stop-Service -Name "AGSService" -Force -ErrorAction SilentlyContinue
        Set-Service -Name "AGSService" -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "已成功禁用 AGSService 服務 (AGSService successfully disabled)" -ForegroundColor Green
    } else {
        Write-Host "找不到 AGSService 服務 (AGSService not found)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "禁用 AGSService 服務時發生錯誤: $_ (Error disabling AGSService: $_)" -ForegroundColor Red
}

# 功能2：刪除 AGSService 服務和 AdobeGCClient 資料夾 (Feature 2: Delete AGSService and AdobeGCClient folder)
Write-Host "正在刪除 AGSService 服務... (Deleting AGSService...)" -ForegroundColor Yellow
try {
    cmd /c "sc delete AGSService"
    Write-Host "已執行刪除 AGSService 服務命令 (AGSService deletion command executed)" -ForegroundColor Green
} catch {
    Write-Host "刪除 AGSService 服務時發生錯誤: $_ (Error deleting AGSService: $_)" -ForegroundColor Red
}

$adobeGCClientPath = "C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient"
Write-Host "正在刪除 AdobeGCClient 資料夾... (Deleting AdobeGCClient folder...)" -ForegroundColor Yellow
if (Test-Path -Path $adobeGCClientPath) {
    try {
        Remove-Item -Path $adobeGCClientPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "已成功刪除 AdobeGCClient 資料夾 (AdobeGCClient folder successfully deleted)" -ForegroundColor Green
    } catch {
        Write-Host "刪除 AdobeGCClient 資料夾時發生錯誤: $_ (Error deleting AdobeGCClient folder: $_)" -ForegroundColor Red
    }
} else {
    Write-Host "找不到 AdobeGCClient 資料夾 (AdobeGCClient folder not found)" -ForegroundColor Yellow
}

# 功能3：刪除 AAMUpdater 服務和 UWA 資料夾 (Feature 3: Delete AAMUpdater and UWA folder)
Write-Host "正在刪除 AAMUpdater 服務... (Deleting AAMUpdater service...)" -ForegroundColor Yellow
try {
    cmd /c "sc delete AAMUpdater"
    Write-Host "已執行刪除 AAMUpdater 服務命令 (AAMUpdater deletion command executed)" -ForegroundColor Green
} catch {
    Write-Host "刪除 AAMUpdater 服務時發生錯誤: $_ (Error deleting AAMUpdater: $_)" -ForegroundColor Red
}

$uwaPath = "C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\UWA"
Write-Host "正在刪除 UWA 資料夾... (Deleting UWA folder...)" -ForegroundColor Yellow
if (Test-Path -Path $uwaPath) {
    try {
        Remove-Item -Path $uwaPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "已成功刪除 UWA 資料夾 (UWA folder successfully deleted)" -ForegroundColor Green
    } catch {
        Write-Host "刪除 UWA 資料夾時發生錯誤: $_ (Error deleting UWA folder: $_)" -ForegroundColor Red
    }
} else {
    Write-Host "找不到 UWA 資料夾 (UWA folder not found)" -ForegroundColor Yellow
}

# 暫停執行程序，讓使用者查看結果 (Pause execution to let user see the results)
Write-Host "`n所有操作已完成！(All operations completed!)" -ForegroundColor Cyan
Pause

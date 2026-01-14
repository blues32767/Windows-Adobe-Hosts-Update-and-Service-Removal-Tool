# 檢查當前執行策略
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
Write-Host "當前執行策略為: $currentPolicy (Current execution policy: $currentPolicy)" -ForegroundColor Yellow

if ($currentPolicy -eq "Restricted") {
    Write-Host "錯誤：當前執行策略為 Restricted，無法運行腳本。 (Error: Current execution policy is Restricted, script cannot run.)" -ForegroundColor Red
    Write-Host "需要將執行策略更改為 Unrestricted 以繼續。 (Need to change execution policy to Unrestricted to proceed.)" -ForegroundColor Yellow
    $response = Read-Host "是否同意更改執行策略？(輸入 'Y' 同意，輸入其他則退出) (Do you agree to change the policy? Enter 'Y' to agree, anything else to exit)"
    
    if ($response -eq 'Y' -or $response -eq 'y') {
        try {
            Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force
            Write-Host "執行策略已成功更改為 Unrestricted (Execution policy successfully changed to Unrestricted)" -ForegroundColor Green
        } catch {
            Write-Host "更改執行策略失敗，請以管理員身份運行此腳本: $($_) (Failed to change execution policy, please run as administrator: $($_))" -ForegroundColor Red
            exit
        }
    } else {
        Write-Host "使用者不同意更改執行策略，腳本將退出。 (User did not agree to change policy, script will exit.)" -ForegroundColor Red
        exit
    }
}

# 檢查是否以管理員權限運行
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 定義防火牆封鎖函數 (已修正刪除邏輯)
function Block-AdobeFirewall {
    param (
        [switch]$Delete
    )

    if ($Delete) {
        Write-Host "正在搜尋並刪除 Adobe 防火牆規則... (Searching and removing Adobe firewall rules...)" -ForegroundColor Yellow
        try {
            # 改用 DisplayName 通配符直接搜尋，速度更快
            $rules = Get-NetFirewallRule -DisplayName "*adobe-block*" -ErrorAction SilentlyContinue
            
            if ($rules) {
                # 統計數量
                $count = @($rules).Count
                Write-Host "發現 $count 條相關規則，正在執行批量刪除，請稍候... (Found $count rules, performing bulk deletion, please wait...)" -ForegroundColor Yellow
                
                # [關鍵修正] 使用管道批量刪除，不使用 Foreach 迴圈列印，避免刷屏和假死現象
                $rules | Remove-NetFirewallRule -ErrorAction SilentlyContinue
                
                Write-Host "防火牆規則刪除完成 (Firewall rules deletion completed)" -ForegroundColor Green
            } else {
                Write-Host "未發現相關防火牆規則 (No related firewall rules found)" -ForegroundColor Green
            }
        } catch {
            Write-Host "刪除防火牆規則時發生錯誤: $($_) (Error deleting firewall rules: $($_))" -ForegroundColor Red
        }
        return
    }

    $folders = @(
        "C:\Program Files\Adobe",
        "C:\Program Files\Common Files\Adobe",
        "C:\Program Files\Maxon Cinema 4D R25",
        "C:\Program Files\Red Giant",
        "C:\Program Files (x86)\Adobe",
        "C:\Program Files (x86)\Common Files\Adobe"
    )

    Write-Host "正在封鎖Adobe相關可執行文件的防火牆規則... (Blocking Adobe-related executables in firewall...)" -ForegroundColor Yellow
    foreach ($folder in $folders) {
        if (Test-Path -Path $folder) {
            $executables = Get-ChildItem -Path $folder -Recurse -Include *.exe -ErrorAction SilentlyContinue
            foreach ($exe in $executables) {
                $exeName = [System.IO.Path]::GetFileNameWithoutExtension($exe.Name)
                $ruleName = "$exeName adobe-block"
                
                # 簡單檢查是否已存在，避免重複建立 (雖然 New-NetFirewallRule 可能會報錯，但這裡做個預防)
                # 為了效能，這裡保持原本的 Try-Catch 結構，但建立時可考慮檢查
                
                Write-Host "正在封鎖: $exeName (Blocking: $exeName)" -ForegroundColor Yellow
                try {
                    # 創建出站規則
                    New-NetFirewallRule -DisplayName $ruleName -Direction Outbound -Program $exe.FullName -Action Block -ErrorAction SilentlyContinue | Out-Null
                    # 創建入站規則
                    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Program $exe.FullName -Action Block -ErrorAction SilentlyContinue | Out-Null
                    Write-Host "已成功封鎖: $exeName (Successfully blocked: $exeName)" -ForegroundColor Green
                } catch {
                    Write-Host "封鎖 $exeName 時發生錯誤: $($_) (Error blocking ${exeName}: $($_))" -ForegroundColor Red
                }
            }
        }
    }
    Write-Host "防火牆封鎖完成 (Firewall blocking completed)" -ForegroundColor Green
}

# 定義主要更新函數
function Update-HostsAndServices {
    # 設置 hosts 檔案路徑
    $hostsFilePath = "$env:SystemRoot\System32\drivers\etc\hosts"
    $backupFilePath = "$env:SystemRoot\System32\drivers\etc\hosts.bak"
    $url = "https://a.dove.isdumb.one/list.txt"

    # 更新 hosts 檔案
    if (Test-Path -Path $hostsFilePath) {
        Copy-Item -Path $hostsFilePath -Destination $backupFilePath -Force
        Write-Host "已備份 hosts 檔案至 $backupFilePath (Hosts file backed up to $backupFilePath)" -ForegroundColor Green

        try {
            $webContent = Invoke-WebRequest -Uri $url -UseBasicParsing
            $blockList = $webContent.Content -split "`n"
            $existingHosts = Get-Content -Path $hostsFilePath
            $combinedList = $existingHosts + $blockList
            
            $uniqueEntries = @{}
            $commentLines = @()
            $headerLines = @()
            $seenDomains = @{}
            
            foreach ($line in $combinedList) {
                if ([string]::IsNullOrWhiteSpace($line)) { continue }
                if ($line.Trim().StartsWith("#")) {
                    if (-not $commentLines.Contains($line)) { $commentLines += $line }
                    continue
                }
                $parts = $line.Trim() -split '\s+', 2
                if ($parts.Count -ge 2) {
                    $ip = $parts[0]
                    $domain = $parts[1]
                    if ($domain.Contains("#")) {
                        $domainParts = $domain -split '#', 2
                        $domain = $domainParts[0].Trim()
                        $comment = "#" + $domainParts[1]
                    }
                    if (-not $seenDomains.ContainsKey($domain)) {
                        $seenDomains[$domain] = $true
                        $uniqueEntries[$line] = $true
                    }
                } else {
                    if (-not $headerLines.Contains($line)) { $headerLines += $line }
                }
            }
            
            $finalContent = $headerLines + $commentLines + $uniqueEntries.Keys
            $finalContent | Out-File -FilePath $hostsFilePath -Encoding ASCII
            Write-Host "已從 $url 更新 hosts 檔案並移除重複項目 (Hosts file updated from $url and duplicates removed)" -ForegroundColor Green
            
            ipconfig /flushdns
            Write-Host "已清除 DNS 快取 (DNS cache cleared)" -ForegroundColor Green
        } catch {
            Write-Host "從 ${url} 更新 hosts 檔案失敗: $($_) (Failed to update hosts file from ${url}: $($_))" -ForegroundColor Red
        }
    } else {
        Write-Host "錯誤：找不到 hosts 檔案 ($hostsFilePath) (Error: Hosts file not found ($hostsFilePath))" -ForegroundColor Red
    }

    # 禁用和刪除 Adobe 服務
    Write-Host "正在禁用 AGSService 服務... (Disabling AGSService service...)" -ForegroundColor Yellow
    try {
        $service = Get-Service -Name "AGSService" -ErrorAction SilentlyContinue
        if ($service) {
            Stop-Service -Name "AGSService" -Force -ErrorAction SilentlyContinue
            Set-Service -Name "AGSService" -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "已成功禁用 AGSService 服務 (AGSService service successfully disabled)" -ForegroundColor Green
        }
    } catch {
        Write-Host "禁用 AGSService 服務時發生錯誤: $($_) (Error disabling AGSService service: $($_))" -ForegroundColor Red
    }

    Write-Host "正在刪除 AGSService 服務... (Deleting AGSService service...)" -ForegroundColor Yellow
    try {
        cmd /c "sc delete AGSService"
        Write-Host "已執行刪除 AGSService 服務命令 (AGSService service deletion command executed)" -ForegroundColor Green
    } catch {
        Write-Host "刪除 AGSService 服務時發生錯誤: $($_) (Error deleting AGSService service: $($_))" -ForegroundColor Red
    }

    Write-Host "正在刪除 AAMUpdater 服務... (Deleting AAMUpdater service...)" -ForegroundColor Yellow
    try {
        cmd /c "sc delete AAMUpdater"
        Write-Host "已執行刪除 AAMUpdater 服務命令 (AAMUpdater service deletion command executed)" -ForegroundColor Green
    } catch {
        Write-Host "刪除 AAMUpdater 服務時發生錯誤: $($_) (Error deleting AAMUpdater service: $($_))" -ForegroundColor Red
    }

    # 刪除 Adobe 相關資料夾
    $adobeGCClientPath = "C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient"
    $uwaPath = "C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\UWA"

    if (Test-Path -Path $adobeGCClientPath) {
        try {
            Remove-Item -Path $adobeGCClientPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "已成功刪除 AdobeGCClient 資料夾 (AdobeGCClient folder successfully deleted)" -ForegroundColor Green
        } catch {
            Write-Host "刪除 AdobeGCClient 資料夾時發生錯誤: $($_) (Error deleting AdobeGCClient folder: $($_))" -ForegroundColor Red
        }
    }

    if (Test-Path -Path $uwaPath) {
        try {
            Remove-Item -Path $uwaPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "已成功刪除 UWA 資料夾 (UWA folder successfully deleted)" -ForegroundColor Green
        } catch {
            Write-Host "刪除 UWA 資料夾時發生錯誤: $($_) (Error deleting UWA folder: $($_))" -ForegroundColor Red
        }
    }

    # 檢查並刪除 Adobe 相關排程任務
    $adobeTasks = @("Adobe Acrobat Update Task", "Adobe-Genuine-Software-Integrity-Scheduler")
    Write-Host "正在檢查並刪除 Adobe 相關排程任務... (Checking and deleting Adobe-related scheduled tasks...)" -ForegroundColor Yellow
    
    foreach ($task in $adobeTasks) {
        try {
            $taskExists = Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
            if ($taskExists) {
                Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction Stop
                Write-Host "已成功刪除排程任務: $task (Scheduled task $task successfully deleted)" -ForegroundColor Green
            } else {
                Write-Host "未找到排程任務: $task (Scheduled task $task not found)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "刪除排程任務 ${task} 時發生錯誤: $($_) (Error deleting scheduled task ${task}: $($_))" -ForegroundColor Red
        }
    }

    # 功能 3：修改註冊表以禁用 AGS
    Write-Host "正在修改註冊表以禁用 AGS... (Modifying registry to disable AGS...)" -ForegroundColor Yellow
    try {
        $agsRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\AGSService"
        if (Test-Path $agsRegPath) {
            Set-ItemProperty -Path $agsRegPath -Name "Start" -Value 4 -ErrorAction Stop
            Write-Host "已成功在註冊表中禁用 AGSService (AGSService successfully disabled in registry)" -ForegroundColor Green
        } else {
            Write-Host "未找到 AGSService 的註冊表項目，可能已被移除 (AGSService registry entry not found, may have been removed)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "修改註冊表禁用 AGSService 時發生錯誤: $($_) (Error modifying registry to disable AGSService: $($_))" -ForegroundColor Red
    }

    # 功能 4：結束並移除 AdobeGCInvoker 進程及相關排程任務
    Write-Host "正在結束 AdobeGCInvoker 進程... (Terminating AdobeGCInvoker process...)" -ForegroundColor Yellow
    try {
        $gcInvokerProcess = Get-Process -Name "AGCInvokerUtility" -ErrorAction SilentlyContinue
        if ($gcInvokerProcess) {
            Stop-Process -Name "AGCInvokerUtility" -Force -ErrorAction Stop
            Write-Host "已成功結束 AdobeGCInvoker 進程 (AdobeGCInvoker process successfully terminated)" -ForegroundColor Green
        } else {
            Write-Host "未找到 AdobeGCInvoker 進程 (AdobeGCInvoker process not found)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "結束 AdobeGCInvoker 進程時發生錯誤: $($_) (Error terminating AdobeGCInvoker process: $($_))" -ForegroundColor Red
    }

    $gcInvokerTask = "AdobeGCInvoker-1"
    Write-Host "正在檢查並刪除 AdobeGCInvoker 排程任務... (Checking and deleting AdobeGCInvoker scheduled task...)" -ForegroundColor Yellow
    try {
        $taskExists = Get-ScheduledTask -TaskName $gcInvokerTask -ErrorAction SilentlyContinue
        if ($taskExists) {
            Unregister-ScheduledTask -TaskName $gcInvokerTask -Confirm:$false -ErrorAction Stop
            Write-Host "已成功刪除排程任務: $gcInvokerTask (Scheduled task $gcInvokerTask successfully deleted)" -ForegroundColor Green
        } else {
            Write-Host "未找到排程任務: $gcInvokerTask (Scheduled task $gcInvokerTask not found)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "刪除排程任務 ${gcInvokerTask} 時發生錯誤: $($_) (Error deleting scheduled task ${gcInvokerTask}: $($_))" -ForegroundColor Red
    }

    # 功能 5：禁用 Adobe Creative Cloud 背景進程及相關排程任務
    Write-Host "正在結束 Adobe Creative Cloud 相關進程... (Terminating Adobe Creative Cloud related processes...)" -ForegroundColor Yellow
    $ccProcesses = @("Creative Cloud", "CCXProcess", "CCLibrary")
    foreach ($process in $ccProcesses) {
        try {
            $ccProcess = Get-Process -Name $process -ErrorAction SilentlyContinue
            if ($ccProcess) {
                Stop-Process -Name $process -Force -ErrorAction Stop
                Write-Host "已成功結束進程: $process (Process $process successfully terminated)" -ForegroundColor Green
            } else {
                Write-Host "未找到進程: $process (Process $process not found)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "結束進程 ${process} 時發生錯誤: $($_) (Error terminating process ${process}: $($_))" -ForegroundColor Red
        }
    }

    $ccTask = "Adobe Creative Cloud"
    Write-Host "正在檢查並刪除 Adobe Creative Cloud 排程任務... (Checking and deleting Adobe Creative Cloud scheduled task...)" -ForegroundColor Yellow
    try {
        $taskExists = Get-ScheduledTask -TaskName $ccTask -ErrorAction SilentlyContinue
        if ($taskExists) {
            Unregister-ScheduledTask -TaskName $ccTask -Confirm:$false -ErrorAction Stop
            Write-Host "已成功刪除排程任務: $ccTask (Scheduled task $ccTask successfully deleted)" -ForegroundColor Green
        } else {
            Write-Host "未找到排程任務: $ccTask (Scheduled task $ccTask not found)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "刪除排程任務 ${ccTask} 時發生錯誤: $($_) (Error deleting scheduled task ${ccTask}: $($_))" -ForegroundColor Red
    }

    # 執行防火牆封鎖功能
    Block-AdobeFirewall
}

# 定義還原預設值函數
function Restore-DefaultSettings {
    Write-Host "`n=== 正在開始還原所有設定 (Starting full restoration) ===" -ForegroundColor Cyan
    
    # 1. 還原 HOSTS 檔案
    $hostsFilePath = "$env:SystemRoot\System32\drivers\etc\hosts"
    $cleanHostsContent = @"
# Copyright (c) 1993-2006 Microsoft Corp.
#
# This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
#
# This file contains the mappings of IP addresses to host names. Each
# entry should be kept on an individual line. The IP address should
# be placed in the first column followed by the corresponding host name.
# The IP address and the host name should be separated by at least one
# space.
#
# Additionally, comments (such as these) may be inserted on individual
# lines or following the machine name denoted by a '#' symbol.
#
# For example:
#
# 102.54.94.97 rhino.acme.com # source server
# 38.25.63.10 x.acme.com # x client host
# localhost name resolution is handle within DNS itself.
# 127.0.0.1 localhost
# ::1 localhost
"@

    try {
        # 確保檔案可寫
        if (Test-Path $hostsFilePath) {
            Set-ItemProperty -Path $hostsFilePath -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
        }
        
        $cleanHostsContent | Out-File -FilePath $hostsFilePath -Encoding ASCII -Force
        Write-Host "已將 HOSTS 檔案還原為預設純淨狀態 (HOSTS file restored to default clean state)" -ForegroundColor Green
        
        ipconfig /flushdns | Out-Null
        Write-Host "已清除 DNS 快取 (DNS cache cleared)" -ForegroundColor Green
    } catch {
        Write-Host "還原 HOSTS 檔案時發生錯誤: $($_) (Error restoring HOSTS file: $($_))" -ForegroundColor Red
    }

    # 2. 移除排程任務
    $taskName = "WeeklyHostsUpdate"
    Write-Host "正在檢查自動更新排程... (Checking auto-update schedule...)" -ForegroundColor Yellow
    try {
        $taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
        if ($taskExists) {
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction Stop
            Write-Host "已成功移除 WeeklyHostsUpdate 排程 (WeeklyHostsUpdate task removed)" -ForegroundColor Green
        } else {
            Write-Host "未發現自動更新排程，無需移除 (No auto-update task found)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "移除排程任務失敗: $($_) (Failed to remove scheduled task: $($_))" -ForegroundColor Red
    }

    # 3. 移除防火牆規則 (呼叫已修正的函數)
    Block-AdobeFirewall -Delete

    # 4. 顯示重要提示
    Write-Host "`n[重要提示 / Important Note]" -ForegroundColor Magenta
    Write-Host "HOSTS、防火牆與排程已還原。" -ForegroundColor Magenta
    Write-Host "由於此腳本曾在更新模式下執行了 'sc delete' (刪除服務) 並刪除了 Adobe 相關資料夾，這些操作無法透過腳本還原。" -ForegroundColor Magenta
    Write-Host "如果您的 Adobe 軟體無法開啟，請重新安裝 Adobe Creative Cloud。" -ForegroundColor Magenta
    Write-Host "(Since services and files were deleted by previous runs, please reinstall Adobe Creative Cloud if apps fail to launch.)" -ForegroundColor Magenta
}

# 使用者選擇更新模式
Write-Host "`n請選擇操作模式 (Please select operation mode):" -ForegroundColor Cyan
Write-Host "1. 僅執行本次更新 (Run update once)" -ForegroundColor Yellow
Write-Host "2. 設定每周自動更新 (Schedule weekly update)" -ForegroundColor Yellow
Write-Host "3. 僅刪除防火牆規則 (Delete firewall rules only)" -ForegroundColor Yellow
Write-Host "4. 全部還原 (Restore default settings: Reset HOSTS, remove schedule & firewall)" -ForegroundColor Green
$choice = Read-Host "輸入 1, 2, 3 或 4 (Enter 1, 2, 3 or 4)"

if ($choice -eq "1") {
    Update-HostsAndServices
} elseif ($choice -eq "2") {
    $taskName = "WeeklyHostsUpdate"
    $taskDescription = "Weekly update of hosts file, Adobe services cleanup, and firewall rules (每周更新 hosts 檔案、Adobe 服務清理和防火牆規則)"
    $scriptPath = $PSCommandPath
    $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At "9:00AM"
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    
    try {
        Register-ScheduledTask -TaskName $taskName -Description $taskDescription -Trigger $trigger -Action $action -RunLevel Highest -Force
        Write-Host "已成功設定每周一上午9點自動更新 (Weekly update scheduled successfully for every Monday at 9:00 AM)" -ForegroundColor Green
        Update-HostsAndServices
    } catch {
        Write-Host "設定排程任務失敗: $($_) (Failed to set up scheduled task: $($_))" -ForegroundColor Red
    }
} elseif ($choice -eq "3") {
    Block-AdobeFirewall -Delete
} elseif ($choice -eq "4") {
    Restore-DefaultSettings
} else {
    Write-Host "無效的選擇，腳本將退出 (Invalid choice, script will exit)" -ForegroundColor Red
}

# 顯示完成訊息和作者資訊
Write-Host "`n所有操作已完成！(All operations completed!)" -ForegroundColor Cyan
Write-Host "您可以在 '工作排程器' 中查看或修改任務 'WeeklyHostsUpdate' (You can view or modify the 'WeeklyHostsUpdate' task in Task Scheduler)" -ForegroundColor Yellow
$authorInfo = @"

====================================================
   Adobe Hosts Update, Service Removal, and Firewall Tool
   Author/作者: blues32767
   Version/版本: v3.20250420 (Modified with Loop Fix)
   https://github.com/blues32767
   Firewall functionality adapted from: https://github.com/ph33nx
====================================================

"@
Write-Host $authorInfo -ForegroundColor Green
Pause
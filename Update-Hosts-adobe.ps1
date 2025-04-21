# �ˬd��e���浦��
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
Write-Host "��e���浦����: $currentPolicy (Current execution policy: $currentPolicy)" -ForegroundColor Yellow

if ($currentPolicy -eq "Restricted") {
    Write-Host "���~�G��e���浦���� Restricted�A�L�k�B��}���C (Error: Current execution policy is Restricted, script cannot run.)" -ForegroundColor Red
    Write-Host "�ݭn�N���浦����אּ Unrestricted �H�~��C (Need to change execution policy to Unrestricted to proceed.)" -ForegroundColor Yellow
    $response = Read-Host "�O�_�P�N�����浦���H(��J 'Y' �P�N�A��J��L�h�h�X) (Do you agree to change the policy? Enter 'Y' to agree, anything else to exit)"
    
    if ($response -eq 'Y' -or $response -eq 'y') {
        try {
            Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force
            Write-Host "���浦���w���\��אּ Unrestricted (Execution policy successfully changed to Unrestricted)" -ForegroundColor Green
        } catch {
            Write-Host "�����浦�����ѡA�ХH�޲z�������B�榹�}��: $($_) (Failed to change execution policy, please run as administrator: $($_))" -ForegroundColor Red
            exit
        }
    } else {
        Write-Host "�ϥΪ̤��P�N�����浦���A�}���N�h�X�C (User did not agree to change policy, script will exit.)" -ForegroundColor Red
        exit
    }
}

# �ˬd�O�_�H�޲z���v���B��
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# �w�q�����������
function Block-AdobeFirewall {
    param (
        [switch]$Delete
    )

    if ($Delete) {
        Write-Host "���b�R���{����Adobe������W�h... (Deleting existing Adobe firewall rules...)" -ForegroundColor Yellow
        try {
            $rules = Get-NetFirewallRule | Where-Object { $_.DisplayName -like '*adobe-block' }
            foreach ($rule in $rules) {
                Remove-NetFirewallRule -DisplayName $rule.DisplayName -ErrorAction SilentlyContinue
                Write-Host "�w�R��������W�h: $($rule.DisplayName) (Firewall rule deleted: $($rule.DisplayName))" -ForegroundColor Green
            }
            Write-Host "������W�h�R������ (Firewall rules deletion completed)" -ForegroundColor Green
        } catch {
            Write-Host "�R��������W�h�ɵo�Ϳ��~: $($_) (Error deleting firewall rules: $($_))" -ForegroundColor Red
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

    Write-Host "���b����Adobe�����i�����󪺨�����W�h... (Blocking Adobe-related executables in firewall...)" -ForegroundColor Yellow
    foreach ($folder in $folders) {
        if (Test-Path -Path $folder) {
            $executables = Get-ChildItem -Path $folder -Recurse -Include *.exe -ErrorAction SilentlyContinue
            foreach ($exe in $executables) {
                $exeName = [System.IO.Path]::GetFileNameWithoutExtension($exe.Name)
                $ruleName = "$exeName adobe-block"
                Write-Host "���b����: $exeName (Blocking: $exeName)" -ForegroundColor Yellow
                try {
                    # �ЫإX���W�h
                    New-NetFirewallRule -DisplayName $ruleName -Direction Outbound -Program $exe.FullName -Action Block -ErrorAction SilentlyContinue | Out-Null
                    # �ЫؤJ���W�h
                    New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Program $exe.FullName -Action Block -ErrorAction SilentlyContinue | Out-Null
                    Write-Host "�w���\����: $exeName (Successfully blocked: $exeName)" -ForegroundColor Green
                } catch {
                    Write-Host "���� $exeName �ɵo�Ϳ��~: $($_) (Error blocking ${exeName}: $($_))" -ForegroundColor Red
                }
            }
        }
    }
    Write-Host "��������꧹�� (Firewall blocking completed)" -ForegroundColor Green
}

# �w�q�D�n��s���
function Update-HostsAndServices {
    # �]�m hosts �ɮ׸��|
    $hostsFilePath = "$env:SystemRoot\System32\drivers\etc\hosts"
    $backupFilePath = "$env:SystemRoot\System32\drivers\etc\hosts.bak"
    $url = "https://a.dove.isdumb.one/list.txt"

    # ��s hosts �ɮ�
    if (Test-Path -Path $hostsFilePath) {
        Copy-Item -Path $hostsFilePath -Destination $backupFilePath -Force
        Write-Host "�w�ƥ� hosts �ɮצ� $backupFilePath (Hosts file backed up to $backupFilePath)" -ForegroundColor Green

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
            Write-Host "�w�q $url ��s hosts �ɮרò������ƶ��� (Hosts file updated from $url and duplicates removed)" -ForegroundColor Green
            
            ipconfig /flushdns
            Write-Host "�w�M�� DNS �֨� (DNS cache cleared)" -ForegroundColor Green
        } catch {
            Write-Host "�q ${url} ��s hosts �ɮץ���: $($_) (Failed to update hosts file from ${url}: $($_))" -ForegroundColor Red
        }
    } else {
        Write-Host "���~�G�䤣�� hosts �ɮ� ($hostsFilePath) (Error: Hosts file not found ($hostsFilePath))" -ForegroundColor Red
    }

    # �T�ΩM�R�� Adobe �A��
    Write-Host "���b�T�� AGSService �A��... (Disabling AGSService service...)" -ForegroundColor Yellow
    try {
        $service = Get-Service -Name "AGSService" -ErrorAction SilentlyContinue
        if ($service) {
            Stop-Service -Name "AGSService" -Force -ErrorAction SilentlyContinue
            Set-Service -Name "AGSService" -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "�w���\�T�� AGSService �A�� (AGSService service successfully disabled)" -ForegroundColor Green
        }
    } catch {
        Write-Host "�T�� AGSService �A�Ȯɵo�Ϳ��~: $($_) (Error disabling AGSService service: $($_))" -ForegroundColor Red
    }

    Write-Host "���b�R�� AGSService �A��... (Deleting AGSService service...)" -ForegroundColor Yellow
    try {
        cmd /c "sc delete AGSService"
        Write-Host "�w����R�� AGSService �A�ȩR�O (AGSService service deletion command executed)" -ForegroundColor Green
    } catch {
        Write-Host "�R�� AGSService �A�Ȯɵo�Ϳ��~: $($_) (Error deleting AGSService service: $($_))" -ForegroundColor Red
    }

    Write-Host "���b�R�� AAMUpdater �A��... (Deleting AAMUpdater service...)" -ForegroundColor Yellow
    try {
        cmd /c "sc delete AAMUpdater"
        Write-Host "�w����R�� AAMUpdater �A�ȩR�O (AAMUpdater service deletion command executed)" -ForegroundColor Green
    } catch {
        Write-Host "�R�� AAMUpdater �A�Ȯɵo�Ϳ��~: $($_) (Error deleting AAMUpdater service: $($_))" -ForegroundColor Red
    }

    # �R�� Adobe ������Ƨ�
    $adobeGCClientPath = "C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient"
    $uwaPath = "C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\UWA"

    if (Test-Path -Path $adobeGCClientPath) {
        try {
            Remove-Item -Path $adobeGCClientPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "�w���\�R�� AdobeGCClient ��Ƨ� (AdobeGCClient folder successfully deleted)" -ForegroundColor Green
        } catch {
            Write-Host "�R�� AdobeGCClient ��Ƨ��ɵo�Ϳ��~: $($_) (Error deleting AdobeGCClient folder: $($_))" -ForegroundColor Red
        }
    }

    if (Test-Path -Path $uwaPath) {
        try {
            Remove-Item -Path $uwaPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "�w���\�R�� UWA ��Ƨ� (UWA folder successfully deleted)" -ForegroundColor Green
        } catch {
            Write-Host "�R�� UWA ��Ƨ��ɵo�Ϳ��~: $($_) (Error deleting UWA folder: $($_))" -ForegroundColor Red
        }
    }

    # �ˬd�çR�� Adobe �����Ƶ{����
    $adobeTasks = @("Adobe Acrobat Update Task", "Adobe-Genuine-Software-Integrity-Scheduler")
    Write-Host "���b�ˬd�çR�� Adobe �����Ƶ{����... (Checking and deleting Adobe-related scheduled tasks...)" -ForegroundColor Yellow
    
    foreach ($task in $adobeTasks) {
        try {
            $taskExists = Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue
            if ($taskExists) {
                Unregister-ScheduledTask -TaskName $task -Confirm:$false -ErrorAction Stop
                Write-Host "�w���\�R���Ƶ{����: $task (Scheduled task $task successfully deleted)" -ForegroundColor Green
            } else {
                Write-Host "�����Ƶ{����: $task (Scheduled task $task not found)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "�R���Ƶ{���� ${task} �ɵo�Ϳ��~: $($_) (Error deleting scheduled task ${task}: $($_))" -ForegroundColor Red
        }
    }

    # �\�� 3�G�ק���U��H�T�� AGS
    Write-Host "���b�ק���U��H�T�� AGS... (Modifying registry to disable AGS...)" -ForegroundColor Yellow
    try {
        $agsRegPath = "HKLM:\SYSTEM\CurrentControlSet\Services\AGSService"
        if (Test-Path $agsRegPath) {
            Set-ItemProperty -Path $agsRegPath -Name "Start" -Value 4 -ErrorAction Stop
            Write-Host "�w���\�b���U���T�� AGSService (AGSService successfully disabled in registry)" -ForegroundColor Green
        } else {
            Write-Host "����� AGSService �����U���ءA�i��w�Q���� (AGSService registry entry not found, may have been removed)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "�ק���U��T�� AGSService �ɵo�Ϳ��~: $($_) (Error modifying registry to disable AGSService: $($_))" -ForegroundColor Red
    }

    # �\�� 4�G�����ò��� AdobeGCInvoker �i�{�ά����Ƶ{����
    Write-Host "���b���� AdobeGCInvoker �i�{... (Terminating AdobeGCInvoker process...)" -ForegroundColor Yellow
    try {
        $gcInvokerProcess = Get-Process -Name "AGCInvokerUtility" -ErrorAction SilentlyContinue
        if ($gcInvokerProcess) {
            Stop-Process -Name "AGCInvokerUtility" -Force -ErrorAction Stop
            Write-Host "�w���\���� AdobeGCInvoker �i�{ (AdobeGCInvoker process successfully terminated)" -ForegroundColor Green
        } else {
            Write-Host "����� AdobeGCInvoker �i�{ (AdobeGCInvoker process not found)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "���� AdobeGCInvoker �i�{�ɵo�Ϳ��~: $($_) (Error terminating AdobeGCInvoker process: $($_))" -ForegroundColor Red
    }

    $gcInvokerTask = "AdobeGCInvoker-1"
    Write-Host "���b�ˬd�çR�� AdobeGCInvoker �Ƶ{����... (Checking and deleting AdobeGCInvoker scheduled task...)" -ForegroundColor Yellow
    try {
        $taskExists = Get-ScheduledTask -TaskName $gcInvokerTask -ErrorAction SilentlyContinue
        if ($taskExists) {
            Unregister-ScheduledTask -TaskName $gcInvokerTask -Confirm:$false -ErrorAction Stop
            Write-Host "�w���\�R���Ƶ{����: $gcInvokerTask (Scheduled task $gcInvokerTask successfully deleted)" -ForegroundColor Green
        } else {
            Write-Host "�����Ƶ{����: $gcInvokerTask (Scheduled task $gcInvokerTask not found)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "�R���Ƶ{���� ${gcInvokerTask} �ɵo�Ϳ��~: $($_) (Error deleting scheduled task ${gcInvokerTask}: $($_))" -ForegroundColor Red
    }

    # �\�� 5�G�T�� Adobe Creative Cloud �I���i�{�ά����Ƶ{����
    Write-Host "���b���� Adobe Creative Cloud �����i�{... (Terminating Adobe Creative Cloud related processes...)" -ForegroundColor Yellow
    $ccProcesses = @("Creative Cloud", "CCXProcess", "CCLibrary")
    foreach ($process in $ccProcesses) {
        try {
            $ccProcess = Get-Process -Name $process -ErrorAction SilentlyContinue
            if ($ccProcess) {
                Stop-Process -Name $process -Force -ErrorAction Stop
                Write-Host "�w���\�����i�{: $process (Process $process successfully terminated)" -ForegroundColor Green
            } else {
                Write-Host "�����i�{: $process (Process $process not found)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "�����i�{ ${process} �ɵo�Ϳ��~: $($_) (Error terminating process ${process}: $($_))" -ForegroundColor Red
        }
    }

    $ccTask = "Adobe Creative Cloud"
    Write-Host "���b�ˬd�çR�� Adobe Creative Cloud �Ƶ{����... (Checking and deleting Adobe Creative Cloud scheduled task...)" -ForegroundColor Yellow
    try {
        $taskExists = Get-ScheduledTask -TaskName $ccTask -ErrorAction SilentlyContinue
        if ($taskExists) {
            Unregister-ScheduledTask -TaskName $ccTask -Confirm:$false -ErrorAction Stop
            Write-Host "�w���\�R���Ƶ{����: $ccTask (Scheduled task $ccTask successfully deleted)" -ForegroundColor Green
        } else {
            Write-Host "�����Ƶ{����: $ccTask (Scheduled task $ccTask not found)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "�R���Ƶ{���� ${ccTask} �ɵo�Ϳ��~: $($_) (Error deleting scheduled task ${ccTask}: $($_))" -ForegroundColor Red
    }

    # ���樾�������\��
    Block-AdobeFirewall
}

# �ϥΪ̿�ܧ�s�Ҧ�
Write-Host "`n�п�ܧ�s�Ҧ� (Please select update mode):" -ForegroundColor Cyan
Write-Host "1. �Ȱ��楻����s (Run update once)" -ForegroundColor Yellow
Write-Host "2. �]�w�C�P�۰ʧ�s (Schedule weekly update)" -ForegroundColor Yellow
Write-Host "3. �ȧR��������W�h (Delete firewall rules only)" -ForegroundColor Yellow
$choice = Read-Host "��J 1, 2 �� 3 (Enter 1, 2, or 3)"

if ($choice -eq "1") {
    Update-HostsAndServices
} elseif ($choice -eq "2") {
    $taskName = "WeeklyHostsUpdate"
    $taskDescription = "Weekly update of hosts file, Adobe services cleanup, and firewall rules (�C�P��s hosts �ɮסBAdobe �A�ȲM�z�M������W�h)"
    $scriptPath = $PSCommandPath
    $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At "9:00AM"
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    
    try {
        Register-ScheduledTask -TaskName $taskName -Description $taskDescription -Trigger $trigger -Action $action -RunLevel Highest -Force
        Write-Host "�w���\�]�w�C�P�@�W��9�I�۰ʧ�s (Weekly update scheduled successfully for every Monday at 9:00 AM)" -ForegroundColor Green
        Update-HostsAndServices
    } catch {
        Write-Host "�]�w�Ƶ{���ȥ���: $($_) (Failed to set up scheduled task: $($_))" -ForegroundColor Red
    }
} elseif ($choice -eq "3") {
    Block-AdobeFirewall -Delete
} else {
    Write-Host "�L�Ī���ܡA�}���N�h�X (Invalid choice, script will exit)" -ForegroundColor Red
}

# ��ܧ����T���M�@�̸�T
Write-Host "`n�Ҧ��ާ@�w�����I(All operations completed!)" -ForegroundColor Cyan
Write-Host "�z�i�H�b '�u�@�Ƶ{��' ���d�ݩέק���� 'WeeklyHostsUpdate' (You can view or modify the 'WeeklyHostsUpdate' task in Task Scheduler)" -ForegroundColor Yellow
$authorInfo = @"

====================================================
   Adobe Hosts Update, Service Removal, and Firewall Tool
   Author/�@��: blues32767
   Version/����: v3.20250420
   https://github.com/blues32767
   Firewall functionality adapted from: https://github.com/ph33nx
====================================================

"@
Write-Host $authorInfo -ForegroundColor Green
Pause
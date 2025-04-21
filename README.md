Adobe Hosts Update and Service Removal Tool
版本/Version: v3.20250420作者/Author: blues32767GitHub: https://github.com/blues32767
下載連結 / Download Link
下載最新版本 / Download the latest version:https://github.com/blues32767/Windows-Adobe-Hosts-Update-and-Service-Removal-Tool/releases/download/v3.20250420/Update-Hosts-adobe-hostsfromweb.zip
啟動方式 / How to Run
此腳本透過 .bat 檔案以管理員權限啟動 PowerShell 腳本。請按照以下步驟執行：This script uses a .bat file to launch the PowerShell script with administrator privileges. Follow these steps to run it:

下載並解壓縮 / Download and Extract

下載上述 ZIP 檔案並解壓縮至任意目錄。
Download the ZIP file above and extract it to any directory.


執行 BAT 檔案 / Run the BAT File

雙擊解壓縮後的 Update-Hosts-adobe.bat 檔案，系統將自動以管理員權限運行 Update-Hosts-adobe.ps1。
Double-click the extracted Update-Hosts-adobe.bat file, and the system will automatically run Update-Hosts-adobe.ps1 with administrator privileges.


確認執行 / Confirm Execution

若出現 UAC（使用者帳戶控制）提示，請點擊「是 (Yes)」以授予管理員權限。
If a UAC (User Account Control) prompt appears, click "Yes" to grant administrator privileges.




簡介 / Introduction
此 PowerShell 腳本旨在更新 Windows 的 hosts 檔案並清理 Adobe 相關的驗證服務與進程，以防止 Adobe Genuine Software Integrity Service (AGS) 等驗證機制干擾使用。它提供單次執行或每周自動更新的選項，並包含多項進階清理功能。
This PowerShell script is designed to update the Windows hosts file and remove Adobe-related validation services and processes, preventing interference from mechanisms like Adobe Genuine Software Integrity Service (AGS). It offers options for one-time execution or weekly scheduled updates, with advanced cleanup features.

功能 / Features

從網址更新 hosts 檔案 / Update hosts file from URL

從 https://a.dove.isdumb.one/list.txt 下載 hosts 內容並更新系統檔案，移除重複項目。
Downloads hosts content from https://a.dove.isdumb.one/list.txt and updates the system file, removing duplicates.
Update hosts source: https://github.com/ignaciocastro/a-dove-is-dumb


清理 Adobe 服務 / Clean Adobe Services

停用並刪除 AGSService 和 AAMUpdater 服務。
Disables and deletes AGSService and AAMUpdater services.


移除 Adobe 相關資料夾 / Remove Adobe Related Folders

刪除 C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient 和 C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\UWA。
Deletes C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient and C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\UWA.


清除 DNS 快取 / Clear DNS Cache

執行 ipconfig /flushdns 確保 hosts 變更立即生效。
Runs ipconfig /flushdns to ensure hosts changes take effect immediately.


檢查並刪除 Adobe 排程任務 / Check and Delete Adobe Scheduled Tasks

檢查並移除以下 Adobe 相關排程任務：Adobe Acrobat Update Task、Adobe-Genuine-Software-Integrity-Scheduler、AdobeGCInvoker-1 和 Adobe Creative Cloud。
Checks and removes the following Adobe-related scheduled tasks: Adobe Acrobat Update Task, Adobe-Genuine-Software-Integrity-Scheduler, AdobeGCInvoker-1, and Adobe Creative Cloud.


修改註冊表以禁用 AGS / Modify Registry to Disable AGS

在 HKLM:\SYSTEM\CurrentControlSet\Services\AGSService 中將 Start 值設為 4，禁用 AGS 服務啟動。
Sets the Start value to 4 in HKLM:\SYSTEM\CurrentControlSet\Services\AGSService to disable AGS service startup.


結束並移除 AdobeGCInvoker 進程 / Terminate and Remove AdobeGCInvoker Process

結束 AGCInvokerUtility 進程並移除相關排程任務。
Terminates the AGCInvokerUtility process and removes its related scheduled task.


禁用 Adobe Creative Cloud 背景進程 / Disable Adobe Creative Cloud Background Processes

結束 Creative Cloud、CCXProcess 和 CCLibrary 進程，並移除相關排程任務。
Terminates Creative Cloud, CCXProcess, and CCLibrary processes, and removes their related scheduled task.


更新模式選擇 / Update Mode Selection

使用者可選擇單次更新或設定每周一上午 9:00 自動更新（透過 Windows 工作排程器）。
Users can choose a one-time update or schedule a weekly update every Monday at 9:00 AM (via Windows Task Scheduler).


封鎖 Adobe 相關可執行文件的防火牆規則 / Block Adobe-related Executables in Firewall

為 Adobe 相關目錄（例如 C:\Program Files\Adobe 和 C:\Program Files (x86)\Adobe）中的可執行文件創建入站和出站防火牆規則，阻止其網路訪問。
Creates inbound and outbound firewall rules for executables in Adobe-related directories (e.g., C:\Program Files\Adobe and C:\Program Files (x86)\Adobe), blocking their network access.
支援刪除現有防火牆規則的選項。
Supports an option to delete existing firewall rules.
Firewall functionality adapted from: https://github.com/ph33nx




使用方法 / Usage
前置條件 / Prerequisites

作業系統 / Operating System: Windows 10 或更高版本 / Windows 10 or higher
權限 / Permissions: 必須以管理員身份運行 / Must run as administrator
PowerShell 版本 / PowerShell Version: 建議 5.1 或更高 / Recommended 5.1 or higher

詳細步驟 / Detailed Steps

下載並解壓縮 / Download and Extract

從上方提供的連結下載 ZIP 檔案並解壓縮。
Download the ZIP file from the link above and extract it.


執行腳本 / Run the Script

雙擊 Update-Hosts-adobe.bat，腳本將自動以管理員權限啟動。
Double-click Update-Hosts-adobe.bat, and the script will start with administrator privileges.


選擇模式 / Select Mode

輸入 1 進行單次更新（包括 hosts 更新、服務清理和防火牆封鎖），輸入 2 設定每周自動更新，或輸入 3 僅刪除防火牆規則。
Enter 1 for a one-time update (including hosts update, service cleanup, and firewall blocking), 2 to schedule a weekly update, or 3 to delete firewall rules only.


查看結果 / View Results

腳本將顯示每一步的執行狀態（成功、失敗或未找到）。
The script will display the status of each step (success, failure, or not found).




注意事項 / Notes

合法性 / Legality: 此腳本僅供學習和測試用途，修改 Adobe 驗證機制可能違反其使用條款，請自行承擔風險。
This script is for educational and testing purposes only. Modifying Adobe validation mechanisms may violate its terms of use; use at your own risk.


備份 / Backup: 腳本會自動備份原始 hosts 檔案至 hosts.bak，但建議手動備份重要資料。
The script automatically backs up the original hosts file to hosts.bak, but manual backup of important data is recommended.


錯誤排查 / Troubleshooting: 若腳本閃退，請檢查檔案編碼（建議 UTF-8 with BOM）或以命令列運行查看錯誤訊息：
If the script crashes, check the file encoding (recommended UTF-8 with BOM) or run it from the command line to view error messages:
powershell.exe -File "C:\path\to\Update-Hosts-adobe.ps1"




排程管理 / Schedule Management: 自動更新任務名為 WeeklyHostsUpdate，可在「工作排程器 (Task Scheduler)」中查看或修改。
The scheduled task is named WeeklyHostsUpdate and can be viewed or modified in Task Scheduler.




貢獻 / Contributing
歡迎提交問題或拉取請求以改進此腳本！Feel free to submit issues or pull requests to improve this script!

更新紀錄 / Change Log

2025-04-20:
新增功能: 添加封鎖 Adobe 相關可執行文件的防火牆功能，阻止其入站和出站網路訪問，支援刪除現有規則的選項（改進自 https://github.com/ph33nx）。
New Feature: Added firewall blocking for Adobe-related executables, preventing inbound and outbound network access, with an option to delete existing rules (adapted from https://github.com/ph33nx).
版本 / Version: v3.20250420




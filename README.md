# Windows Adobe Hosts 一鍵更新及服務移除工具

[![Windows Compatible](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows)

這個一鍵更新工具可以幫助您更新 Adobe 軟體的啟用和驗證伺服器，防止 Adobe 軟體連線到授權伺服器，同時移除相關的 Adobe 服務和資料夾。

## 功能說明 (Features)

1. **更新 Hosts 檔案** (Update Hosts File)
   - 自動備份原始 hosts 檔案
   - 將 Adobe 封鎖清單加入到 hosts 檔案中
   - 清除 DNS 快取以確保變更立即生效

2. **停用 Adobe 服務** (Disable Adobe Services)
   - 停用 AGSService 服務
   - 刪除 AGSService 服務
   - 刪除 AAMUpdater 服務

3. **移除 Adobe 相關資料夾** (Remove Adobe Related Folders)
   - 刪除 AdobeGCClient 資料夾 (C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient)
   - 刪除 UWA 資料夾 (C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\UWA)

## 使用方法 (How to Use)

1. **下載檔案** (Download Files)
   - Update-Hosts-adobe.ps1、hosts.txt 放在同一個資料夾

2. **執行腳本** (Run the Script)
   - 右鍵點擊 `Update-Hosts-adobe.ps1` 檔案
   - 選擇「用PowerShell執行」(Select "Run with PowerShell")
   - 如果出現安全性提示，請輸入Y(是) (If a security prompt appears, enter Y (Yes))

3. **完成後** (After Completion)
   - 腳本會自動備份您原有的 hosts 檔案
   - 將 Adobe 封鎖清單加入到 hosts 檔案中
   - 清除 DNS 快取以確保變更立即生效
   - 停用並刪除 Adobe 相關服務
   - 移除指定的 Adobe 資料夾
   - 顯示成功訊息

## 注意事項 (Important Notes)

- 執行前請確保您已關閉所有 Adobe 應用程式 (Make sure all Adobe applications are closed before running)
- 需要系統管理員權限才能修改 hosts 檔案和系統服務 (Administrator privileges are required to modify the hosts file and system services)
- 原始 hosts 檔案會被備份到 `C:\Windows\System32\drivers\etc\hosts.bak` (Your original hosts file will be backed up to `C:\Windows\System32\drivers\etc\hosts.bak`)
- 如果您需要恢復原始設定，只需將備份檔案重新命名為 hosts (To restore original settings, simply rename the backup file to hosts)
- 刪除的服務和資料夾無法自動恢復，請確保您真的需要移除這些項目 (Deleted services and folders cannot be automatically restored, please make sure you really need to remove these items)

## 系統要求 (System Requirements)

- Windows 7/8/10/11
- PowerShell 3.0 或更高版本
- 系統管理員權限

## 免責聲明 (Disclaimer)

此工具僅供教育和測試目的使用。使用者應遵守當地法律法規，並自行承擔使用此工具的風險和責任。作者不對因使用此工具而可能導致的任何損失或損害負責。

hosts.txt from
https://github.com/Ruddernation-Designs/Adobe-URL-Block-List/blob/master/hosts

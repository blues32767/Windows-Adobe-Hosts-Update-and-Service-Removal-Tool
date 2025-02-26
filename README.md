# Adobe 封鎖工具 (Adobe Blocker Tool)

[![Windows Compatible](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows)

這個一鍵更新hosts工具可以幫助您更新 Adobe 軟體的啟用和驗證伺服器，防止 Adobe 軟體連線到授權伺服器。


中文說明

## 使用方法

1. **下載檔案**
   -Update-Hosts-adobe.ps1、hosts.txt 放在同一個資料夾

2. **執行腳本**
   - 右鍵點擊 `Update-Hosts-adobe.ps1` 檔案
   - 選擇「用PowerShell執行」
   - 如果出現安全性提示，請輸入Y(是)

3. **完成後**
   - 腳本會自動備份您原有的 hosts 檔案
   - 將 Adobe 封鎖清單加入到 hosts 檔案中
   - 清除 DNS 快取以確保變更立即生效
   - 顯示成功訊息

## 注意事項

- 執行前請確保您已關閉所有 Adobe 應用程式
- 需要系統管理員權限才能修改 hosts 檔案
- 原始 hosts 檔案會被備份到 `C:\Windows\System32\drivers\etc\hosts.bak`
- 如果您需要恢復原始設定，只需將備份檔案重新命名為 hosts


English Instructions

## How to Use
# English Translation

1. **Download Files**
   - Place Update-Hosts-adobe.ps1 and hosts.txt in the same folder

2. **Run the Script**
   - Right-click on the `Update-Hosts-adobe.ps1` file
   - Select "Run with PowerShell"
   - If a security prompt appears, enter Y (Yes)


3. **After Completion**
   - The script will automatically back up your original hosts file
   - Add the Adobe blocking list to your hosts file
   - Clear DNS cache to ensure changes take effect immediately
   - Display success messages

## Important Notes

- Make sure all Adobe applications are closed before running
- Administrator privileges are required to modify the hosts file
- Your original hosts file will be backed up to `C:\Windows\System32\drivers\etc\hosts.bak`
- To restore original settings, simply rename the backup file to hosts

</details>

## 系統要求 (System Requirements)

- Windows 7/8/10/11
- PowerShell 3.0 或更高版本
- 系統管理員權限



## 免責聲明 (Disclaimer)

此工具僅供教育和測試目的使用。使用者應遵守當地法律法規，並自行承擔使用此工具的風險和責任。作者不對因使用此工具而可能導致的任何損失或損害負責。

hosts.txt from
https://github.com/Ruddernation-Designs/Adobe-URL-Block-List/blob/master/hosts


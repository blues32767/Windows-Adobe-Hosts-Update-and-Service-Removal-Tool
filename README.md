# Windows Adobe Hosts Update and Service Removal Tool
# Windows Adob​​e Hosts 更新與服務移除工具
*20250313 update hosts.txt  

[![Windows Compatible](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-3.0+-5391FE.svg)](https://microsoft.com/PowerShell)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Release](https://img.shields.io/github/v/release/blues32767/Update-Hosts-adobe-powershell)](https://github.com/blues32767/Update-Hosts-adobe-powershell/releases/latest)

<details>
<summary>English</summary>

## Quick Start Guide
0. First go to Windows applications and remove the Adobe genuine service software.  
1.Download Files :(https://github.com/blues32767/Windows-Adobe-Hosts-Update-and-Service-Removal-Tool/releases/download/v2.20250313v2/Update-Hosts-adobe-20250317.zip)
2. **Extract Files**: Extract all files from the downloaded ZIP to the same folder  
3. **Run the Script**: Right-click on `Run-Adobe-Hosts-Update.bat` and select "Run as administrator"  
4. **Confirm**: If prompted, enter Y to continue  

## Table of Contents
- [Features](#features)
- [Detailed Instructions](#how-to-use)
- [Important Notes](#important-notes)
- [System Requirements](#system-requirements)
- [Disclaimer](#disclaimer)

## Features

1. **Update Hosts File**
   - Automatically backs up the original hosts file
   - Adds Adobe blocking list to the hosts file
   - Clears DNS cache to ensure changes take effect immediately

2. **Disable Adobe Services**
   - Disables AGSService service
   - Removes AGSService service
   - Removes AAMUpdater service

3. **Remove Adobe Related Folders**
   - Deletes AdobeGCClient folder (C:\Program Files (x86)\Common Files\Adobe\AdobeGCClient)
   - Deletes UWA folder (C:\Program Files (x86)\Common Files\Adobe\OOBE\PDApp\UWA)

## How to Use

1. **Download Files**
   - [Download the latest release](https://github.com/blues32767/Windows-Adobe-Hosts-Update-and-Service-Removal-Tool/releases/download/v2.20250313v2/Update-Hosts-adobe-20250317.zip)  
   - Extract all files from the ZIP archive

2. **Run the Script**
   - Right-click on the `Run-Adobe-Hosts-Update.bat` file
   - Select "Run as administrator"
   - If a security prompt appears, enter Y (Yes)

3. **After Completion**
   - The script will automatically back up your original hosts file
   - Add the Adobe blocking list to your hosts file
   - Clear DNS cache to ensure changes take effect immediately
   - Disable and remove Adobe related services
   - Remove specified Adobe folders
   - Display success messages

## Important Notes

- Make sure all Adobe applications are closed before running
- Administrator privileges are required to modify the hosts file and system services
- Your original hosts file will be backed up to `C:\Windows\System32\drivers\etc\hosts.bak`
- To restore original settings, simply rename the backup file to hosts
- Deleted services and folders cannot be automatically restored, please make sure you really need to remove these items

## System Requirements

- Windows 7/8/10/11
- PowerShell 3.0 or higher
- Administrator privileges

## Disclaimer

This tool is for educational and testing purposes only. Users should comply with local laws and regulations and assume all risks and responsibilities associated with using this tool. The author is not responsible for any loss or damage that may result from using this tool.

---
2025/3/3 v2.20250303 Updated to address the issue in Windows 11 where the error message "Script execution is disabled on this system... Visit https:/go.microsoft.com/fwlink/?LinkID=135170..." appears. Now using cmd method to bypass PowerShell execution policy checks.

hosts.txt from
https://github.com/Ruddernation-Designs/Adobe-URL-Block-List/blob/master/hosts
https://github.com/wangzhenjjcn/AdobeGenp

</details>

<details open>
<summary>中文</summary>

## 快速開始指南
   0. 先去windows的應用程式，把Adobe genuine service(驗證程式)移除。  
   1. 下載 [Update-Hosts-adobe-20250317.zip ](https://github.com/blues32767/Windows-Adobe-Hosts-Update-and-Service-Removal-Tool/releases/download/v2.20250313v2/Update-Hosts-adobe-20250317.zip)  
   2. **解壓縮檔案**: 將下載的ZIP檔案中的所有檔案解壓縮到同一個資料夾  
   3. **執行腳本**: 右鍵點擊`Run-Adobe-Hosts-Update.bat`並選擇「以系統管理員身分執行」  
   4. **確認執行**: 如果出現提示，輸入 Y 繼續  
   *若還是會跳出，請移除全部的adobe軟體後，重開機，再重做一次"執行腳本"，再安裝adobe，再執行腳本。


## 目錄
- [功能說明](#功能說明-features)
- [詳細使用方法](#使用方法-how-to-use)
- [注意事項](#注意事項-important-notes)
- [系統要求](#系統要求-system-requirements)
- [免責聲明](#免責聲明-disclaimer)

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
   - [下載最新版本](https://github.com/blues32767/Windows-Adobe-Hosts-Update-and-Service-Removal-Tool/releases/download/v2.20250313v2/Update-Hosts-adobe-20250317.zip)  
   - 解壓縮ZIP檔案中的所有檔案

2. **執行腳本** (Run the Script)
   - 右鍵點擊 `Run-Adobe-Hosts-Update.bat` 檔案
   - 選擇「以系統管理員身分執行」
   - 如果出現安全性提示，請輸入Y(是)

3. **完成後** (After Completion)
   - 腳本會自動備份您原有的 hosts 檔案
   - 將 Adobe 封鎖清單加入到 hosts 檔案中
   - 清除 DNS 快取以確保變更立即生效
   - 停用並刪除 Adobe 相關服務
   - 移除指定的 Adobe 資料夾
   - 顯示成功訊息

## 注意事項 (Important Notes)

- 執行前請確保您已關閉所有 Adobe 應用程式
- 需要系統管理員權限才能修改 hosts 檔案和系統服務
- 原始 hosts 檔案會被備份到 `C:\Windows\System32\drivers\etc\hosts.bak`
- 如果您需要恢復原始設定，只需將備份檔案重新命名為 hosts
- 刪除的服務和資料夾無法自動恢復，請確保您真的需要移除這些項目

## 系統要求 (System Requirements)

- Windows 7/8/10/11
- PowerShell 3.0 或更高版本
- 系統管理員權限

## 免責聲明 (Disclaimer)

此工具僅供教育和測試目的使用。使用者應遵守當地法律法規，並自行承擔使用此工具的風險和責任。作者不對因使用此工具而可能導致的任何損失或損害負責。

</details>

---
2025/3/3 v2.20250303 更新以解決Windows 11中出現「因為這個系統上已停用指令碼執行，所以無法載入...網址為 https:/go.microsoft.com/fwlink/?LinkID=135170...」錯誤訊息的問題。現在使用cmd方法繞過PowerShell執行原則檢查。

hosts.txt from
https://github.com/ignaciocastro/a-dove-is-dumb
https://github.com/Ruddernation-Designs/Adobe-URL-Block-List/blob/master/hosts
https://github.com/wangzhenjjcn/AdobeGenp

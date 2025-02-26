# Windows Adobe Hosts Update and Service Removal Tool

[![Windows Compatible](https://img.shields.io/badge/Platform-Windows-blue.svg)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-3.0+-5391FE.svg)](https://microsoft.com/PowerShell)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<details>
<summary>English</summary>

## Quick Start Guide

1. **Download Files**: Place `Update-Hosts-adobe.ps1` and `hosts.txt` in the same folder
2. **Run the Script**: Right-click on the script file and select "Run with PowerShell"
3. **Confirm**: If prompted, enter Y to continue

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
   - Place Update-Hosts-adobe.ps1 and hosts.txt in the same folder

2. **Run the Script**
   - Right-click on the `Update-Hosts-adobe.ps1` file
   - Select "Run with PowerShell"
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

</details>

<details open>
<summary>中文</summary>

## 快速開始指南

1. **下載檔案**: 將 `Update-Hosts-adobe.ps1` 和 `hosts.txt` 放在同一個資料夾
2. **執行腳本**: 右鍵點擊腳本檔案並選擇「用PowerShell執行」
3. **確認執行**: 如果出現提示，輸入 Y 繼續

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
   - Update-Hosts-adobe.ps1、hosts.txt 放在同一個資料夾

2. **執行腳本** (Run the Script)
   - 右鍵點擊 `Update-Hosts-adobe.ps1` 檔案
   - 選擇「用PowerShell執行」
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

hosts.txt from
https://github.com/Ruddernation-Designs/Adobe-URL-Block-List/blob/master/hosts

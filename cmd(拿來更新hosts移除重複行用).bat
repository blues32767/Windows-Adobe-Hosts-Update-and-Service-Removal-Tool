@echo off
setlocal enabledelayedexpansion

echo 正在處理文件...
type hosts.txt | sort > sorted_hosts.txt
set "lastLine="
set "duplicateCount=0"
set "totalLines=0"

echo 正在移除重複行...
(for /f "usebackq delims=" %%a in ("sorted_hosts.txt") do (
    set "currentLine=%%a"
    set /a totalLines+=1
    if not "!currentLine!"=="!lastLine!" (
        echo %%a
    ) else (
        set /a duplicateCount+=1
    )
    set "lastLine=!currentLine!"
)) > unique_hosts.txt

echo 處理完成！
echo 原始行數: %totalLines%
echo 重複行數: %duplicateCount%
echo 唯一行數: %=totalLines-duplicateCount%
echo 結果已保存到 unique_hosts.txt

del sorted_hosts.txt
endlocal

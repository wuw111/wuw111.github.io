@echo off
setlocal enabledelayedexpansion
title DNS 快速配置工具 V11稳定版
chcp 936 >nul

:: 1. 管理员权限检查与引导
:checkAdmin
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :start
) else (
    echo 正在请求管理员权限...
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    exit /b
)

:start
cls
echo ======================================================
echo           DNS 快速配置工具 (Win7/10/11 通用)
echo ======================================================
echo.

:: 2. 获取并选择网卡
echo [当前可用的网卡列表]:
echo ------------------------------------------------------
set "idx=0"
for /f "tokens=*" %%a in ('powershell -Command "Get-WmiObject -Class Win32_NetworkAdapter | Where-Object { $_.NetConnectionStatus -eq 2 } | Select-Object -ExpandProperty NetConnectionID"') do (
    set /a idx+=1
    set "nic!idx!=%%a"
    echo  [!idx!] %%a
)

if %idx% == 0 (
    echo [错误] 未发现处于活动状态的网卡。
    pause
    exit
)

echo.
set /p choice=请输入目标网卡编号 (1-%idx%): 
if not defined nic%choice% (
    echo.
    echo [错误] 输入编号 "!choice!" 无效，请按任意键重新选择...
    pause >nul
    goto :start
)
for /f "delims=" %%n in ("!nic%choice%!") do set "targetNIC=%%n"
echo 已选择: !targetNIC!
echo.

:: 3. 设定 DNS 地址
:input1
set "dns1="
set /p dns1=请输入首选 DNS后回车 (输入 help 获取推荐，留空默认设置阿里DNS：223.5.5.5): 
if /i "%dns1%"=="help" (
    call :showHelp
    goto :input1
)
if "%dns1%"=="" (
    set "dns1=223.5.5.5"
) else (
    call :validateIP "%dns1%"
    if !errorLevel! neq 0 (
        echo [错误] IP 地址格式不规范。
        call :showHelp
        goto :input1
    )
)

:input2
set "dns2="
set /p dns2=请输入备用 DNS后回车 (输入 help 获取推荐，留空默认设置腾讯DNS：119.29.29.29): 
if /i "%dns2%"=="help" (
    call :showHelp
    goto :input2
)
if "%dns2%"=="" (
    set "dns2=119.29.29.29"
) else (
    call :validateIP "%dns2%"
    if !errorLevel! neq 0 (
        echo [错误] IP 地址格式不规范。
        call :showHelp
        goto :input2
    )
)

:: 4. 自动备份当前配置
echo.
echo [正在备份当前网络配置...]
set "backupDir=%~dp0DNSbackup"
if not exist "%backupDir%" mkdir "%backupDir%"

for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "dt=%%I"
set "timestamp=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%_%dt:~8,2%-%dt:~10,2%-%dt:~12,2%"
set "backupFile=%backupDir%\!targetNIC!_%timestamp%.txt"

powershell -Command "$nic = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.Description -eq (Get-WmiObject Win32_NetworkAdapter | Where-Object { $_.NetConnectionID -eq '!targetNIC!' }).Description }; echo '--- Network Backup Report ---' > '%backupFile%'; echo ('Backup Time: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) >> '%backupFile%'; echo ('Interface:   !targetNIC!') >> '%backupFile%'; echo '----------------------------' >> '%backupFile%'; echo ('IPv4 Address: ' + $nic.IPAddress[0]) >> '%backupFile%'; echo ('Subnet Mask:  ' + $nic.IPSubnet[0]) >> '%backupFile%'; echo ('Gateway:      ' + $nic.DefaultIPGateway[0]) >> '%backupFile%'; echo ('Old DNS 1:    ' + $nic.DNSServerSearchOrder[0]) >> '%backupFile%'; echo ('Old DNS 2:    ' + $nic.DNSServerSearchOrder[1]) >> '%backupFile%';" >nul 2>&1

echo 已保存备份: "%backupFile%"

:: 5. 应用 DNS 配置
echo.
echo [正在应用 DNS 配置...]
netsh interface ip set dns name="!targetNIC!" source=static addr=%dns1% register=primary >nul 2>&1

if !errorlevel! neq 0 (
    echo. & echo [严重错误] DNS 配置失败! & echo. & pause & exit
)

netsh interface ip add dns name="!targetNIC!" addr=%dns2% index=2 >nul 2>&1

echo [成功] DNS 设置已生效。
ipconfig /flushdns >nul
echo.

:: 6. 延迟检测与彩色评估
echo [正在测试 DNS 响应延迟...]
echo ------------------------------------------------------

set "color1=White" & set "eval1=无法访问" & set "ms1=超时"
set "color2=White" & set "eval2=无法访问" & set "ms2=超时"

for /f %%i in ('powershell -Command "$p = Test-Connection -ComputerName %dns1% -Count 2 -ErrorAction SilentlyContinue; if($p){ [int]($p | Measure-Object -Property ResponseTime -Average).Average }else{ 'Error' }"') do (
    if not "%%i"=="Error" (
        set "ms1=%%i" & set /a num=%%i
        if !num! lss 20 (set "eval1=极佳" & set "color1=Green") else if !num! lss 50 (set "eval1=良好" & set "color1=Green") else if !num! lss 100 (set "eval1=一般" & set "color1=Yellow") else (set "eval1=较差" & set "color1=Red")
    ) else (set "color1=Red")
)
for /f %%i in ('powershell -Command "$p = Test-Connection -ComputerName %dns2% -Count 2 -ErrorAction SilentlyContinue; if($p){ [int]($p | Measure-Object -Property ResponseTime -Average).Average }else{ 'Error' }"') do (
    if not "%%i"=="Error" (
        set "ms2=%%i" & set /a num=%%i
        if !num! lss 20 (set "eval2=极佳" & set "color2=Green") else if !num! lss 50 (set "eval2=良好" & set "color2=Green") else if !num! lss 100 (set "eval2=一般" & set "color2=Yellow") else (set "eval2=较差" & set "color2=Red")
    ) else (set "color2=Red")
)

powershell -Command "Write-Host ' 首选 DNS: %dns1%  延迟: %ms1%ms  评级: ' -NoNewline; Write-Host '%eval1%' -ForegroundColor %color1% ; Write-Host '' ; Write-Host ' 备用 DNS: %dns2%  延迟: %ms2%ms  评级: ' -NoNewline; Write-Host '%eval2%' -ForegroundColor %color2%"

echo ------------------------------------------------------
echo 配置任务已完成，请按任意键退出。
pause >nul
exit

:: --- 帮助信息子程序 ---
:showHelp
echo.
echo  --- 常见公共 DNS 服务器推荐 ---
echo.
echo   服务商              首选 DNS            备用 DNS
echo   ----------          ---------------     ---------------
echo   [国内推荐]
echo   腾讯DNS             119.29.29.29        182.254.116.116
echo   阿里DNS             223.5.5.5           223.6.6.6
echo   百度DNS             180.76.76.76        -
echo   火山DNS             180.184.1.1         180.184.2.2
echo   114DNS              114.114.114.114     114.114.115.115
echo   中科大DNS           202.38.64.1         202.112.20.131
echo.
echo   [国际通用]
echo   GoogleDNS           8.8.8.8             8.8.4.4
echo   Cloudflare          1.1.1.1             1.0.0.1
echo   Quad9DNS            9.9.9.9             149.112.112.112
echo   OpenDNS             208.67.222.222      208.67.220.220
echo   AdGuard             94.140.14.14        94.140.15.15
echo   Level3DNS           4.2.2.1             4.2.2.2
echo.
echo  请从上方选择一组并重新输入:
echo.
goto :eof

:: --- IP 格式校验子程序 ---
:validateIP
set "ip_to_test=%~1"
for /f "tokens=1-4 delims=." %%a in ("%ip_to_test%") do (
    if "%%a"=="" exit /b 1
    if "%%b"=="" exit /b 1
    if "%%c"=="" exit /b 1
    if "%%d"=="" exit /b 1
    for /f "tokens=5 delims=." %%e in ("%ip_to_test%") do exit /b 1
    for %%n in (%%a %%b %%c %%d) do (
        set "var=%%n"
        for /f "delims=0123456789" %%i in ("!var!") do exit /b 1
        if !var! gtr 255 exit /b 1
        if !var! lss 0 exit /b 1
    )
)
exit /b 0
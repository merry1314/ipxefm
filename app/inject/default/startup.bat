@echo off
set root=X:\windows\system32
if defined desktop (
    echo desktop ok!
) else (
set desktop=%USERPROFILE%\desktop
)
::补丁缺少的系统组件
if exist %root%\sysx64.exe start /w "" sysx64.exe
:::创建符号链接，避免32位程序运行不正常
mklink %temp%\cmd.exe x:\windows\system32\cmd.exe
%root%\pecmd.exe LINK %Desktop%\ghostx64,%root%\ghostx64.exe
%root%\pecmd.exe LINK %Desktop%\netcopy网络同传,%root%\netcopyx64.exe
%root%\pecmd.exe LINK %Desktop%\CGI一键还原,%root%\cgix64.exe
%root%\pecmd.exe LINK %Desktop%\ImDisk_Gui镜像挂载,%root%\ShowDrives_Gui_x64.exe
%root%\pecmd.exe LINK %Desktop%\DG分区工具3.5,%root%\DiskGeniusx64.exe
%root%\pecmd.exe LINK %Desktop%\文件共享盘,explorer.exe,B:\
%root%\pecmd.exe LINK %Desktop%\文件共享盘,"%programfiles%\explorer.exe", B:\
%root%\pecmd.exe LINK %Desktop%\Ghost自动网克,"%root%\startup.bat",netghost
%root%\pecmd.exe LINK %Desktop%\连接共享,"%root%\startup.bat",smbcli
%root%\pecmd.exe LINK %Desktop%\多播接收,"%root%\startup.bat",cloud
%root%\pecmd.exe LINK %Desktop%\多播发送,"%root%\uftp.exe",-R 800000

::获得执行的任务名称%job%
for /f "tokens=1-2 delims=@ " %%a in ('dir /b %root%\*@*') do (
set %%a
set %%b
)
if not "%1" == "" set job=%1
echo 服务器IP地址为  %ip%
echo 本次执行的任务  %job%
::动画化批处理
color b0 
set a=50
set b=34
:re
set /a a-=1
set /a b-=1
mode con: cols=%a% lines=%b% 
if %a% geq 16 if %b% geq 1 goto re
:::旧的查找ip方式
:::for /f "tokens=2 delims==" %%a in ('dir /b %root%\serverip*') do set ip=%%a
:判断ip值
if defined ip (
    goto runtask
) else (
%root%\pecmd.exe TEAM TEXT 提取服务器IP中，检测系统目录下有无ip.txt L300 T300 R768 B768 $30^|wait 5000 
if exist X:\windows\system32\ip.txt @echo 文件存在.准备提取...&&goto txtip
if not exist X:\windows\system32\ip.txt @echo 文件不存在.dhcp作为服务器地址...&&goto dhcpip
)

:::检测服务器文件并退出
:runtask
cd /d "%ProgramFiles(x86)%"
%root%\pecmd.exe TEAM TEXT 得到服务器IP为%ip% L300 T300 R768 B768 $30^|wait 2000 
echo 
cls
%root%\pecmd.exe TEAM TEXT 正在初始化网络.......L300 T300 R768 B768 $30^|wait 5000 
ipconfig /renew>nul
goto %job%
exit
::::从txt中提取服务器地址
:txtip
cd /d X:\windows\system32
for /f %%a in (ip.txt) do set ip=%%a
echo %ip%
%root%\pecmd.exe TEAM TEXT 初始化完成！准备执行相关任务…… L300 T300 R768 B768 $30^|wait 3000 
goto runtask
:::从dhcp中提取服务器地址
:dhcpip
for /f "tokens=1,2 delims=:" %%a in ('Ipconfig /all^|find /i "DHCP 服务器 . . . . . . . . . . . :"') do (
for /f "tokens=1,2 delims= " %%i in ('echo %%b')  do set ip=%%i
)
goto runtask
exit


::::::执行任务
:cloud
color 07
mode con: cols=40 lines=4 
%root%\pecmd.exe TEAM TEXT 正在准备多播接收端…… L300 T300 R768 B768 $30^|wait 2000 
%root%\pecmd.exe kill uftp.exe >nul
%root%\pecmd.exe kill uftpd.exe >nul
cd /d "X:\windows\system32" >nul
if exist I:\ (
echo 存在I盘,多播到I:\
start /min "多播到I:\" uftpd -B 2097152 -L %temp%\uftpd.log -D I:\
) else (
echo 不存在I盘,多播到X:\
start /min "多播到X:\" uftpd -B 2097152 -L %temp%\uftpd.log -D X:\
)
exit

::::::执行任务
:netghost
%root%\pecmd.exe TEAM TEXT 正在连接会话名称为mousedos的ghostsrv…… L300 T1 R1000 B768 $30^|wait 8000
%root%\pecmd.exe kill ghostx64.exe >nul
cd /d "X:\windows\system32" >nul
ghostx64.exe -ja=mousedos -batch >nul
if errorlevel 1 goto netghost
exit

::::::执行任务
:netcopy
%root%\pecmd.exe TEAM TEXT 正在准备netcopy网络同传,接收端可以取消后切换成发送模式…… L300 T300 R768 B768 $30^|wait 2000 
%root%\pecmd.exe kill netcopyx64.exe >nul
cd /d "X:\windows\system32" >nul
netcopyx64.exe
exit

::::::执行任务
:smbcli
net use * /delete /y >nul
%root%\pecmd.exe TEAM TEXT 正在连接共享\\%ip%\pxe为B盘.... L300 T1 R1000 B768 $30^|wait 8000
::echo 正在连接共享\\%ip%\pxe为B盘 
::echo 如果很久连不上，请确认主机%ip%开了名称为pxe的共享!，可关闭本窗口!
net use B: \\%ip%\pxe "" /user:guest
if "%errorlevel%"=="0" ( 
 %root%\pecmd.exe TEAM TEXT 连接服务器成功！准备进入桌面！L300 T1 R1000 B768 $30^|wait 2000
 exit
) else (
%root%\pecmd.exe TEAM TEXT 连接服务器超时！请确认主机的共享名为PXE或PE未加载网卡驱动! L300 T1 R1000 B768 $30^|wait 5000
goto runtask
)
exit


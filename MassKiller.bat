if not exist "%~0" echo rename file "%~0" without spaces! &goto :EOF
if not "%~1" == "DoIt!" echo line command must be '%0 DoIt!' && pause && goto :EOF

rem safety check. do not continue if the person just execute it. yeah....
rem must put "DoIt!" in the parameter to continue or erase here upwards to continue.
rem yeah , i consider some people retarded/dumb
rem ...
rem if i know someone like that? hell yeah i know. hes actually me. i am talking about myself

@echo off
@if defined SKIPAHEADDUNNOWHYLOL @if "%SKIPAHEADDUNNOWHYLOL%" == "YES" @goto :beginmadness >nul
set SKIPAHEADDUNNOWHYLOL=YES
start "Disabling everything" /WAIT /REALTIME /B %0 %*
goto :EOF && goto EOF
rem ####################################################################################################################################################################################################
rem ####################################################################################################################################################################################################
rem ####################################################################################################################################################################################################
rem ####################################################################################################################################################################################################
:UserPersonalizedCommands_Before




goto :EOF && goto EOF
rem ####################################################################################################################################################################################################
:UserPersonalizedCommands_After




goto :EOF && goto EOF
rem ####################################################################################################################################################################################################
rem ####################################################################################################################################################################################################
rem ####################################################################################################################################################################################################
rem ####################################################################################################################################################################################################
:beginmadness
setlocal

@(@set timestamp=%date:~0,4%%date:~5,2%%date:~8,2%%time:~0,2%%time:~3,2%%time:~6,2%&if /I %time:~0,2% LSS 10 @(@set timestamp=%date:~0,4%%date:~5,2%%date:~8,2%0%time:~1,1%%time:~3,2%%time:~6,2%))

CALL :UserPersonalizedCommands_Before

CALL :FirewallLockdown_A
CALL :ServiceDisable_A
CALL :TasksDisable_A
CALL :RemoveStartWithUser_A

CALL :UserPersonalizedCommands_After

endlocal
start "" /min /low /wait MassKill_Loops.bat

rem ####################################################################################################################################################################################################
goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF
rem ####################################################################################################################################################################################################
:ServiceDisable_A
rem for /f "tokens=2" %%a in ('sc queryex ^| findstr /c:SERVICE_NAME: ') do (sc config %%a start=disabled) && (echo SVC %%a>>MassKill.bkp)
for /f "delims=\ tokens=4*" %%a in ('reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services') do call :ServiceDisable_B "%%b"
goto :EOF

:ServiceDisable_B
for %%a in (Description DisplayName ErrorControl ImagePath Start Type ObjectName) do (
	set v_%%a=
	set v_%%aValue=
)

for /f "tokens=1-2*" %%a in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\%~1" /v *') do (
	set v_%%a=%%b
	set v_%%aValue=%%c
)

for %%a in (Description DisplayName ErrorControl ImagePath Start Type ObjectName) do if not defined v_%%a goto :EOF

if "%v_TypeValue%"=="0x01" goto :EOF
if "%v_TypeValue%"=="0x02" goto :EOF


echo SVC "%~1" "%v_StartValue%" "%v_TypeValue%" "%v_ImagePathValue%" >> MassKill_%timestamp%_SVC.bkp

rem @for %%a in ( Appinfo AudioEndpointBuilder Audiosrv BFE BITS BrokerInfrastructure Browser bthserv CoreMessagingRegistrar CryptSvc DcomLaunch DeveloperToolsService Dhcp DmEnrollmentSvc Dnscache DsmSvc EventLog ibtsiva LanmanServer LanmanWorkstation LicenseManager lmhosts LSM MpsSvc Netman netprofm NlaSvc nsi PlugPlay Power ProfSvc RpcEptMapper RpcLocator RpcSs SamSs Schedule SharedAccess StateRepository SystemEventsBroker wfcs tiledatamodelsvc TimeBrokerSvc UserManager Wcmsvc Winmgmt WlanSvc workfolderssvc WSearch wuauserv WlanSvc trustedinstaller ) do @if "%%a" == "%~1" @(@echo whitelisted "%%a" "%~1" && @goto :EOF)

sc config "%~1" start=demand && sc stop "%~1"
echo sc config "%~1" start=demand ^&^& sc stop "%~1" >> MassKill_Loops.bat

rem ####################################################################################################################################################################################################
goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF
rem ####################################################################################################################################################################################################
:TasksDisable_A
schtasks /Query /FO csv>> MassKill_%timestamp%_SCH.bkp
for /f "delims=," %%a in ('schtasks /Query /FO csv ^| findstr /v /c:"\"TaskName\",\"Next Run Time\",\"Status\"" ') do schtasks /End /TN %%a && schtasks /Change /Disable /TN %%a && echo schtasks /Change /Disable /TN %%a >> MassKill_Loops.bat

rem ####################################################################################################################################################################################################
goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF
rem ####################################################################################################################################################################################################
:FirewallLockdown_A
netsh advfirewall firewall delete rule all
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound
netsh advfirewall set allprofiles state on
for %%a in (in out) do (
    for %%b in (TCP UDP) do (
        netsh advfirewall firewall add rule name="DNS_%%a_%%b" dir=%%a action=allow protocol=%%b remoteport=53
        netsh advfirewall firewall add rule name="DNS_%%a_%%b" dir=%%a action=allow protocol=%%b localport=53
    )
    netsh advfirewall firewall add rule name="ICMP_%%a" dir=%%a action=allow protocol=ICMP
    netsh advfirewall firewall add rule name="ICMPv6_%%a" dir=%%a action=allow protocol=ICMPv6
    for %%b in ( 127.0.0.1/8 10.0.0.0/28 1.1.1.1/30 ) do (
		netsh advfirewall firewall add rule name="%%b_%%a" dir=%%a action=allow localip=%%b remoteip=%%b
	)
)

rem ####################################################################################################################################################################################################
goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF
rem ####################################################################################################################################################################################################
:RemoveStartWithUser_A
reg export HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run MassKill_%timestamp%_RUN_A.reg
reg delete HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\* /F /VA
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /VE

reg export HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run MassKill_%timestamp%_RUN_B.reg
reg delete HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run\* /F /VA
reg add HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run /VE

rem ####################################################################################################################################################################################################
goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF & goto :EOF
rem ####################################################################################################################################################################################################


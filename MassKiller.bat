if not exist %~0 echo rename file "%~0" without spaces! &goto :EOF
if not "%~1" == "DoIt!" echo line command must be '%~0 DoIt!' && pause && goto :EOF
CALL :ServiceDisable_A
CALL :TasksDisable_A
CALL :FirewallLockdown_A
goto :EOF

rem ####################################################################################################################################################################################################
:ServiceDisable_A
for /f "tokens=2" %%a in ('sc queryex ^| findstr /c:SERVICE_NAME: ') do (sc config %%a start=disabled) && (echo SVC %%a>>MassKill.bkp)

goto :EOF
:ServiceDisable_B
for /f "tokens=1,2" %a in ('reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\%~1') do set %a=%b
if not defined DisplayName

if "%Description%"==REG_SZ
if "%DisplayName%"==REG_SZ
if "%ErrorControl%"==REG_DWORD
if "%ImagePath%"==REG_EXPAND_SZ
if "%Start%"==REG_DWORD
if "%Type%"==REG_DWORD
if "%ObjectName%" ==REG_SZ

goto :EOF
rem ####################################################################################################################################################################################################
:TasksDisable_A
for /f "delims=," %%a in ('schtasks /Query /FO csv ^| findstr /v /c:"\"TaskName\",\"Next Run Time\",\"Status\"" ') do schtasks /Change /Disable /TN %%a && (echo TSK %%a>>MassKill.bkp)
goto :EOF
rem ####################################################################################################################################################################################################
:FirewallLockdown_A
rem netsh advfirewall firewall delete rule all
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound
netsh advfirewall set allprofiles state on
for %%a in (in out) do (
    for %%b in (TCP UDP) do (
        netsh advfirewall firewall add rule name="DNS_%%a_%%b" dir=%%a action=allow protocol=%%b remoteport=53
        netsh advfirewall firewall add rule name="DNS_%%a_%%b" dir=%%a action=allow protocol=%%b localport=53
    )
    netsh advfirewall firewall add rule name="10.8.0.25/28_%%a" dir=%%a action=allow localip=10.8.0.24/28 remoteip=10.8.0.25/28
)
for /f "tokens=1*" %%a in (%~0) do (
    if "%%a" == "SVC" sc config "%%b" start=auto & sc start "%%b"
    if "%%a" == "TSK" schtasks /Change /ENABLE /TN "%%b"
    if "%%a" == "FWP" echo start Allow Firewall %%b
)
goto :EOF
rem ####################################################################################################################################################################################################


#################################### Services
SVC Appinfo
SVC AudioEndpointBuilder
SVC Audiosrv
SVC BFE
SVC BITS
SVC BrokerInfrastructure
SVC Browser
SVC bthserv
SVC CoreMessagingRegistrar
SVC CryptSvc
SVC DcomLaunch
SVC DeveloperToolsService
SVC Dhcp
SVC DmEnrollmentSvc
SVC Dnscache
SVC DsmSvc
SVC EventLog
SVC ibtsiva
SVC LanmanServer
SVC LanmanWorkstation
SVC LicenseManager
SVC lmhosts
SVC LSM
SVC MpsSvc
SVC Netman
SVC netprofm
SVC NlaSvc
SVC nsi
SVC PlugPlay
SVC Power
SVC ProfSvc
SVC RpcEptMapper
SVC RpcLocator
SVC RpcSs
SVC SamSs
SVC Schedule
SVC SharedAccess
SVC StateRepository
SVC SystemEventsBroker
SVC tiledatamodelsvc
SVC TimeBrokerSvc
SVC UserManager
SVC Wcmsvc
SVC Winmgmt
SVC WlanSvc
SVC workfolderssvc
SVC WSearch
SVC wuauserv

#################################### Tasks
!TSK "Microsoft\Windows\Time Synchronization\SynchronizeTime"

#################################### FireWalls Program
!FWP name=B:\apps\firefox_x64\firefox.exe

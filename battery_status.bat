@ECHO OFF
cls

:: Localize variables
SETLOCAL

:start

:: Use WMI to get battery status information
:: FOR /F "tokens=1* delims==" %%A IN ('WMIC /NameSpace:"\\root\WMI" Path BatteryStatus              Get Charging^,Critical^,Discharging /Format:list ^| FIND "=TRUE"') DO ECHO Battery is %%A
FOR /F "tokens=*  delims="  %%A IN ('WMIC /NameSpace:"\\root\WMI" Path BatteryStatus              Get PowerOnline^,RemainingCapacity  /Format:list ^| FIND "="')     DO SET  Battery.%%A
FOR /F "tokens=*  delims="  %%A IN ('WMIC /NameSpace:"\\root\WMI" Path BatteryRuntime             Get EstimatedRuntime                /Format:list ^| FIND "="')     DO SET  Battery.%%A
FOR /F "tokens=*  delims="  %%A IN ('WMIC /NameSpace:"\\root\WMI" Path BatteryFullChargedCapacity Get FullChargedCapacity             /Format:list ^| FIND "="')     DO SET  Battery.%%A

:: Calculate runtime left and capacity
SET /A Battery.EstimatedRuntime  = ( %Battery.EstimatedRuntime% + 30 ) / 60
SET /A Battery.RemainingCapacity = ( %Battery.RemainingCapacity%00 + %Battery.FullChargedCapacity% / 2 ) / %Battery.FullChargedCapacity%

:: Display results
IF /I "%Battery.PowerOnline%"=="TRUE" (
	:: ECHO Now working on mains power
	ECHO %Battery.RemainingCapacity%%%
	IF %Battery.RemainingCapacity% GTR 99 (
	goto alarm
	)
	TIMEOUT /T 10 /NOBREAK
	goto start
) ELSE (
	:: ECHO Estimated remaining runtime %Battery.EstimatedRuntime% minutes
	ECHO %Battery.RemainingCapacity%%%
	TIMEOUT /T 10 /NOBREAK
	goto start
)
GOTO:EOF

:alarm











TIMEOUT /T 10 /NOBREAK
goto start

:: End localization
IF "%OS%"=="Windows_NT" ENDLOCAL

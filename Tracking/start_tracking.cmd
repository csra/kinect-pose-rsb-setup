@ECHO OFF
SETLOCAL

REM this script is used to start streaming the kinect tracking on a windows machine.


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM predefinitions:
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
SET me=%~n0
SET parent=%~dp0
REM get computer name:
FOR /F "usebackq" %%i IN (`hostname`) DO SET computer_name=%%i
REM set rsb scope of tracking data:
Set rsb_scope=/pointing/skeleton/%computer_name%

REM locations of required files:
SET logfile=%parent%log.txt

REM program calls
SET ks=KStudio.exe
SET rdsg_short=rsb-depth-sensors-grabber
SET rdsg=%rdsg_short%.exe
SET rdsg_full="%rdsg% -s ""-b kinectsdk2 -t Skeleton -s %rsb_scope%"""

REM Adding default program locations to the path:
SET PATH=%PATH%;"C:\Program Files\Microsoft SDKs\Kinect\v2.0_1409\Tools\KinectStudio\";"C:\Tracking\Binaries"


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM main function:
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM Continuous logfile vs. overwrite.
:: IF EXIST "%logfile%" DEL /Q %logfile% >NUL
CALL :log Script started

CALL :start_prog %ks%
CALL :start_prog %rdsg_full%
REM Wait for Kinect Studio to start.
@ping -n 3 localhost> nul
CALL :log Checking, if %rdsg% is running:
tasklist /FI "IMAGENAME eq %rdsg%" 2>NUL | find /I /N "%rdsg_short%">NUL
SET err=%ERRORLEVEL%
IF "%err%"=="0" (
  CALL :log - %rdsg% is still running
) ELSE ( 
  CALL :log - %rdsg% is not running anymore
)

CALL :log Script finished with exit code %err%
REM force execution to quit at the end of the "main" logic before running into the functions
EXIT /B %err%


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
REM functions:
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:start_prog
SET p=%~1
SET p=%p:""="%

CALL :log + starting %p%
REM possible alternative:
:: start cmd /c %p% ^> %2
start %p%

IF ERRORLEVEL 9009 (
  CALL :log - %p% not found. Make sure it is installed and its installation folder is registered in the PATH variable!
) ELSE IF %ERRORLEVEL% NEQ 0 (
  CALL :log - start %p% failed with error code %ERRORLEVEL%.
) ELSE (
  CALL :log - %p% started successfully
)
EXIT /B 0


:log
ECHO [%DATE% %TIME%] %* >> "%logfile%"
ECHO [%DATE% %TIME%] %*
EXIT /B 0
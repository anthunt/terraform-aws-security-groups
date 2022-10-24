@echo off
setlocal

If "%1" == "" Goto help
If "%2" == "" Goto help

Set PROFILE=%1
Set REGIONID=%2

:run
java -jar aws-sg-export-to-terraform-1.1.jar %PROFILE% %REGIONID%
exit /b

:help
echo.
echo Usage: ./export.cmd [AWS CLI Profile Name] [region id]
echo.
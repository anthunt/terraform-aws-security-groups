@echo off
setlocal

set MODULE_DIR=module
set MODULE_NAME=SecurityGroups
cd /d %~dp0%
cd ./%MODULE_DIR%

call :Echo.Color.Init
IF "%1" neq "" (
     SET PROFILE=%1
     GOTO SHOW_PROFILE
)
GOTO main

:Echo.Color %1=Color %2=Str [%3=/n]
setlocal enableDelayedExpansion
set "str=%~2"
:Echo.Color.2
:# Replace path separators in the string, so that the final path still refers to the current path.
set "str=a%ECHO.DEL%!str:\=a%ECHO.DEL%\..\%ECHO.DEL%%ECHO.DEL%%ECHO.DEL%!"
set "str=!str:/=a%ECHO.DEL%/..\%ECHO.DEL%%ECHO.DEL%%ECHO.DEL%!"
set "str=!str:"=\"!"
:# Go to the script directory and search for the trailing -
pushd "%ECHO.DIR%"
findstr /p /r /a:%~1 "^^-" "!str!\..\!ECHO.FILE!" nul
popd
:# Remove the name of this script from the output. (Dependant on its length.)
for /l %%n in (1,1,12) do if not "!ECHO.FILE:~%%n!"=="" <nul set /p "=%ECHO.DEL%"
:# Remove the other unwanted characters "\..\: -"
<nul set /p "=%ECHO.DEL%%ECHO.DEL%%ECHO.DEL%%ECHO.DEL%%ECHO.DEL%%ECHO.DEL%%ECHO.DEL%"
:# Append the optional CRLF
if not "%~3"=="" echo.
endlocal & goto :eof

:Echo.Color.Init
set "ECHO.COLOR=call :Echo.Color"
set "ECHO.DIR=%~dp0"
set "ECHO.FILE=%~nx0"
set "ECHO.FULL=%ECHO.DIR%%ECHO.FILE%"
:# Use prompt to store a backspace into a variable. (Actually backspace+space+backspace)
for /F "tokens=1 delims=#" %%a in ('"prompt #$H# & echo on & for %%b in (1) do rem"') do set "ECHO.DEL=%%a"
goto :eof

:main
echo.
call :Echo.Color 0f "--------------------------------------------------" /n
call :Echo.Color 0b " Managing module for AWS %MODULE_NAME%" /n
call :Echo.Color 0b " This is the Terraform execution command." /n
call :Echo.Color 0f "--------------------------------------------------" /n
call :Echo.Color 0a " Usage :" /n
call :Echo.Color 0f "    -Profile name:" /n
call :Echo.Color 0b "        Format: [Prefix]-[Name]" /n
call :Echo.Color 0b "        Using the profile name from the ~/.aws/credentails and ~/.aws/config" /n
echo.
call :Echo.Color 0f "    -Configuration file location:" /n
call :Echo.Color 0b "        It should be created in the "conf/[prefix]/" directory in the same location as run.cmd." /n
echo.
call :Echo.Color 0f "    -Configuration file name:" /n
call :Echo.Color 0b "        [Profile name].tfvars" /n
echo.
call :Echo.Color 0f "    -Option : " /n
call :Echo.Color 0b "        y/Y : terraform apply with terraform init" /n
call :Echo.Color 0b "        s/S : terraform apply without terraform init" /n
call :Echo.Color 0b "        i/I : continue with terraform init" /n
echo.
call :Echo.Color 0f "    -MFA : " /n
call :Echo.Color 0b "        no arguments then will show input prompt. " /n
call :Echo.Color 0b "        with arguments then have to input 3rd argument AWS CLI Profile Name. " /n
call :Echo.Color 0b "        it is not Profile Name (for tfvars). " /n
call :Echo.Color 0b "        if you want to use mfa then you have to set mfa_serial your AWS CLI Profile." /n
echo.
call :Echo.Color 0a " Run : " /n
call :Echo.Color 0f "    - Syntax : " /n
call :Echo.Color 0f "         ./run.cmd [Profile name] [s|y] [AWS CLI Profile Name]" /n
call :Echo.Color 0f "         ./run.cmd [Profile name] [i] [terraform resource key] [aws resource key]" /n
echo.
call :Echo.Color 0f "    - Example : " /n
call :Echo.Color 0b "         case1) ./run.cmd " /n
call :Echo.Color 0b "         case2) ./run.cmd gpt-qa" /n
call :Echo.Color 0b "         case3) ./run.cmd gpt-qa s" /n
call :Echo.Color 0b "         case4) ./run.cmd gpt-qa s GPORTAL-QA" /n
call :Echo.Color 0f "--------------------------------------------------" /n
echo.

:SET_PROFILE
    call :Echo.Color 0b "profile name must start with three digit alphabet(prefix) !" /n
    call :Echo.Color 0b "if you set profile name q or Q then will be exit." /n
    echo.
    call :Echo.Color 0a "Set profile name : "
    SET /P PROFILE=""
    echo.    
    IF "%PROFILE%" == "q" GOTO :eof
    IF "%PROFILE%" == "Q" GOTO :eof
    IF "%PROFILE%" == "" GOTO SET_PROFILE

:SHOW_PROFILE
SET STATE="../state/%PROFILE%.terraform.tfstate"
SET VAR_FILE="../conf/%PROFILE:~0,3%/%PROFILE%.tfvars"

call :Echo.Color 0f "Terraform will be executing with selected configuration." /n
call :Echo.Color 0a "STATE_FILE = "
call :Echo.Color 0b %STATE% /n
call :Echo.Color 0a "VAR_FILE = "
call :Echo.Color 0b %VAR_FILE% /n
echo.

IF "%2" neq "" (
     SET CHECK_PROC=%2
     GOTO CHECK_PROC
)

call :Echo.Color 0b "Y/y then continue with terraform init" /n
call :Echo.Color 0b "S/s then continue without terraform init" /n
call :Echo.Color 0b "I/i then execute terraform import" /n
call :Echo.Color 0b "others then cancel" /n
SET /P CHECK_PROC="Do you want to proceed with the entered content? "
echo.

:CHECK_PROC
IF "%CHECK_PROC%" == "Y" GOTO run-init
IF "%CHECK_PROC%" == "y" GOTO run-init
IF "%CHECK_PROC%" == "S" GOTO run
IF "%CHECK_PROC%" == "s" GOTO run
IF "%CHECK_PROC%" == "I" GOTO run-import
IF "%CHECK_PROC%" == "i" GOTO run-import
GOTO :eof

:run-init
call :Echo.Color 0a "run with terraform-init..."
terraform init

:run
IF "%3" neq "" (
     SET CHECK_AWS_PROFILE=%3
     GOTO get_session_token
)
IF "%2" neq "" GOTO run-apply

call :Echo.Color 0a "use mfa?(yes then use mfa) : "
SET /P CHECK_MFA=""
IF "%CHECK_MFA%" == "yes" GOTO mfa
GOTO run-apply

:mfa
echo.
call :Echo.Color 0b "if you set AWS CLI Profile Name q or Q then will be exit." /n
echo.
call :Echo.Color 0a "Set AWS CLI Profile Name : "
SET /P CHECK_AWS_PROFILE=""
echo.
IF "%CHECK_AWS_PROFILE%" == "q" GOTO :eof
IF "%CHECK_AWS_PROFILE%" == "Q" GOTO :eof
IF "%CHECK_AWS_PROFILE%" == "" GOTO mfa

:get_session_token
aws configure get source_profile --profile %CHECK_AWS_PROFILE% --output text > tmpsource.txt
FOR /f %%i in ( tmpsource.txt ) DO SET AWS_SOURCE_PROFILE=%%i
del tmpsource.txt
IF "%AWS_SOURCE_PROFILE%" == "" GOTO mfa-token

aws configure get role_arn --profile %CHECK_AWS_PROFILE% --output text > tmprole.txt
FOR /f %%i in ( tmprole.txt ) DO SET AWS_ROLE_ARN=%%i
del tmprole.txt

SET CHECK_AWS_PROFILE=%AWS_SOURCE_PROFILE%

:mfa-token
aws configure get mfa_serial --profile %CHECK_AWS_PROFILE% --output text > tmpmfa.txt
for /f %%i in ( tmpmfa.txt ) do set MFA_SERIAL=%%i
del tmpmfa.txt
IF "%MFA_SERIAL%" == "" GOTO :eof

call :Echo.Color 0a "Set MFA Code : "
SET /P CHECK_MFA_CODE=""
echo.
IF "%CHECK_MFA_CODE%" == "" GOTO mfa-token

IF "%AWS_ROLE_ARN%" == "" GOTO :session-token
:assume-role
echo. Get Assume Role Token for %CHECK_AWS_PROFILE%
aws sts assume-role --query Credentials.{AK:AccessKeyId,SK:SecretAccessKey,TK:SessionToken} --role-arn %AWS_ROLE_ARN% --role-session-name %CHECK_AWS_PROFILE% --serial-number %MFA_SERIAL% --token-code %CHECK_MFA_CODE% --profile %CHECK_AWS_PROFILE% --output text > tmpassume.txt
for /F "tokens=1,2,3" %%i in ( tmpassume.txt ) do (
    set TF_VAR_AWS_SESSION_ACCESSKEY=%%i
    set TF_VAR_AWS_SESSION_SECRETKEY=%%j
    set TF_VAR_AWS_SESSION_TOKEN=%%k
)
del tmpassume.txt
GOTO run-apply

:session-token
echo. Get Session Token for %CHECK_AWS_PROFILE%
aws sts get-session-token --query Credentials.{AK:AccessKeyId,SK:SecretAccessKey,TK:SessionToken} --serial-number %MFA_SERIAL% --token-code %CHECK_MFA_CODE% --profile %CHECK_AWS_PROFILE% --output text > tmptoken.txt
for /F "tokens=1,2,3" %%i in ( tmptoken.txt ) do (
    set TF_VAR_AWS_SESSION_ACCESSKEY=%%i
    set TF_VAR_AWS_SESSION_SECRETKEY=%%j
    set TF_VAR_AWS_SESSION_TOKEN=%%k
)
del tmptoken.txt

:run-apply
echo.
terraform apply -state=%STATE% -var-file=%VAR_FILE%

exit /b

:run-import

:SET_PARAM_OTHER
echo "%3=>"%3
echo "%4=>"%4
IF "%3" neq "" IF "%4" neq "" (
     SET IMPORT_ADDR=%3
     SET IMPORT_ID=%4
     GOTO run-import-cmd
)

:run-import-input
SET /P IMPORT_ADDR="Input import address : e.g) aws_vpc_endpoint.s3?"
SET /P IMPORT_ID="Input import id : e.g) vpce-091b9a1a0ca01e148?"
IF "%IMPORT_ADDR%%IMPORT_ID%" == "" GOTO run-import-input

:run-import-cmd
terraform import -state=%STATE% -var-file=%VAR_FILE% %IMPORT_ADDR% %IMPORT_ID%

exit /b

:# The following line must be last and not end by a CRLF.
-
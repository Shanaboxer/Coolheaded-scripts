@echo off
setlocal EnableDelayedExpansion
title Threshold - remove protection

net session >nul 2>&1
if %errorLevel% neq 0 (
  echo.
  echo   This needs to run as Administrator.
  echo   Right-click remove-threshold.bat and choose "Run as administrator".
  echo.
  pause
  exit /b 1
)

echo.
echo   THRESHOLD - REMOVING PROTECTION
echo   ==============================
echo.
echo   To remove Threshold you need the removal code.
echo.
echo   Get it by opening Threshold's settings in your browser, clicking
echo   "Start removal", and waiting out the cooling-off period. The code
echo   appears at the end of it.
echo.
echo   If you don't have a code yet, close this window and go and do that
echo   first. Cancelling costs nothing.
echo.

set /p CODE="   Removal code: "

for /f "delims=" %%A in ('powershell -NoProfile -Command "$now=(Get-Date).ToUniversalTime(); $ok=@(); foreach($h in 0,1){ $s=$now.AddHours(-$h).ToString('yyyyMMddHH'); $b=[Text.Encoding]::UTF8.GetBytes('threshold-removal-'+$s); $x=[Security.Cryptography.SHA256]::Create().ComputeHash($b); $ok += (($x[0..3] | ForEach-Object { $_.ToString('x2') }) -join '').ToUpper() }; if($ok -contains '%CODE%'.Trim().ToUpper()){'YES'}else{'NO'}"') do set VALID=%%A

if /i not "!VALID!"=="YES" (
  echo.
  echo   That code isn't right, or it has expired.
  echo   Codes last one hour. Open Threshold's settings and read the current one.
  echo.
  pause
  exit /b 1
)

echo.
echo   Code accepted. Removing policy...

set CHROME=HKLM\SOFTWARE\Policies\Google\Chrome
set EDGE=HKLM\SOFTWARE\Policies\Microsoft\Edge

reg delete "%CHROME%\URLBlocklist" /f >nul 2>&1
reg delete "%CHROME%\ExtensionInstallForcelist" /f >nul 2>&1
reg delete "%CHROME%\ExtensionSettings" /f >nul 2>&1
reg delete "%CHROME%" /v ForceGoogleSafeSearch /f >nul 2>&1
reg delete "%CHROME%" /v ForceYouTubeRestrict /f >nul 2>&1
reg delete "%CHROME%" /v IncognitoModeAvailability /f >nul 2>&1

reg delete "%EDGE%\URLBlocklist" /f >nul 2>&1
reg delete "%EDGE%\ExtensionInstallForcelist" /f >nul 2>&1
reg delete "%EDGE%\ExtensionSettings" /f >nul 2>&1
reg delete "%EDGE%" /v ForceGoogleSafeSearch /f >nul 2>&1
reg delete "%EDGE%" /v ForceYouTubeRestrict /f >nul 2>&1
reg delete "%EDGE%" /v ForceBingSafeSearch /f >nul 2>&1
reg delete "%EDGE%" /v InPrivateModeAvailability /f >nul 2>&1

set FIREFOX=HKLM\SOFTWARE\Policies\Mozilla\Firefox
reg delete "%FIREFOX%" /v DisablePrivateBrowsing /f >nul 2>&1
reg delete "%FIREFOX%" /v BlockAboutAddons /f >nul 2>&1
reg delete "%FIREFOX%" /v BlockAboutConfig /f >nul 2>&1

echo.
echo   Policy removed. Close Chrome completely and reopen it.
echo.
echo   The extensions page will work again, and you can remove the Threshold
echo   extension from there in the normal way.
echo.
echo   If you want it back later, run install-threshold.bat as Administrator.
echo.
pause

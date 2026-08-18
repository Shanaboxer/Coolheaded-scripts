@echo off
setlocal EnableDelayedExpansion
title Threshold - lock the browser

net session >nul 2>&1
if %errorLevel% neq 0 (
  echo.
  echo   This needs to run as Administrator.
  echo   Right-click install-threshold.bat and choose "Run as administrator".
  echo.
  pause
  exit /b 1
)

echo.
echo   THRESHOLD - LOCK THE BROWSER
echo   ============================
echo.
echo   This writes browser policy that:
echo.
echo     * Stops Threshold being removed or disabled - and ONLY Threshold.
echo       Your other extensions carry on working and stay manageable.
echo     * Forces Google SafeSearch on, browser-wide
echo     * Disables private browsing, which otherwise bypasses everything
echo     * Blocks about:config in Firefox
echo.
echo   None of it can be changed from inside the browser.
echo.

echo   Filter YouTube? Restricted Mode also disables YouTube comments.
echo   YouTube isn't a porn site, so most people leave this off.
set /p YT="   Turn on YouTube filtering? (y/N): "

echo.
set /p CONFIRM="   Continue? (y/n): "
if /i not "%CONFIRM%"=="y" (
  echo   Cancelled. Nothing was changed.
  pause
  exit /b 0
)

:: Threshold's Chrome Web Store extension ID. Permanent: assigned when the
:: listing was created, and unchanged by updates.
set EXTID=geciepejjdhbcafgbfkfnofjlcaholok

set CHROME=HKLM\SOFTWARE\Policies\Google\Chrome
set EDGE=HKLM\SOFTWARE\Policies\Microsoft\Edge
set FIREFOX=HKLM\SOFTWARE\Policies\Mozilla\Firefox

echo.
echo   Writing policy...

:: Lock Threshold only. Every other extension is untouched.
reg add "%CHROME%\ExtensionSettings\!EXTID!" /v installation_mode /t REG_SZ /d "force_installed" /f >nul
reg add "%CHROME%\ExtensionSettings\!EXTID!" /v update_url /t REG_SZ /d "https://clients2.google.com/service/update2/crx" /f >nul
reg add "%CHROME%\ExtensionSettings\!EXTID!" /v incognito_mode /t REG_SZ /d "enabled" /f >nul
reg add "%CHROME%\ExtensionSettings\!EXTID!" /v toolbar_pin /t REG_SZ /d "force_pinned" /f >nul

reg add "%EDGE%\ExtensionSettings\!EXTID!" /v installation_mode /t REG_SZ /d "force_installed" /f >nul
reg add "%EDGE%\ExtensionSettings\!EXTID!" /v update_url /t REG_SZ /d "https://clients2.google.com/service/update2/crx" /f >nul

:: Browser-level settings, below the extension
reg add "%CHROME%" /v ForceGoogleSafeSearch /t REG_DWORD /d 1 /f >nul
reg add "%CHROME%" /v IncognitoModeAvailability /t REG_DWORD /d 1 /f >nul
reg add "%EDGE%" /v ForceGoogleSafeSearch /t REG_DWORD /d 1 /f >nul
reg add "%EDGE%" /v ForceBingSafeSearch /t REG_DWORD /d 2 /f >nul
reg add "%EDGE%" /v InPrivateModeAvailability /t REG_DWORD /d 1 /f >nul

reg add "%FIREFOX%" /v DisablePrivateBrowsing /t REG_DWORD /d 1 /f >nul
reg add "%FIREFOX%" /v BlockAboutConfig /t REG_DWORD /d 1 /f >nul

if /i "%YT%"=="y" (
  reg add "%CHROME%" /v ForceYouTubeRestrict /t REG_DWORD /d 2 /f >nul
  reg add "%EDGE%" /v ForceYouTubeRestrict /t REG_DWORD /d 2 /f >nul
  echo   YouTube filtering ON - comments will be unavailable.
)

echo.
echo   Done. Close ALL browsers completely and reopen them.
echo.
echo   Check it worked:
echo     chrome://policy       the entries should be listed
echo     chrome://extensions   Threshold's Remove should be greyed out,
echo                           other extensions unaffected
echo     Right-click the Threshold icon - Remove should be unavailable
echo.
echo   Private browsing should be gone from the menu.
echo.
pause

@echo off
rem ============================================================
rem  MM YouTube Downloader - ONE-CLICK WEB SETUP (bootstrap)
rem  User downloads this tiny file and double-clicks it.
rem  Phase 1: downloads all components into a staging folder
rem  Phase 2: asks (Y/N) to install into the system
rem ============================================================
setlocal EnableExtensions EnableDelayedExpansion

for /f %%a in ('"prompt $E & for %%b in (1) do rem"') do set "ESC=%%a"
set "CY=%ESC%[96m" & set "GR=%ESC%[92m" & set "YE=%ESC%[93m"
set "RD=%ESC%[91m" & set "MG=%ESC%[95m" & set "DIM=%ESC%[90m"
set "BD=%ESC%[1m" & set "RS=%ESC%[0m"

title MM YouTube Downloader - Setup

rem --- where scripts live on GitHub (raw) ---
set "RAW=https://raw.githubusercontent.com/mahendra0905/mm-youtube-downloader/main"

rem --- download everything into a staging area first ---
set "STAGE=%TEMP%\MM-Setup-stage"
set "BIN=%STAGE%\bin"
if exist "%STAGE%" rmdir /S /Q "%STAGE%"
mkdir "%BIN%" 2>nul

cls
echo.
echo  %CY%  .---------------------------------------------.%RS%
echo  %CY%  ^|%RS%     %BD%%MG%M M   Y O U T U B E   D O W N L O A D E R%RS%   %CY%^|%RS%
echo  %CY%  ^|%RS%              %DIM%web setup  -  by Mahendra%RS%          %CY%^|%RS%
echo  %CY%  '---------------------------------------------'%RS%
echo.
echo    %DIM%This will download the downloader to your PC.%RS%
echo.

rem ============================================================
rem  1/4  yt-dlp engine (official release)
rem ============================================================
echo    %YE%[1/4]%RS% Getting the YouTube engine (yt-dlp) . . .
call :fetch "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" "%BIN%\yt-dlp.exe"
if not exist "%BIN%\yt-dlp.exe" goto dlfail

rem ============================================================
rem  2/4  the mm / mk commands (from GitHub)
rem ============================================================
echo    %YE%[2/4]%RS% Getting the commands (mm / mk) . . .
call :fetch "%RAW%/mm.cmd"         "%STAGE%\mm.cmd"
call :fetch "%RAW%/mk.cmd"         "%STAGE%\mk.cmd"
call :fetch "%RAW%/_download.cmd"  "%STAGE%\_download.cmd"
call :fetch "%RAW%/yt-dlp-update.bat" "%STAGE%\yt-dlp-update.bat"
if not exist "%STAGE%\mm.cmd" goto dlfail

rem ============================================================
rem  3/4  ffmpeg  (only if the PC doesn't already have it)
rem ============================================================
set "HAVEFF="
if exist "%BIN%\ffmpeg.exe" set "HAVEFF=1"
where ffmpeg >nul 2>&1 && set "HAVEFF=1"
if defined HAVEFF (
  echo    %YE%[3/4]%RS% ffmpeg already on this PC - skipping.
) else (
  echo    %YE%[3/4]%RS% Getting ffmpeg ^(~115 MB, one time^) . . .
  call :fetch "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip" "%STAGE%\ff.zip"
  if exist "%STAGE%\ff.zip" (
    powershell -NoProfile -Command "Expand-Archive -Force '%STAGE%\ff.zip' '%STAGE%\ff'" >nul 2>&1
    for /r "%STAGE%\ff" %%F in (ffmpeg.exe)  do copy /Y "%%F" "%BIN%\" >nul
    for /r "%STAGE%\ff" %%F in (ffprobe.exe) do copy /Y "%%F" "%BIN%\" >nul
    rmdir /S /Q "%STAGE%\ff" 2>nul & del /Q "%STAGE%\ff.zip" 2>nul
  )
)

rem ============================================================
rem  4/4  node (solves YouTube bot-check; only if missing)
rem ============================================================
set "HAVENODE="
if exist "%BIN%\node.exe" set "HAVENODE=1"
where node >nul 2>&1 && set "HAVENODE=1"
if defined HAVENODE (
  echo    %YE%[4/4]%RS% Node.js already on this PC - skipping.
) else (
  echo    %YE%[4/4]%RS% Getting Node.js ^(~80 MB, one time^) . . .
  call :fetch "https://nodejs.org/dist/v22.11.0/win-x64/node.exe" "%BIN%\node.exe"
)

echo.
echo  %GR%  Download complete.%RS%
echo.
echo  %CY%  -----------------------------------------------%RS%
echo.
echo    Install now so you can type %BD%mm%RS% / %BD%mk%RS% in ANY terminal?
echo    %DIM%(Installs to your account folder and adds it to PATH.%RS%
echo    %DIM% Choose N to just keep the files without installing.)%RS%
echo.

choice /C YN /N /M "   Install?  [Y/N]: "
if errorlevel 2 goto noinstall

rem ============================================================
rem  INSTALL
rem ============================================================
set "DEST=%LOCALAPPDATA%\MM-YouTube-Downloader"
echo.
echo    %YE%(*)%RS% Installing to %DEST% . . .
if not exist "%DEST%\bin" mkdir "%DEST%\bin"
xcopy "%BIN%" "%DEST%\bin\" /E /I /Y /Q >nul
copy /Y "%STAGE%\mm.cmd"            "%DEST%\" >nul
copy /Y "%STAGE%\mk.cmd"            "%DEST%\" >nul
copy /Y "%STAGE%\_download.cmd"     "%DEST%\" >nul
copy /Y "%STAGE%\yt-dlp-update.bat" "%DEST%\" >nul 2>&1

rem --- add to USER PATH if not already there ---
set "UP="
for /f "tokens=2,*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul ^| findstr /I "Path"') do set "UP=%%B"
echo !UP! | find /I "%DEST%" >nul
if errorlevel 1 (
  if defined UP ( setx PATH "!UP!;%DEST%" >nul ) else ( setx PATH "%DEST%" >nul )
)

rmdir /S /Q "%STAGE%" 2>nul

echo.
echo  %GR%  .---------------------------------------------.%RS%
echo  %GR%  ^|%RS%   %BD%%GR%INSTALLED!%RS%  Open a NEW terminal and use:       %GR%^|%RS%
echo  %GR%  '---------------------------------------------'%RS%
echo.
echo       %BD%mm%RS% "https://www.youtube.com/watch?v=XXXX"    %DIM%(video mp4)%RS%
echo       %BD%mk%RS% "https://www.youtube.com/watch?v=XXXX"    %DIM%(audio mp3)%RS%
echo.
echo    %DIM%Files save to your Downloads folder.%RS%
echo    %YE%IMPORTANT:%RS% close this window, open a NEW Command Prompt.
echo.
pause
exit /b 0

:noinstall
echo.
echo    %DIM%Skipped install. The files are here:%RS%
echo    %STAGE%
echo    %DIM%You can run mm.cmd / mk.cmd from that folder directly.%RS%
echo.
pause
exit /b 0

:dlfail
echo.
echo  %RD%  Download failed.%RS% Check your internet and run this setup again.
echo.
pause
exit /b 1

rem ------------------------------------------------------------
rem  :fetch  URL  OUTFILE   (quiet, reliable via PowerShell)
rem ------------------------------------------------------------
:fetch
powershell -NoProfile -Command "try { $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing '%~1' -OutFile '%~2' } catch { exit 1 }" >nul 2>&1
exit /b %errorlevel%

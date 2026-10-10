@echo off
rem ============================================================
rem  MM YouTube Downloader - core engine (do not run directly)
rem  Args:  %1 = URL   %2 = format string   %3 = container
rem ============================================================
setlocal EnableExtensions

rem --- grab the ESC char so we can print ANSI colors ---
for /f %%a in ('"prompt $E & for %%b in (1) do rem"') do set "ESC=%%a"
set "CY=%ESC%[96m"
set "GR=%ESC%[92m"
set "YE=%ESC%[93m"
set "RD=%ESC%[91m"
set "MG=%ESC%[95m"
set "DIM=%ESC%[90m"
set "BD=%ESC%[1m"
set "RS=%ESC%[0m"

set "HERE=%~dp0"
set "URL=%~1"
set "FMT=%~2"
set "CONT=%~3"

rem --- auto-strip chat-app junk if pasted (@url: prefix and backticks) ---
set "URL=%URL:`=%"
set "URL=%URL:@url:=%"

if "%URL%"=="" (
  echo.
  echo   Usage:  mm "https://www.youtube.com/watch?v=XXXX"
  echo           mk "https://www.youtube.com/watch?v=XXXX"
  echo.
  echo   ^(Put the URL in double quotes.^)
  echo.
  exit /b 1
)

set "YTDLP=%HERE%bin\yt-dlp.exe"
set "OUT=%USERPROFILE%\Downloads\%%(title)s.%%(ext)s"

rem --- detect ffmpeg: bundled wins, else rely on system PATH ---
set "FFARG="
if exist "%HERE%bin\ffmpeg.exe" set "FFARG=--ffmpeg-location "%HERE%bin""

rem --- detect node (JS bot-check solver): bundled wins, else system PATH ---
set "JSARG=--js-runtimes node"
if exist "%HERE%bin\node.exe" set "JSARG=--js-runtimes "node:%HERE%bin\node.exe""

rem --- custom one-line animated progress bar for yt-dlp ---
set "PBAR=  %GR%%%(progress._percent_str)s%RS%  %DIM%of%RS% %%(progress._total_bytes_str)s   %CY%%%(progress._speed_str)s%RS%   %DIM%ETA%RS% %YE%%%(progress._eta_str)s%RS%        "

cls
echo.
echo  %CY%  .-----------------------------------------.%RS%
echo  %CY%  ^|%RS%     %BD%%MG%M M   Y O U T U B E%RS%  %DIM%downloader%RS%      %CY%^|%RS%
echo  %CY%  '-----------------------------------------'%RS%
echo.
echo    %DIM%save to :%RS%  %USERPROFILE%\Downloads
echo    %DIM%link    :%RS%  %URL%
echo.
echo    %YE%(*)%RS% connecting to YouTube . . .

rem --- Attempt 1: no browser cookies (fastest) ---
call :run "" && goto ok

echo    %DIM%(~) retrying with your Firefox login . . .%RS%
call :run "--cookies-from-browser firefox" && goto ok

echo    %DIM%(~) retrying with your Chrome login . . .%RS%
call :run "--cookies-from-browser chrome" && goto ok

echo    %DIM%(~) retrying with your Edge login . . .%RS%
call :run "--cookies-from-browser edge" && goto ok

echo.
echo  %RD%  .-----------------------------------------.%RS%
echo  %RD%  ^|%RS%   %BD%%RD%X  DOWNLOAD FAILED%RS%                     %RD%^|%RS%
echo  %RD%  '-----------------------------------------'%RS%
echo.
echo    %DIM%try this:%RS%
echo      1^) check your internet connection
echo      2^) sign in to YouTube in Firefox/Chrome/Edge, then retry
echo      3^) run  yt-dlp-update.bat  to update the engine
echo.
exit /b 1

:ok
echo.
echo  %GR%  .-----------------------------------------.%RS%
echo  %GR%  ^|%RS%   %BD%%GR%[ DONE ]%RS%  saved to your Downloads folder  %GR%^|%RS%
echo  %GR%  '-----------------------------------------'%RS%
echo.
exit /b 0

:run
"%YTDLP%" %~1 %FFARG% --remote-components ejs:github %JSARG% -f "%FMT%" --merge-output-format %CONT% --no-mtime --no-warnings --quiet --progress --progress-template "download:%PBAR%" -o "%OUT%" "%URL%" 2>nul
exit /b %errorlevel%

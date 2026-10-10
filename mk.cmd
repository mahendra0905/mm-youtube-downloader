@echo off
rem mk = download AUDIO only as MP3 (music / podcast)
setlocal EnableExtensions

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
if "%URL%"=="" (
  echo.
  echo   Usage:  mk "https://www.youtube.com/watch?v=XXXX"
  echo   ^(downloads audio only as MP3^)
  echo.
  exit /b 1
)
rem --- auto-strip chat-app junk if pasted (@url: prefix and backticks) ---
set "URL=%URL:`=%"
set "URL=%URL:@url:=%"

set "YTDLP=%HERE%bin\yt-dlp.exe"
set "OUT=%USERPROFILE%\Downloads\%%(title)s.%%(ext)s"

set "FFARG="
if exist "%HERE%bin\ffmpeg.exe" set "FFARG=--ffmpeg-location "%HERE%bin""

set "JSARG=--js-runtimes node"
if exist "%HERE%bin\node.exe" set "JSARG=--js-runtimes "node:%HERE%bin\node.exe""

set "PBAR=  %GR%%%(progress._percent_str)s%RS%  %DIM%of%RS% %%(progress._total_bytes_str)s   %CY%%%(progress._speed_str)s%RS%   %DIM%ETA%RS% %YE%%%(progress._eta_str)s%RS%        "

cls
echo.
echo  %MG%  .-----------------------------------------.%RS%
echo  %MG%  ^|%RS%     %BD%%CY%M M   A U D I O%RS%  %DIM%mp3 downloader%RS%     %MG%^|%RS%
echo  %MG%  '-----------------------------------------'%RS%
echo.
echo    %DIM%save to :%RS%  %USERPROFILE%\Downloads
echo    %DIM%link    :%RS%  %URL%
echo.
echo    %YE%(*)%RS% connecting to YouTube . . .

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
echo    %DIM%check internet, or sign in to YouTube in your browser and retry.%RS%
echo.
exit /b 1

:ok
echo.
echo  %GR%  .-----------------------------------------.%RS%
echo  %GR%  ^|%RS%   %BD%%GR%[ DONE ]%RS%  mp3 saved to your Downloads     %GR%^|%RS%
echo  %GR%  '-----------------------------------------'%RS%
echo.
exit /b 0

:run
"%YTDLP%" %~1 %FFARG% --remote-components ejs:github %JSARG% -x --audio-format mp3 --audio-quality 0 --no-mtime --no-warnings --quiet --progress --progress-template "download:%PBAR%" -o "%OUT%" "%URL%" 2>nul
exit /b %errorlevel%

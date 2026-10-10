@echo off
rem Updates yt-dlp to the newest version (run if downloads start failing)
setlocal
set "HERE=%~dp0"
echo Updating yt-dlp...
"%HERE%bin\yt-dlp.exe" -U
echo Done.
pause

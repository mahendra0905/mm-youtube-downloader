# ============================================================
#  MM YouTube Downloader - one-liner web setup (PowerShell)
#  Run with:  irm https://mahendra0905.github.io/mm-youtube-downloader/go | iex
# ============================================================
$ErrorActionPreference = 'Stop'
$RAW  = 'https://raw.githubusercontent.com/mahendra0905/mm-youtube-downloader/main'
$stage = Join-Path $env:TEMP 'MM-Setup-stage'
$bin   = Join-Path $stage 'bin'
if (Test-Path $stage) { Remove-Item $stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $bin | Out-Null

function Say($c,$t){ Write-Host $t -ForegroundColor $c }
function Grab($url,$out){ $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing $url -OutFile $out }

Clear-Host
Say Cyan    "  .---------------------------------------------."
Say Magenta "       M M   Y O U T U B E   D O W N L O A D E R"
Say DarkGray "               web setup  -  by Mahendra"
Say Cyan    "  '---------------------------------------------'"
Write-Host ""
Say Yellow  "  [1/4] YouTube engine (yt-dlp) ..."
Grab "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe" "$bin\yt-dlp.exe"

Say Yellow  "  [2/4] commands (mm / mk) ..."
foreach($f in 'mm.cmd','mk.cmd','_download.cmd','yt-dlp-update.bat'){ Grab "$RAW/$f" "$stage\$f" }

if (Get-Command ffmpeg -ErrorAction SilentlyContinue) {
  Say Yellow "  [3/4] ffmpeg already present - skipping."
} else {
  Say Yellow "  [3/4] ffmpeg (~115 MB, one time) ..."
  Grab "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip" "$stage\ff.zip"
  Expand-Archive -Force "$stage\ff.zip" "$stage\ff"
  Get-ChildItem "$stage\ff" -Recurse -Include ffmpeg.exe,ffprobe.exe | % { Copy-Item $_.FullName $bin -Force }
  Remove-Item "$stage\ff","$stage\ff.zip" -Recurse -Force
}

if (Get-Command node -ErrorAction SilentlyContinue) {
  Say Yellow "  [4/4] Node.js already present - skipping."
} else {
  Say Yellow "  [4/4] Node.js (~80 MB, one time) ..."
  Grab "https://nodejs.org/dist/v22.11.0/win-x64/node.exe" "$bin\node.exe"
}

Write-Host ""
Say Green "  Download complete."
Write-Host ""
$ans = Read-Host "  Install now so 'mm' / 'mk' work in any terminal?  [Y/N]"
if ($ans -notmatch '^[Yy]') {
  Say DarkGray "  Skipped. Files are at: $stage"
  return
}

$dest = Join-Path $env:LOCALAPPDATA 'MM-YouTube-Downloader'
New-Item -ItemType Directory -Force -Path (Join-Path $dest 'bin') | Out-Null
Copy-Item "$bin\*" (Join-Path $dest 'bin') -Recurse -Force
foreach($f in 'mm.cmd','mk.cmd','_download.cmd','yt-dlp-update.bat'){ Copy-Item "$stage\$f" $dest -Force }

$up = [Environment]::GetEnvironmentVariable('Path','User')
if ($up -notlike "*$dest*") {
  $new = if ($up) { "$up;$dest" } else { $dest }
  [Environment]::SetEnvironmentVariable('Path',$new,'User')
}
Remove-Item $stage -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Say Green  "  .---------------------------------------------."
Say Green  "     INSTALLED!  Open a NEW terminal and use:"
Say Green  "  '---------------------------------------------'"
Write-Host '       mm "https://www.youtube.com/watch?v=XXXX"   (video)'
Write-Host '       mk "https://www.youtube.com/watch?v=XXXX"   (audio mp3)'
Write-Host ""
Say Yellow "  IMPORTANT: close this window, open a NEW terminal."
Write-Host ""

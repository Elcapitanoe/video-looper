@echo off
title VIDEO LOOPER (R1-20250804)
setlocal enabledelayedexpansion

:: ===== Configuration =====
set "WATERMARK=YOUTUBE @BDI_YT"
set "DURATION=3600"

:: ===== Prepare folders =====
if not exist "original"  mkdir "original"
if not exist "modified"  mkdir "modified"

:MENU
cls
echo  ==================================================
echo  Creator  : Domi Adiwijaya
echo  Github   : https://github.com/Elcapitanoe
echo  Revision : R1 (20250804)
echo  ==================================================
echo(
echo  Main Menu
echo  [1] Change Watermark   (current: !WATERMARK:\=:!)
echo  [2] Change Duration    (current: !DURATION!s)
echo  [3] Start Processing
echo  [0] Exit
echo(
set /p choice="Select an option : "

if /i "%choice%"=="0" exit
if "%choice%"=="1" goto SET_WM
if "%choice%"=="2" goto SET_DUR
if "%choice%"=="3" goto PROCESS
goto MENU

:SET_WM
echo(
set /p WATERMARK=New watermark text: 
set "WATERMARK=!WATERMARK::=\:!"
goto MENU

:SET_DUR
echo(
set /p DURATION=New duration (seconds): 
goto MENU

:PROCESS
cls
echo  Select output resolution:
echo  [1] 144p   (256x144)
echo  [2] 240p   (426x240)
echo  [3] 360p   (640x360)
echo  [4] 480p   (854x480)
echo  [5] 720p   (1280x720)
echo  [6] 1080p  (1920x1080)
echo  [7] 1440p  (2560x1440)
echo  [0] Back to Menu
echo(
set /p r="Select Resolution : "

if "%r%"=="0" goto MENU
if "%r%"=="1" set "W=256"   & set "H=144"   & set "R=144p"
if "%r%"=="2" set "W=426"   & set "H=240"   & set "R=240p"
if "%r%"=="3" set "W=640"   & set "H=360"   & set "R=360p"
if "%r%"=="4" set "W=854"   & set "H=480"   & set "R=480p"
if "%r%"=="5" set "W=1280"  & set "H=720"   & set "R=720p"
if "%r%"=="6" set "W=1920"  & set "H=1080"  & set "R=1080p"
if "%r%"=="7" set "W=2560"  & set "H=1440"  & set "R=1440p"
if not defined W goto MENU

for %%F in ("original\*.mp4") do (
    for /f %%A in ('powershell -Command "Get-Date -Format yyyyMMdd-HHmmss"') do set "NOW=%%A"
    set /a FS=H * 5 / 100
    set "OUT=modified\%%~nF-!DURATION!s-!NOW!-!R!.mp4"
     
    cls
    echo(
    echo  ---------------------------------------------------
    echo(
    echo  Processing the file...
    echo(
    echo  ---------------------------------------------------

    ffmpeg -hide_banner -loglevel error -stream_loop -1 -i "%%F" -t !DURATION! ^
        -vf "scale=!W!:!H!:flags=lanczos,drawtext=fontfile='C\:/Windows/Fonts/arial.ttf':text='!WATERMARK!':fontcolor=white:alpha=0.3:fontsize=!FS!:x=(w-text_w)/2:y=(h-text_h)/2" ^
        -c:v libx264 -crf 22 -preset slow -c:a copy "!OUT!"

:: Calculate File Size
set "FILE_PATH=%CD%\!OUT!"
set "SIZE_B=0"
set "SIZE_MB=0"

    if exist "!FILE_PATH!" (
        for %%S in ("!FILE_PATH!") do (
            set /a SIZE_B=%%~zS
        )

        if !SIZE_B! LSS 1048576 (
            set /a SIZE_KB=!SIZE_B! / 1024
            set "FILE_SIZE=!SIZE_KB! KB (!SIZE_B! byte)"
        ) else (
            set /a SIZE_MB=!SIZE_B! / 1048576
            set "FILE_SIZE=!SIZE_MB! MB (!SIZE_B! byte)"
        )
    ) else (
        set "FILE_SIZE=Unknown (file not found)"
    )

    
    cls
    echo(
    echo  ---------------------------------------------------
    echo(
    echo  Processing complete...
    echo(
    echo  Video Length : !DURATION!s
    echo  Watermark    : !WATERMARK!
    echo  File Size    : !FILE_SIZE!
    echo  Location     : %CD%\!OUT!
    echo(
    echo  ---------------------------------------------------
    echo(
)

pause
goto MENU

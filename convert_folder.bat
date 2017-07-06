@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set srcdir=%~1\
set destdir=%~dp1%~nx1_converted\

echo %srcdir%
echo %destdir%
set /p ok="Is this OK? (Y/N)"
if /i !ok!==n exit

set /p del="Delete copied .dds files after conversion? (Y/N)"

set /p rec="Perform the conversion recursively? (Y/N)"

set dorec=false
if /i !rec!==y set dorec=true

rem copy the dds files with the folder structure
if !dorec!==true xcopy "%srcdir%*.dds" "%destdir%" /c /s /r /d /y /i /q

rem copy the dds files only one folder deep
if !dorec!==false xcopy "%srcdir%*.dds" "%destdir%" /c /r /d /y /i /q

rem flush log
break > %~dp0\conversion_log.txt

rem convert the dds files to tga
for /r %destdir% %%i in (*.dds) do (
	set file=%%~ni
	echo [!TIME!] Converting: !file!
	%~dp0\readdxt.exe "%%i"
	echo [!TIME!] Converted: %%i >> %~dp0\conversion_log.txt
)

for /r %destdir% %%i in (*.tga) do (

    set path=%%~dpi
    set tmp=%%~nxi
    set nn=%%~ni
	rem delete unwanted tga files (*01.tga, *02.tga...)
    if not !tmp:~-6!==00.tga (
		del %%i
		echo [!TIME!] Deleted: !tmp! >> %~dp0\conversion_log.txt
	)
    if !tmp:~-6!==00.tga (
		rem rename converted tga to match the dds (remove 00 postfix)
		ren !path!!nn!.tga !nn:~0,-2!.tga
		rem remove copied dds file
		if !del!==y del !path!!nn:~0,-2!.dds
		if !del!==Y del !path!!nn:~0,-2!.dds

		echo [!TIME!] Clean up: !nn:~0,-2!.tga
		echo [!TIME!] Clean up: !path!!nn:~0,-2!.tga >> %~dp0\conversion_log.txt
    )

)

echo [!TIME!] Conversion process READY >> %~dp0\conversion_log.txt
echo [!TIME!] Conversion process READY

pause
exit

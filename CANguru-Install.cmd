@echo off
set COMPORT=COM3
set source=..\0103-Gleisbesetztmelder\.pio\build\nodemcu-32s\
set dest=CANguru-Files
set upload=Prepare-Upload
set ota=Prepare-OTA

:loop
cls
echo.
echo CARguru - Helper fuer Gleisbesetztmelder
echo.
echo USB-Anschluesse:
call files
echo.
echo Bitte waehlen Sie eine der folgenden Optionen:
echo. 
echo  1 - COM-Port festlegen
echo  2 - Flash-Speicher loeschen
echo  3 - OTA-Upload vorbereiten auf %COMPORT%
echo  4 - Upload CANguru-Decoder (aus Ordner CANguru-Files) ueber %COMPORT%
echo  5 - Putty starten
echo. 
echo  x - Beenden
echo.
set /p SELECTED=Ihre Auswahl: 

if "%SELECTED%" == "x" goto :eof
if "%SELECTED%" == "1" goto :SetComPort
if "%SELECTED%" == "2" goto :ERASE_FLASH
if "%SELECTED%" == "3" goto :FOR_OTA
if "%SELECTED%" == "4" goto :UPLOAD_FIRMWARE
if "%SELECTED%" == "5" goto :Putty

goto :errorInput 

:SetComPort
REM @echo OFF
REM FOR /L %%x IN (1, 1, 29) DO ECHO %%x - Setze COM-Port %%x
echo Bitte geben Sie die Nummer des COM-Anschlusses ein (z.B. 5 fuer COM5) oder x fuer Exit
echo.
set /p SELECTED=Ihre Auswahl: 

if "%SELECTED%" == "x" goto :loop

set COMPORT=COM%SELECTED%
goto :loop

:ERASE_FLASH
@echo on
esptool.exe --chip esp32 --port %COMPORT% erase_flash
@echo off
echo.
pause
goto :loop

:FOR_OTA
@echo off
echo. 
echo Weist dem Decoder eine IP-Adresse zu; anschliessend sollte diese Adresse im Browser aufgerufen werden;
echo dann kann von dort eine Software (firmware.bin) ausgewaehlt und auf den Decoder geladen werden
esptool.exe --chip esp32 --port %COMPORT% --baud 460800 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 80m --flash_size 4MB 0x1000 %ota%/bootloader.bin 0x8000 %ota%/partitions.bin 0xe000 %ota%/boot_app0.bin 0x10000 %ota%/firmware.bin
Putty\putty.exe -serial %COMPORT% -sercfg 115200,8,n,1,N
@echo off
echo.
pause
goto :loop

:UPLOAD_FIRMWARE
@echo off
echo.
echo Geht davon aus, dass die aktuelle Decoder-Software im Verzeichnis CANguru-Files steht; weist dem Decoder eine IP-Adresse zu;
echo laedt anschliessend diese Software (firmware.bin) auf den Decoder hoch
echo.
copy %source%*.bin %dest%
esptool.exe --chip esp32 --port %COMPORT% --baud 460800 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 80m --flash_size 4MB 0x1000 %upload%/bootloader.bin 0x8000 %upload%/partitions.bin 0x10000 %upload%/firmware.bin
Putty\putty.exe -serial %COMPORT% -sercfg 115200,8,n,1,N

esptool.exe --chip esp32 --port %COMPORT% --baud 460800 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 80m --flash_size 4MB 0x1000 %dest%/bootloader.bin 0x8000 %dest%/partitions.bin 0x10000 %dest%/firmware.bin
@echo off
echo.
pause
goto :loop

:Putty
@echo on
Putty\putty.exe -serial %COMPORT% -sercfg 115200,8,n,1,N
@echo off
echo.
pause
goto :loop

:errorInput
echo.
echo Falsche Eingabe! Bitte erneut versuchen!
echo.
pause
goto :loop


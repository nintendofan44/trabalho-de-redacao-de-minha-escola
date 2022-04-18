@echo off

cd crash-dialog
haxe hxwidgets-windows.hxml
copy build\windows\Main.exe ..\export\release\windows\bin\CrashDialog.exe
cd ..

@echo on
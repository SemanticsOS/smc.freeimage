@echo off
cls
setlocal
rem set PATH=%PATH%;%ProgramFiles%\mingw32\bin;%ProgramFiles%\msys\bin
set PYTHONPATH=src

del src\smc\freeimage\_freeimage.c
del src\smc\freeimage\*.pyd
..\..\environment\Python27\python.exe setup.py build_ext -i
..\..\environment\Python27\python.exe -m smc.freeimage.tests.__main__
rem ..\..\environment\Python26\python.exe -m smc.freeimage.tests.test_lcms
pause

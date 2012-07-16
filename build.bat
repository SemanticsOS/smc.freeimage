@echo off
cls
setlocal
rem set PATH=%PATH%;%ProgramFiles%\mingw32\bin;%ProgramFiles%\msys\bin
set PYTHONPATH=%~d0%~p0
set PYTHON=..\..\environment\Python27\python.exe

del smc\freeimage\_freeimage.c
del smc\freeimage\*.pyd

%PYTHON% setup.py build_ext -i
%PYTHON% -c "import smc.freeimage; print(smc.freeimage)"
%PYTHON% -m smc.freeimage.tests.__main__
pause

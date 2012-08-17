@echo off
cls
setlocal

set PYTHON="%ProgramFiles%\Python27\python.exe"

del smc\freeimage\_freeimage.c

%PYTHON% contrib\build.py

pause

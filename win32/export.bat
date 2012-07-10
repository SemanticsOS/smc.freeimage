@echo off
setlocal
set PATH=%PATH%;%ProgramFiles%\mingw32\bin;%ProgramFiles%\msys\bin
pexports freeimage.dll | sed "s/^_//" > freeimage_gcc.def
dlltool -U -d freeimage_gcc.def -l libfreeimage.a 
pexports lcms2.dll | sed "s/^_//" > lcms2_gcc.def
dlltool -U -d lcms2_gcc.def -l liblcms2.a 
pause

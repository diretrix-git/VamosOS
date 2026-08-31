@echo off
cd /d "%~dp0"
set PATH=C:\msys64\ucrt64\bin;C:\msys64\usr\bin;%PATH%
make clean
make

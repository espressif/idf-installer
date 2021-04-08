@echo off

:: This script is called from a shortcut (cmd.exe /k export_fallback.bat), with
:: the working directory set to an ESP-IDF directory.
:: Its purpose is to support using the "IDF Tools Directory" method of
:: installation for ESP-IDF versions older than IDF v4.0.
:: It does the same thing as "export.bat" in IDF v4.0.

set IDF_PATH=%CD%

if "%IDF_TOOLS_PATH%"=="" (
    set IDF_TOOLS_PATH=%USERPROFILE%/.espressif
    echo IDF_TOOLS_PATH not set. Setting to %IDF_TOOLS_PATH%
)

set TEMP_IDF_PYTHON_PATH="%TEMP%"\idf-python-path.txt
%IDF_TOOLS_PATH%/curator.exe config get --property python --idf-path %IDF_PATH%\>"%TEMP_IDF_PYTHON_PATH%"
set /p IDF_PYTHON_DIR=<"%TEMP_IDF_PYTHON_PATH%"

set TEMP_IDF_GIT_PATH="%TEMP%"\idf-git-path.txt
%IDF_TOOLS_PATH%/curator.exe config get --property gitPath>"%TEMP_IDF_GIT_PATH%"
set /p IDF_GIT_DIR=<"%TEMP_IDF_GIT_PATH%"

set PREFIX=%IDF_PYTHON_DIR%\python.exe %IDF_PATH%
DOSKEY idf.py=%PREFIX%\tools\idf.py $*
DOSKEY esptool.py=%PREFIX%\components\esptool_py\esptool\esptool.py $*
DOSKEY espefuse.py=%PREFIX%\components\esptool_py\esptool\espefuse.py $*
DOSKEY otatool.py=%PREFIX%\components\app_update\otatool.py $*
DOSKEY parttool.py=%PREFIX%\components\partition_table\parttool.py $*

:: Clear PYTHONPATH as it may contain libraries of other Python versions
if not "%PYTHONPATH%"=="" (
    echo Clearing PYTHONPATH, was set to %PYTHONPATH%
    set PYTHONPATH=
)

:: Clear PYTHONHOME as it may contain path to other Python versions which can cause crash of Python using virtualenv
if not "%PYTHONHOME%"=="" (
    echo Clearing PYTHONHOME, was set to %PYTHONHOME%
    set PYTHONHOME=
)

:: Set PYTHONNOUSERSITE to avoid loading of Python packages from AppData\Roaming profile
if "%PYTHONNOUSERSITE%"=="" (
    echo Setting PYTHONNOUSERSITE, was not set
    set PYTHONNOUSERSITE=True
)

:: Add Python and Git paths to PATH
set "PATH=%IDF_PYTHON_DIR%;%IDF_GIT_DIR%;%PATH%"
echo Using Python in %IDF_PYTHON_DIR%
python.exe --version
echo Using Git in %IDF_GIT_DIR%
git.exe --version

:: Check if this is a recent enough copy of ESP-IDF.
:: If so, use export.bat provided there.
:: Note: no "call", will not return into this batch file.
if exist "%IDF_PATH%\export.bat" %IDF_PATH%\export.bat

@echo off

:: The script determines location of Git, Python and ESP-IDF.
:: Similar result can be achieved by running export.ps1 from ESP-IDF directory.

:: How the script determines the location of ESP-IDF:
:: 1. try to use the fist input parameter to query configuration managed by idf-env
:: 2. try to use environment variable IDF_PATH to query configuration managed by idf-env
:: 3. try to use local working directory to query configuration managed by idf-env

if "%IDF_TOOLS_PATH%" == "" (
    set IDF_TOOLS_PATH=%~dp0
    echo IDF_TOOLS_PATH not set. Setting to %~dp0
)

if exist "echo" (
    echo "File 'echo' was detected in the current directory. The file can cause problems with 'echo.' in batch scripts."
    echo "Renaming the file to 'echo.old'"
    move "echo" "echo.old"
)

set PATH=%IDF_TOOLS_PATH%;%PATH%
set TEMP_IDF_PYTHON_PATH="%TEMP%\idf-python-path.txt"
set TEMP_IDF_PATH=%TEMP%\idf-path.txt
:: Check whether IDF ID was specified as the first parameter
set PARAM=%1
if /i "%PARAM:~0,7%"=="esp-idf" (
    idf-env config get --property "path" --idf-id %PARAM%>%TEMP_IDF_PATH%
    idf-env config get --property python --idf-id %PARAM%>%TEMP_IDF_PYTHON_PATH%
    set /P IDF_PATH=<"%TEMP_IDF_PATH%"
) else (
    if "%IDF_PATH%" == "" (
        set IDF_PATH=%CD%
    )
    idf-env config get --property python --idf-path %IDF_PATH%\>%TEMP_IDF_PYTHON_PATH%
)

set /P IDF_PYTHON=<%TEMP_IDF_PYTHON_PATH%

set TEMP_IDF_GIT_PATH="%TEMP%\idf-git-path.txt"
idf-env config get --property gitPath>%TEMP_IDF_GIT_PATH%
set /P IDF_GIT=<%TEMP_IDF_GIT_PATH%

set PREFIX=%IDF_PYTHON% %IDF_PATH%
DOSKEY idf.py=%PREFIX%\tools\idf.py $*
DOSKEY esptool.py=%PREFIX%\components\esptool_py\esptool\esptool.py $*
DOSKEY espefuse.py=%PREFIX%\components\esptool_py\esptool\espefuse.py $*
DOSKEY espsecure.py=%PREFIX%\components\esptool_py\esptool\espsecure.py $*
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

:: Get base name of Git and Python
for %%F in (%IDF_PYTHON%) do set IDF_PYTHON_DIR=%%~dpF
for %%F in (%IDF_GIT%) do set IDF_GIT_DIR=%%~dpF

:: Add Python and Git paths to PATH
set "PATH=%IDF_PYTHON_DIR%;%IDF_GIT_DIR%;%PATH%"
echo Using Python in %IDF_PYTHON_DIR%
%IDF_PYTHON% --version
echo Using Git in %IDF_GIT_DIR%
%IDF_GIT% --version

:: Check if this is a recent enough copy of ESP-IDF.
:: If so, use export.bat provided there.
:: Note: no "call", will not return into this batch file.
if exist "%IDF_PATH%\export.bat" %IDF_PATH%\export.bat

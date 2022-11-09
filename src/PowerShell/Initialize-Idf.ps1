# This script is called from a Windows shortcut and Windows Terminal launcher fragments.
# The script determines location of Git, Python and ESP-IDF.
# Similar result can be achieved by running export.ps1 from ESP-IDF directory.

# How the script determines the location of ESP-IDF:
# 1. try to use IdfId parameter to query configuration managed by idf-env
# 2. try to use environment variable IDF_PATH to query configuration managed by idf-env
# 3. try to use local working directory to query configuration managed by idf-env

[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $IdfId=""
)

if ($null -eq $env:IDF_TOOLS_PATH) {
    $env:IDF_TOOLS_PATH="$PSScriptRoot"
    "IDF_TOOLS_PATH not set. Setting to $PSScriptRoot"
}

$env:PATH="$env:IDF_TOOLS_PATH;$env:PATH"

$IdfGit=idf-env config get --property gitPath

if ("" -eq $IdfId) {
    if ($null -eq $env:IDF_PATH) {
        $IDF_PATH=(Get-Location).Path
    } else {
        $IDF_PATH=$env:IDF_PATH
    }
    $PythonCommand=idf-env config get --property python --idf-path "$IDF_PATH\"
} else {
    $PythonCommand=idf-env config get --property python --idf-id ${IdfId}
    $IDF_PATH=idf-env config get --property path --idf-id ${IdfId}
}

$isEspIdfRoot = (Test-Path "$IDF_PATH/tools/idf.py")
if (-not $isEspIdfRoot) {
    "Unable to find ESP-IDF on following path: $IDF_PATH"
    "Recommendations:"
    "  #1: Run ESP-IDF Tools Windows installer and select an existing installation of ESP-IDF to repair the configuration."
    "  #2: Set working directory to root of ESP-IDF and launch this script."
    "  #3: Other option: Set environment variable IDF_PATH pointing to the directory with ESP-IDF."
    Exit 1
}

function idf.py { &$PythonCommand "$IDF_PATH\tools\idf.py" $args }
function esptool.py { &$PythonCommand "$IDF_PATH\components\esptool_py\esptool\esptool.py" $args }
function espefuse.py { &$PythonCommand "$IDF_PATH\components\esptool_py\esptool\espefuse.py" $args }
function espsecure.py { &$PythonCommand "$IDF_PATH\components\esptool_py\esptool\espsecure.py" $args }
function otatool.py { &$PythonCommand "$IDF_PATH\components\app_update\otatool.py" $args }
function parttool.py { &$PythonCommand "$IDF_PATH\components\partition_table\parttool.py" $args }

# Clear PYTHONPATH as it may contain libraries of other Python versions
if ($null -ne $env:PYTHONPATH) {
    "Clearing PYTHONPATH, was set to $env:PYTHONPATH"
    $env:PYTHONPATH=$null
}

# Clear PYTHONHOME as it may contain path to other Python versions which can cause crash of Python using virtualenv
if ($null -ne $env:PYTHONHOME) {
    "Clearing PYTHONHOME, was set to $env:PYTHONHOME"
    $env:PYTHONHOME=$null
}

# Set PYTHONNOUSERSITE to avoid loading of Python packages from AppData\Roaming profile
if ($null -eq $env:PYTHONNOUSERSITE) {
    "Setting PYTHONNOUSERSITE, was not set"
    $env:PYTHONNOUSERSITE="True"
}

# Strip quotes
$IdfGitDir = (Get-Item $IdfGit).Directory.FullName
$IdfPythonDir = (Get-Item $PythonCommand).Directory.FullName

# Add Python and Git paths to PATH
$env:PATH = "$IdfGitDir;$IdfPythonDir;$env:PATH"
"Using Python in $IdfPythonDir"
&$PythonCommand --version
"Using Git in $IdfGitDir"
&$IdfGit --version

# Check if this is a recent enough copy of ESP-IDF.
# If so, use export.ps1 provided there.
$isExport = (Test-Path "$IDF_PATH/export.ps1")
if ($isExport){
    . $IDF_PATH/export.ps1
}
else {
    "IDF version does not include export.ps1. Using the fallback version."

    if ((Test-Path "$IDF_PATH/tools/tools.json")){
        $IDF_TOOLS_JSON_PATH = "$IDF_PATH/tools/tools.json"
    }
    else{
        "IDF version does not include tools/tools.json. Using the fallback version."
        $IDF_TOOLS_JSON_PATH = "$PSScriptRoot/tools_fallback.json"
    }

    if ((Test-Path "$IDF_PATH/tools/idf_tools.py")){
        $IDF_TOOLS_PY_PATH = "$IDF_PATH/tools/idf_tools.py"
    }
    else{
        "IDF version does not include tools/idf_tools.py. Using the fallback version."
        $IDF_TOOLS_PY_PATH = "$PSScriptRoot/idf_tools_fallback.py"
    }

    "Setting IDF_PATH: $IDF_PATH"
    $env:IDF_PATH = $IDF_PATH

    "Adding ESP-IDF tools to PATH..."
    $OLD_PATH = $env:Path.split(";") | Select-Object -Unique # array without duplicates
    # using idf_tools.py to get $envars_array to set
    $envars_raw = (python.exe "$IDF_TOOLS_PY_PATH" --tools-json "$IDF_TOOLS_JSON_PATH" export --format key-value)
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } # if error

    $envars_array # will be filled like:
    #               [
    #                    [vname1, vval1], [vname2, vval2], ...
    #               ]
    foreach ($line  in $envars_raw) {
        $pair = $line.split("=") # split in name, val
        $var_name = $pair[0].Trim() # trim spaces on the ends of the name
        $var_val = $pair[1].Trim() # trim spaces on the ends of the val
        $var_val = $var_val -replace "%(.+)%", "`$env:`$1" # convert var syntax to PS using RegEx
        $var_val = $ExecutionContext.InvokeCommand.ExpandString($var_val) # expand variables to values
        $envars_array += (, ($var_name, $var_val))
    }

    foreach ($pair  in $envars_array) {
        # setting the values
        $var_name = $pair[0].Trim() # trim spaces on the ends of the name
        $var_val = $pair[1].Trim() # trim spaces on the ends of the val
        Set-Item -Path "Env:$var_name" -Value "$var_val"
    }

    #Compare Path's OLD vs. NEW
    $NEW_PATH = $env:Path.split(";") | Select-Object -Unique # array without duplicates
    $dif_Path = Compare-Object -ReferenceObject $OLD_PATH -DifferenceObject $NEW_PATH -PassThru
    if ($dif_Path -ne $null) {
        $dif_Path
    }
    else {
        "No directories added to PATH:"
        $OLD_PATH
    }


   "Checking if Python packages are up to date..."

    Start-Process -Wait -NoNewWindow -FilePath "python" -Args "`"$IDF_PATH/tools/check_python_dependencies.py`""
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } # if error

    "
Done! You can now compile ESP-IDF projects.
Go to the project directory and run:
    idf.py build
"

}

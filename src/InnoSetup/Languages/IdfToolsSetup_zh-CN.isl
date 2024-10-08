﻿; Copyright 2019-2020 Espressif Systems (Shanghai) CO LTD
; SPDX-License-Identifier: Apache-2.0

[LangOptions]
LanguageID=$0804

[CustomMessages]
PreInstallationCheckTitle=安装前系统检查
PreInstallationCheckSubtitle=环境验证
SystemCheckStart=开始系统检查...
SystemCheckForDefender=检查 Windows Defender
SystemCheckHint=提示
SystemCheckResultFound=存在
SystemCheckResultNotFound=不存在
SystemCheckResultOk=正常
SystemCheckResultFail=失败
SystemCheckResultError=错误
SystemCheckResultWarn=警告
SystemCheckStopped=检查终止。
SystemCheckStopButtonCaption=停止
SystemCheckComplete=检查完成。
SystemCheckForComponent=检查已安装内容
SystemCheckUnableToExecute=无法执行
SystemCheckUnableToFindFile=无法找到文件
SystemCheckRemedyMissingPip=请使用随后显示的支持的 Python 版本。
SystemCheckRemedyMissingVirtualenv=请安装虚拟设备并重试安装。建议的命令：
SystemCheckRemedyCreateVirtualenv=请使用随后显示的支持的 Python 版本。
SystemCheckRemedyPythonInVirtualenv=请使用随后显示的支持的 Python 版本。
SystemCheckRemedyBinaryPythonWheel=请使用随后显示的支持的 Python 版本。
SystemCheckRemedyFailedHttpsDownload=请使用随后显示的支持的 Python 版本。
SystemCheckRemedyFailedSubmoduleRun=Python 包含一个用于 Python 2 的 subprocess.run 模块。请卸载模块。建议的命令：
SystemCheckApplyFixesButtonCaption=应用修复
SystemCheckFullLogButtonCaption=完整日志
SystemCheckApplyFixesConsent=是否要应用经过建议修复的命令，以更新 Windows 环境并启动新的系统检查？
SystemCheckFixesSuccessful=修复应用成功。
SystemCheckFixesFailed=修复应用失败。请参阅完整日志。
SystemCheckNotCompleteConsent=系统检查尚未完成。您想要跳过检查进行下一步吗？
SystemCheckOldOS=不再支援該作業系統。請注意，安裝程式可能無法如預期般運作。
SystemCheckRootCertificates=检查证书
SystemCheckRootCertificateWarning=无法加载来自服务器 的数据。
SystemCheckForLongPathsEnabled=检查 Windows 注册表中的“启用长路径”
SystemCheckRemedyFailedLongPathsEnabled=请将注册表 HKLM\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled 设为 1。该操作需要管理员权限。命令：
SystemCheckRemedyApplyFixInfo=完成系统检查后，单击“应用修复”按钮。
CreateShortcutStartMenu=开始菜单
CreateShortcutDesktop=桌面
CreateShortcutPowerShell=使用 PowerShell 为 ESP-IDF 工具创建快捷方式：
CreateShortcutCMD=使用 CMD 为 ESP-IDF 工具创建快捷方式：
OptimizationTitle=优化：
OptimizationWindowsDefender=将 ESP-IDF 工具的可执行文件注册为 Windows Defender 的排除项。该项操作可以节省大约 30% 的汇编时间。安装程序将文件部署在操作系统上，由防病毒软件对文件进行扫描。注册排除项需要提升权限。可以通过 idf-env 工具添加或删除排除项。详情参阅: https://github.com/espressif/idf-env。
OptimizationDownloadMirror=使用乐鑫下载服务器，而非从 GitHub 下载工具包。
ErrorTooLongIdfPath=ESP-IDF 的路径长度超过 90 个字符。路径过长可能导致使用某些构建工具时出现问题。请选择较短的路径。
ErrorTooLongToolsPath=ESP-IDF 工具的路径长度超过 90 个字符。路径过长可能导致使用某些构建工具时出现问题。请选择较短的路径。
ComponentIde=开发集成
ComponentEclipse=Espressif-IDE
ComponentRust=对 Xtensa 的 Rust 语言支持
ComponentRustGnu=Rust ESP toolchain for x86_64-pc-windows-gnu (requires MinGW)
ComponentRustGnuMinGW=MinGW x86_64 with MSYS2
ComponentRustMsvc=Rust ESP toolchain for x86_64-pc-windows-msvc (requires Windows 11 SDK and MSVC C++)
ComponentRustMsvcVctools=Windows 11 SDK and MSVC C++
ComponentRustBinaryCrates=Binary crates for Rust (cargo-espflash, cargo-generate, ldproxy)
ComponentDesktopShortcut=桌面快捷方式
ComponentPowerShell=PowerShell
ComponentPowerShellWindowsTerminal=Windows 终端下拉菜单
ComponentStartMenuShortcut=开始菜单快捷方式
ComponentCommandPrompt=命令提示符
ComponentDrivers=驱动程序 - 需要提升权限
ComponentDriverEspressif=Espressif - WinUSB 对 JTAG 的支持 (ESP32-C3/S3)
ComponentDriverFtdi=FTDI Chip - USB 的虚拟 COM 端口 (WROVER, WROOM)
ComponentDriverSilabs=Silicon Labs - USB CP210x 的虚拟 COM 端口 （ESP 开发板）
ComponentDriverWch=WCH - USB CH343/CH9102 的虚拟 COM 端口 (LilyGo  开发板)
ComponentTarget=Chip Targets - 详情请参阅: https://products.espressif.com/
ComponentTargetEsp32=ESP32
ComponentTargetEsp32c=ESP32-C 系列
ComponentTargetEsp32c2=ESP32-C2 (ESP-IDF v5.0+)
ComponentTargetEsp32c3=ESP32-C3 (ESP-IDF v4.3+)
ComponentTargetEsp32c6=ESP32-C6 (ESP-IDF v5.1+)
ComponentTargetEsp32h=ESP32-H 系列
ComponentTargetEsp32h2=ESP32-H2 (ESP-IDF v5.1+)
ComponentTargetEsp32s=ESP32-S 系列
ComponentTargetEsp32s3=ESP32-S3 (ESP-IDF v4.4+)
ComponentTargetEsp32s2=ESP32-S2 (ESP-IDF v4.2+)
ComponentTargetEsp32p=ESP32-P Series
ComponentTargetEsp32p4=ESP32-P4 (ESP-IDF v5.3+)
ComponentOptimization=优化
ComponentOptimizationEspressifDownload=使用 Espressif 下载镜像代替 Github
InstallationFull=完全安装
InstallationMinimal=最小化安装
InstallationCustom=自定义安装
RunInstallGit=安装 Git
RunEclipse=运行 Espressif-IDE 环境
PointToDocumentation=開始使用 ESP-IDF - 文件
RunPowerShell=运行 ESP-IDF PowerShell 环境
RunCmd=运行 ESP-IDF 命令提示符环境
InstallationCancelled=安装已取消。
InstallationFailed=安装过程遇到错误（可能并不严重）。 退出代码：
InstallationFailedAtStep=安装失败，失败步骤为：
DirectoryAlreadyExists=目录已经存在且并不为空：
ChooseDifferentDirectory=请另外选择目录。
SpacesInPathNotSupported=ESP-IDF 构建系统不支持包含空格的路径。
SpecialCharactersInPathNotSupported=不支持在包含特殊字符的路径上安装选定的 IDF 版本。
EspIdfVersion=ESP-IDF 版本
ChooseEspIdfVersion=请选择要安装的 ESP-IDF 版本
MoreInformation=有关 ESP-IDF 版本的更多信息，请参阅
EspIdfVersionInformationUrl=https://docs.espressif.com/projects/esp-idf/en/latest/versions.html
ChooseEspIdfDirectory=选择安装 ESP-IDF 的目录
DownloadOrUseExistingEspIdf=下载或使用 ESP-IDF
DownloadOrUseExistingEspIdfDetail=请选择要下载的 ESP-IDF 版本，或使用现有的 ESP-IDF 副本
AvailableEspIdfVersions=可用的 ESP-IDF 版本
ChooseExistingEspIdfDirectory=选择现有的 ESP-IDF 目录
DirectoryDoesNotExist=目录不存在：
UnableToFindIdfpy=无法找到 idf.py, 搜索范围为：
UnableToFindRequirementsTxt=无法找到 requirements.txt, 搜索范围为：
EspIdfToolsShouldNotBeLocatedUnderSource=工具不应位于上一页所选的 ESP-IDF 源代码目录下。请选择其它位置放置工具目录。
PythonVersionChoice=Python 选择
PythonVersionChoiceDetail=请选择 Python 版本
AvailablePythonVersions=可用的 Python 版本
UnableToWriteConfiguration=无法将 ESP-IDF 配置编写到
CheckPermissionToFile=请检查文件权限并重试安装。
SwitchBranch=切换分支
FinishingEspIdfInstallation=完成 ESP-IDF 安装
CleaningUntrackedDirectories=清理未跟踪的目录
ExtractingEspIdf=提取 ESP-IDF
SettingUpReferenceRepository=设置参考仓库
DownloadingEspIdf=下载 ESP-IDF
UsingGitToClone=使用 git 克隆 ESP-IDF 仓库
CopyingEspIdf=将 ESP-IDF 复制到目标目录
InstallingEspIdfTools=安装 ESP-IDF 工具
CheckingPythonVirtualEnvSupport=检查 Python 虚拟环境支持
CreatingPythonVirtualEnv=创建 Python 环境
InstallingPythonVirtualEnv=安装 Python 环境
RepackingRepository=重新打包仓库
UpdatingSubmodules=更新子模块
UpdatingFileMode=更新 fileMode
UpdatingFileModeInSubmodules=在子模块中更新 fileMode
UpdatingNewLines=更新换行符
UpdatingNewLinesInSubmodules=在子模块中更新换行符
FailedToCreateShortcut=创建快捷方式失败：
ExtractingPython=提取 Python 解释器
UsingEmbeddedPython=使用嵌入式 Python
ExtractingGit=提取 Git
UsingEmbeddedGit=使用嵌入式 Git
Extracting=正在提取...
InstallationLogCreated=已创建安装日志，其中可能包含有关该问题的详细信息。
DisplayInstallationLog=是否需要查看安装日志？
UsingPython=使用 Python
UsingGit=使用 Git
DownloadGitForWindows=即将在 Windows 下载并安装 Git
UsingExistingEspIdf=使用现有的 ESP-IDF 副本：
InstallingNewEspIdf=即将安装 ESP-IDF
EspIdfToolsDirectory=IDF 工具目录（IDF_TOOLS_PATH）：
DownloadEspIdf=下载 ESP-IDF
UsingExistingEspIdfDirectory=使用现有的 ESP-IDF 目录
InstallingDrivers=安装驱动程序
InstallingRust=安装 Rust 语言
SystemCheckToolsPathSpecialCharacter=系统代码页面设置为 65001，工具路径包含特殊字符。由于 JRE 的限制，无法在包含特殊字符的路径上安装 Espressif-IDE。请选择不包含特殊字符的工具位置。
SystemCheckTmpPathSpecialCharacter=系统代码页面设置为 65001，环境变量 TMP 包含特殊字符。由于 JRE 的限制，当 TMP 包含特殊字符时，Espressif-IDE 无法运行。请将 TMP 变量放置于不包含特殊字符的路径，并重试安装。
SystemCheckActiveCodePage=活动代码页：
SystemCheckUnableToDetermine=无法确定
SystemVersionTooLow=Windows 操作系统版本过旧或不支持。请使用支持的版本。
WindowsVersion=Windows 版本
SystemCheckAlternativeMirror=测试备选镜像
ComponentOptimizationGitMirror=Git 镜像
ComponentOptimizationGiteeMirror=Git 镜像 (码云) gitee.com/EspressifSystems/esp-idf
ComponentOptimizationJihulabMirror=Git 镜像 (极狐) jihulab.com/esp-mirror/espressif/esp-idf/
ComponentOptimizationGitShallow=仅克隆当前分支 (--single-branch)
SummaryComponents=Components
SummaryDrivers=驱动程序
SummaryTargets=Targets
SummaryOptimization=优化下载
ComponentToitJaguar=Toit 语言支持 - Jaguar live reloading tool (jag.exe)
InstallingToit=正在安装 Toit 语言
ComponentJdk=Amazon Corretto 11 JDK
SettingEnvironmentVariable=正在设置环境变量
SystemCheckEnvironmentVariables=环境变量
SystemCheckPathExtError=PATHEXT 路径中不包含 .EXE

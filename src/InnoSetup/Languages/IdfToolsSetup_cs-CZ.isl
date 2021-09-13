; Copyright 2019-2020 Espressif Systems (Shanghai) CO LTD
; SPDX-License-Identifier: Apache-2.0

[LangOptions]
LanguageName=Czech
LanguageID=$0405

[CustomMessages]
PreInstallationCheckTitle=Kontrola systému před instalací
PreInstallationCheckSubtitle=Kontrola prostředí
SystemCheckStart=Start kontroly systému ...
SystemCheckForDefender=Ověření Windows Defender
SystemCheckHint=Tip
SystemCheckResultFound=NALEZENO
SystemCheckResultNotFound=NENALEZENO
SystemCheckResultOk=OK
SystemCheckResultFail=SELHÁNÍ
SystemCheckResultError=CHYBA
SystemCheckResultWarn=VAROVÁNÍ
SystemCheckStopped=Kontrola zastavena.
SystemCheckStopButtonCaption=Zastavit
SystemCheckComplete=Kontrola dokončena.
SystemCheckForComponent=Kontrola instalace
SystemCheckUnableToExecute=Není možné spustit
SystemCheckUnableToFindFile=Není možné najít soubor
SystemCheckRemedyMissingPip=Použijte podporovanou verzi Python-u, která je dostupná na další obrazovce.
SystemCheckRemedyMissingVirtualenv=Doinstalujte balíček virtualenv a opakujte instalaci. Doporučovaný příkaz:
SystemCheckRemedyCreateVirtualenv=Použijte podporovanou verzi Python-u, která je dostupná na další obrazovce.
SystemCheckRemedyPythonInVirtualenv=Použijte podporovanou verzi Python-u, která je dostupná na další obrazovce.
SystemCheckRemedyBinaryPythonWheel=Použijte podporovanou verzi Python-u, která je dostupná na další obrazovce.
SystemCheckRemedyFailedHttpsDownload=Použijte podporovanou verzi Python-u, která je dostupná na další obrazovce.
SystemCheckRemedyFailedSubmoduleRun=Python contains a subprocess.run module intended for Python 2. Please uninstall the module. Suggested command:
SystemCheckApplyFixesButtonCaption=Opravit
SystemCheckFullLogButtonCaption=Detaily
SystemCheckApplyFixesConsent=Přejete si spustit aplikování oprav vašeho prostředí Windows?
SystemCheckFixesSuccessful=Aplikace oprav byla úspěšná.
SystemCheckFixesFailed=Aplikace oprav selhala. Bližší informace jsou dostupné pod tlačítkem Detail.
SystemCheckNotCompleteConsent=Kontola systému není hotová. Přejete si zastavit kontrolu a pokračova bez ní?
SystemCheckRootCertificates=Kontrola certifikátů
SystemCheckRootCertificateWarning=Není možné načíst data ze serveru dl.espressif.com.
SystemCheckForLongPathsEnabled=Kontrola podpory pro "Dlouhé cesty" ve Windows registrech
SystemCheckRemedyFailedLongPathsEnabled=Ověřte, že registr HKLM\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled je nastaven na hodnotu 1. Operace vyžaduje administátorská oprávnění. Příkaz:
SystemCheckRemedyApplyFixInfo=Zvolte tlačítko 'Opravit' po dokončení systémové kontroly.
CreateShortcutStartMenu=Menu Start
CreateShortcutDesktop=Plocha
CreateShortcutPowerShell=PowerShell - vytvořit zástupce ESP-IDF Tools:
CreateShortcutCMD=CMD - vytvořit zástupce ESP-IDF Tools:
OptimizationTitle=Optimalizace:
OptimizationWindowsDefender=Registrovat binární soubory ESP-IDF Tools jako výjimky do Windows Defender. Registrací je možné zvýšit rychlost sestavení až o 30%. Instalátor již zapsal soubory na systém, takže lokální antivirový software je prověřil. Registrace vyžaduje administátorská oprávnění. Výjimky je možné spravovat pomocí nástroje idf-env. Více informací: https://github.com/espressif/idf-env.
OptimizationDownloadMirror=Použít Espressif download server pro stahovíní nástrojů místo GitHub-u.
ErrorTooLongIdfPath=Cesta k ESP-IDF je delší než 90 znaků. Příliš dlouhá cesta může způsobit problém některým nástrojům. Použijte kratší cestu.
ErrorTooLongToolsPath=Cesta k ESP-IDF Tools je delší než 90 znaků. Příliš dlouhá cesta může způsobit problém některým nástrojům. Použijte kratší cestu.

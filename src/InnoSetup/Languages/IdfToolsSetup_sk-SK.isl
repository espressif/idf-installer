; Copyright 2019-2020 Espressif Systems (Shanghai) CO LTD
; SPDX-License-Identifier: Apache-2.0

[LangOptions]
LanguageID=$041b
LanguageCodePage=1250

[CustomMessages]
PreInstallationCheckTitle=Kontrola systému pred inštaláciou
PreInstallationCheckSubtitle=Overenie prostredia
SystemCheckStart=Štart kontroly systému ...
SystemCheckForDefender=Kontrola Windows Defender
SystemCheckHint=Nápoveda
SystemCheckResultFound=NÁJDENÉ
SystemCheckResultNotFound=NENÁJDENÉ
SystemCheckResultOk=OK
SystemCheckResultFail=ZLYHANIE
SystemCheckResultError=CHYBA
SystemCheckResultWarn=VAROVANIE
SystemCheckStopped=Kontrola zastavená.
SystemCheckStopButtonCaption=Zastaviť
SystemCheckComplete=Kontrola hotová.
SystemCheckForComponent=Kontrola inštalovaných komponent
SystemCheckUnableToExecute=Nie je možné spustiť
SystemCheckUnableToFindFile=Nie je možné nájst súbor
SystemCheckRemedyMissingPip=Použite podporovaná verziu Python-u, ktorú nájdete na nasledujúcej obrazovke.
SystemCheckRemedyMissingVirtualenv=Nainštalujte balík virtualenv a opakujte inštaláciu. Odporúčaný príkaz:
SystemCheckRemedyCreateVirtualenv=Použite podporovaná verziu Python-u, ktorú nájdete na nasledujúcej obrazovke
SystemCheckRemedyPythonInVirtualenv=Použite podporovaná verziu Python-u, ktorú nájdete na nasledujúcej obrazovke
SystemCheckRemedyBinaryPythonWheel=Použite podporovaná verziu Python-u, ktorú nájdete na nasledujúcej obrazovke
SystemCheckRemedyFailedHttpsDownload=Použite podporovaná verziu Python-u, ktorú nájdete na nasledujúcej obrazovke.
SystemCheckRemedyFailedSubmoduleRun=Python obsahuje modul subprocess.run, ktorý je určený pre Python 2. Odinštalujte prosém modul. Odporučaný príkaz:
SystemCheckApplyFixesButtonCaption=Opraviť
SystemCheckFullLogButtonCaption=Detaily
SystemCheckApplyFixesConsent=Chcete spustiť aplikovanie opráv vašeho prostredia Windows?
SystemCheckFixesSuccessful=Aplikovanie opráv bolo úspešné.
SystemCheckFixesFailed=Aplikovanie opráv sa nepodarilo. Detailné informácie sú dostupné pod tlačidlom Detaily.
SystemCheckNotCompleteConsent=Kontrola systému ešte nie je hotová. Chcete kontrolu ukončiť a pokračovať bez kontroly?
SystemCheckRootCertificates=Kontrola certifikátov
SystemCheckRootCertificateWarning=Nie je možné spojiť sa so serverom dl.espressif.com.
SystemCheckForLongPathsEnabled=Kontrola podporu pre "Dlhé cesty" vo Windows registroch
SystemCheckRemedyFailedLongPathsEnabled=Nastavte register HKLM\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled na hodnotu 1. Operácia vyžaduje administrátorské oprávnenia. Príkaz:
SystemCheckRemedyApplyFixInfo=Zvoľte tlačidlo 'Opraviť' po dokončení kontroly systému.
CreateShortcutStartMenu=Menu Štart
CreateShortcutDesktop=Plocha
CreateShortcutPowerShell=PowerShell - Vytvoriť skratku pre ESP-IDF Tools:
CreateShortcutCMD=CMD - Vytvoriť skratku pre ESP-IDF Tools:
OptimizationTitle=Optimalizácie:
OptimizationWindowsDefender=Zaregistrovať spustiteľné súbory z ESP-IDF Tools vo výnimkách pre Windows Defender. Registrácia výnimiek môže úrychliť zostavenie programu až o 30%. Inštalátor už zapísal súbory na súborový systém, takže by mali byť skontrolované nainštalovaným antivírusovým softvérom. Registrácia vyžaduje administátorské oprávnenia. Výnimky je tiež možné zaregistrovať/zrušiť pomocou nástroja idf-env. Viac informácií: https://github.com/espressif/idf-env.
OptimizationDownloadMirror=Použiť Espressif download server pre získanie baličkov s nástrojmi (namiesto GitHub-u).
ErrorTooLongIdfPath=Cestu k ESP-IDF je dlhšia než 90 znakov. Príliš dlhá cesta môže spôsobovať problém niekotrým nástrojom. Vyberte prosím kratšiu cestu.
ErrorTooLongToolsPath=Cesta k ESP-IDF Tools je dlhšia než 90 znakov. Príliš dlhá cesta môže spôsobovať problém niekotrým nástrojom. Vyberte prosím kratšiu cestu.

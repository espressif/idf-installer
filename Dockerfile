# Docker image for building Inno Setup installers.
# Installs Wine, Inno Setup, Inno Download Plugin, and osslsigncode.
# Provides a wraper script, 'iscc', which runs ISCC.exe in Wine with given script.
#
# bin/xvfb-run-wine is a simplified version of the xvfb-run script,
# which starts Xvfb, runs the given command in Wine, and waits for wineserver to finish.
#
# Credits:
# https://medium.com/faun/running-windows-app-headless-in-docker-15ff008f2f16
# https://hub.docker.com/r/scottyhardy/docker-wine/
# https://github.com/jonataa/innosetup-docker

FROM debian AS base-image

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y -q \
    software-properties-common \
    apt-transport-https \
    wget \
    gnupg \
    osslsigncode \
    python3 \
    python3-pip \
    p7zip \
    git \
    unzip \
    curl \
  && update-alternatives --install /usr/bin/python python /usr/bin/python3 10
RUN wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y powershell
RUN apt-get install -y xvfb
RUN dpkg --add-architecture i386 \
    && apt-get update && apt-get install -y wine
#  && wget --no-verbose -nc https://dl.winehq.org/wine-builds/winehq.key \
#  && apt-key add winehq.key \
#  && apt-add-repository https://dl.winehq.org/wine-builds/debian/ \
#    winehq-stable \
#    xvfb \
#  && apt-get remove -y \
#    software-properties-common \
#    apt-transport-https \
#    gnupg \
#  && apt-get clean -y \
#  && apt-get autoremove -y \
#  && rm -rf /var/lib/apt/lists/*


ENV WINEPREFIX=/opt/wine
# Disable Mono and Gecko popups in wineboot
ENV WINEDLLOVERRIDES="mscoree,mshtml="
# Make Wine slightly less noisy
ENV WINEDEBUG=fixme-all

ARG INNO_DIST=innosetup-6.1.2.exe
ARG INNO_SHA256=a3ce1c40ef9c71a92691aaff0f413f530c8c9e3c766be481bc63ca7cc74e35e7

ARG IDP_DIST=idpsetup-1.5.1.exe
ARG IDP_SHA256=e7a7013f533e1f8f9ebbb5138c5c208af0c58c80590b72acabdbb337af8fd060
#RUN dpkg --add-architecture i386 \
#    && apt-get install wine32
ADD src/Bash/* /usr/local/bin/
ADD src/Resources/ShowDotFiles.reg /usr/local/share/

RUN wget --no-verbose http://files.jrsoftware.org/is/6/${INNO_DIST} \
  && echo "${INNO_SHA256} *${INNO_DIST}" | sha256sum --check --strict - \
  && wget --no-verbose https://github.com/espressif/inno-download-plugin/releases/download/v1.5.1/${IDP_DIST} \
  && echo "${IDP_SHA256} *${IDP_DIST}" | sha256sum --check --strict - \
  && xvfb-run-wine wineboot \
  && xvfb-run-wine ${INNO_DIST} /ALLUSERS /SILENT \
  && xvfb-run-wine ${IDP_DIST} /SILENT \
  && xvfb-run-wine regedit /usr/local/share/ShowDotFiles.reg \
  && rm ${INNO_DIST} ${IDP_DIST}

ENV ISCC_PATH="/opt/wine/drive_c/Program Files (x86)/Inno Setup 6/ISCC.exe"


FROM base-image AS builder
CMD [ "/usr/bin/pwsh" ]
SHELL [ "/usr/bin/pwsh" ]
COPY src /opt/idf-installer/src
COPY Build-Installer.ps1 /opt/idf-installer/Build-Installer.ps1
WORKDIR /opt/idf-installer

#FROM builder AS installer-online
#RUN [ "pwsh", "./Build-Installer.ps1", "-InstallerType", "online" ]

#FROM installer-online AS runner-online
#RUN src/PowerShell/Install-Idf.ps1 -Installer 'build/online/esp-idf-tools-setup-online-unsigned.exe'
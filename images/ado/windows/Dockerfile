FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-NoLogo", "-NoProfile", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN New-Item -Path C:\azp -ItemType Directory -Force | Out-Null

COPY start.ps1 C:/azp/start.ps1

WORKDIR C:/azp

ENTRYPOINT ["powershell", "-NoLogo", "-NoProfile", "-File", "C:/azp/start.ps1"]

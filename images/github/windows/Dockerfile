FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-NoLogo", "-NoProfile", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG RUNNER_VERSION=2.331.0

RUN New-Item -Path C:\runner -ItemType Directory -Force | Out-Null; \
    Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v${env:RUNNER_VERSION}/actions-runner-win-x64-${env:RUNNER_VERSION}.zip" -OutFile C:\runner\actions-runner.zip; \
    Expand-Archive -Path C:\runner\actions-runner.zip -DestinationPath C:\runner -Force; \
    Remove-Item C:\runner\actions-runner.zip -Force

# Install Chocolatey and Git (provides bash)
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')); \
    choco feature enable -n allowGlobalConfirmation; \
    choco install git -y; \
    Write-Output 'Chocolatey and Git installed'

# Install Visual C++ Redistributable (2015-2022)
RUN $vcUrl = 'https://aka.ms/vs/17/release/vc_redist.x64.exe'; \
    $out = 'C:\vc_redist.x64.exe'; \
    Invoke-WebRequest -Uri $vcUrl -OutFile $out; \
    Start-Process -FilePath $out -ArgumentList '/install','/passive','/norestart' -Wait; \
    Remove-Item $out -Force; \
    Write-Output 'VC++ Redistributable installed'

COPY start.ps1 C:/runner/start.ps1

WORKDIR C:/runner

ENTRYPOINT ["powershell", "-NoLogo", "-NoProfile", "-File", "C:/runner/start.ps1"]

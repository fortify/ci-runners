FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-NoLogo", "-NoProfile", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ARG RUNNER_VERSION=2.331.0

RUN New-Item -Path C:\runner -ItemType Directory -Force | Out-Null; \
    Invoke-WebRequest -Uri "https://github.com/actions/runner/releases/download/v${env:RUNNER_VERSION}/actions-runner-win-x64-${env:RUNNER_VERSION}.zip" -OutFile C:\runner\actions-runner.zip; \
    Expand-Archive -Path C:\runner\actions-runner.zip -DestinationPath C:\runner -Force; \
    Remove-Item C:\runner\actions-runner.zip -Force

COPY start.ps1 C:/runner/start.ps1

WORKDIR C:/runner

ENTRYPOINT ["powershell", "-NoLogo", "-NoProfile", "-File", "C:/runner/start.ps1"]

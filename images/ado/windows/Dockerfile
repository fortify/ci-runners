FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-NoLogo", "-NoProfile", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN New-Item -Path C:\azp -ItemType Directory -Force | Out-Null

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

COPY start.ps1 C:/azp/start.ps1

WORKDIR C:/azp

ENTRYPOINT ["powershell", "-NoLogo", "-NoProfile", "-File", "C:/azp/start.ps1"]

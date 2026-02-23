$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not $env:AZP_URL) {
  throw "AZP_URL is required"
}

if ($env:AZP_TOKEN_FILE) {
  $env:AZP_TOKEN = [System.IO.File]::ReadAllText($env:AZP_TOKEN_FILE).Trim()
}

if (-not $env:AZP_TOKEN) {
  throw "AZP_TOKEN or AZP_TOKEN_FILE is required"
}

$pool = if ($env:AZP_POOL) { $env:AZP_POOL } else { "Default" }
$agentName = if ($env:AZP_AGENT_NAME) { $env:AZP_AGENT_NAME } else { $env:COMPUTERNAME }
$workDir = if ($env:AZP_WORK) { $env:AZP_WORK } else { "_work" }

Set-Location C:\azp
New-Item -Path C:\azp\agent -ItemType Directory -Force | Out-Null
Set-Location C:\azp\agent

$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($env:AZP_TOKEN)"))
$pkgApi = "$($env:AZP_URL.TrimEnd('/'))/_apis/distributedtask/packages/agent?platform=win-x64&`$top=1"
$pkg = Invoke-RestMethod -Uri $pkgApi -Headers @{ Authorization = "Basic $auth" } -Method Get
$pkgUrl = $pkg.value[0].downloadUrl

if (-not $pkgUrl) {
  throw "Unable to resolve Azure Pipelines agent package URL"
}

$zipPath = "C:\azp\agent.zip"
Invoke-WebRequest -Uri $pkgUrl -OutFile $zipPath
Expand-Archive -Path $zipPath -DestinationPath C:\azp\agent -Force
Remove-Item $zipPath -Force

$cleanupToken = $env:AZP_TOKEN
$exitCode = 1

try {
  & .\config.cmd --unattended --url $env:AZP_URL --auth PAT --token $cleanupToken --pool $pool --agent $agentName --work $workDir --replace --acceptTeeEula
  if ($LASTEXITCODE -ne 0) {
    throw "Agent configuration failed with exit code $LASTEXITCODE"
  }

  Remove-Item Env:AZP_TOKEN -ErrorAction SilentlyContinue
  & .\run.cmd
  $exitCode = $LASTEXITCODE
}
finally {
  if (Test-Path .\.agent) {
    try {
      & .\config.cmd remove --unattended --auth PAT --token $cleanupToken | Out-Null
    }
    catch {
    }
  }
}

exit $exitCode

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

Set-Location C:\runner

if ($env:ACTIONS_RUNNER_INPUT_JITCONFIG) {
  & .\run.cmd
  exit $LASTEXITCODE
}

if (-not $env:GITHUB_URL) {
  throw "GITHUB_URL is required when ACTIONS_RUNNER_INPUT_JITCONFIG is not provided."
}

if (-not $env:GITHUB_TOKEN) {
  throw "GITHUB_TOKEN is required when ACTIONS_RUNNER_INPUT_JITCONFIG is not provided."
}

$runnerName = if ($env:RUNNER_NAME) { $env:RUNNER_NAME } else { $env:COMPUTERNAME }
$runnerWork = if ($env:RUNNER_WORKDIR) { $env:RUNNER_WORKDIR } else { "_work" }

$configArgs = @(
  "--unattended",
  "--url", $env:GITHUB_URL,
  "--token", $env:GITHUB_TOKEN,
  "--name", $runnerName,
  "--work", $runnerWork,
  "--replace"
)

& .\config.cmd @configArgs
if ($LASTEXITCODE -ne 0) {
  throw "Runner configuration failed with exit code $LASTEXITCODE"
}

$exitCode = 1
try {
  & .\run.cmd
  $exitCode = $LASTEXITCODE
} finally {
  if (Test-Path .\.runner) {
    try {
      & .\config.cmd remove --unattended --token $env:GITHUB_TOKEN | Out-Null
    } catch {
    }
  }
}

exit $exitCode

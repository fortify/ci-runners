#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${AZP_URL:-}" ]]; then
  echo "AZP_URL is required"
  exit 1
fi

if [[ -n "${AZP_TOKEN_FILE:-}" ]]; then
  AZP_TOKEN="$(<"${AZP_TOKEN_FILE}")"
elif [[ -z "${AZP_TOKEN:-}" ]]; then
  echo "AZP_TOKEN or AZP_TOKEN_FILE is required"
  exit 1
fi

if [[ -z "${AZP_TOKEN:-}" ]]; then
  echo "Resolved AZP_TOKEN is empty"
  exit 1
fi

AZP_POOL="${AZP_POOL:-Default}"
AZP_AGENT_NAME="${AZP_AGENT_NAME:-$(hostname)}"
AZP_WORK="${AZP_WORK:-_work}"

mkdir -p /azp/agent
cd /azp/agent

cleanup() {
  if [[ -f .agent ]]; then
    ./config.sh remove --unattended --auth PAT --token "${AZP_TOKEN}" || true
  fi
}
trap cleanup EXIT INT TERM

AUTH="$(printf ":%s" "${AZP_TOKEN}" | base64 -w0)"
PKG_URL="$(curl -fsSL -H "Authorization: Basic ${AUTH}" "${AZP_URL%/}/_apis/distributedtask/packages/agent?platform=linux-x64&\$top=1" | jq -r '.value[0].downloadUrl')"

if [[ -z "${PKG_URL}" || "${PKG_URL}" == "null" ]]; then
  echo "Unable to resolve Azure Pipelines agent package URL"
  exit 1
fi

curl -fsSL "${PKG_URL}" -o agent.tar.gz
tar -xzf agent.tar.gz
rm -f agent.tar.gz

./config.sh --unattended \
  --agent "${AZP_AGENT_NAME}" \
  --url "${AZP_URL}" \
  --auth PAT \
  --token "${AZP_TOKEN}" \
  --pool "${AZP_POOL}" \
  --work "${AZP_WORK}" \
  --replace \
  --acceptTeeEula

unset AZP_TOKEN
./run.sh "$@"

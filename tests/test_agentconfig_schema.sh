#!/usr/bin/env bash
# tests/test_agentconfig_schema.sh
# Validates the AgentConfig JSON schema against known-good and known-bad fixtures
# using kubeconform.
#
# Usage:
#   ./tests/test_agentconfig_schema.sh
#
# Requirements:
#   - kubeconform in PATH
#   - Run from the repo root

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEMA_DIR="${REPO_ROOT}/custom-standalone-strict"
FIXTURES_DIR="${REPO_ROOT}/tests/fixtures/agentconfig"

# AgentConfig uses apiVersion: v1beta1 (no group), so kubeconform resolves
# the schema via the {{.ResourceKind}}{{.KindSuffix}} template:
#   agentconfig + -v1beta1 = agentconfig-v1beta1.json
SCHEMA_LOCATION="${SCHEMA_DIR}/{{.ResourceKind}}{{.KindSuffix}}.json"

PASS=0
FAIL=0

_run() {
    local desc="$1"
    local file="$2"
    local expect_valid="$3"   # "valid" or "invalid"

    output=$(kubeconform -strict \
        -schema-location "${SCHEMA_LOCATION}" \
        "${file}" 2>&1) && exit_code=0 || exit_code=$?

    if [[ "${expect_valid}" == "valid" ]]; then
        if [[ ${exit_code} -eq 0 ]]; then
            echo "  PASS  ${desc}"
            PASS=$((PASS + 1))
        else
            echo "  FAIL  ${desc}"
            echo "        expected: valid"
            echo "        got:      ${output}"
            FAIL=$((FAIL + 1))
        fi
    else
        if [[ ${exit_code} -ne 0 ]]; then
            echo "  PASS  ${desc}"
            PASS=$((PASS + 1))
        else
            echo "  FAIL  ${desc}"
            echo "        expected: invalid (non-zero exit)"
            echo "        got:      ${output}"
            FAIL=$((FAIL + 1))
        fi
    fi
}

echo ""
echo "AgentConfig schema tests"
echo "Schema: ${SCHEMA_DIR}/agentconfig-v1beta1.json"
echo "========================================"

echo ""
echo "--- Valid fixtures (should pass) ---"
_run "minimal valid config"                   "${FIXTURES_DIR}/valid-minimal.yaml"            valid
_run "full config with networkConfig/bonds"   "${FIXTURES_DIR}/valid-full.yaml"               valid
_run "real HomeLab okd/agent-config.yaml"     "${REPO_ROOT}/../HomeLab/okd/agent-config.yaml" valid

echo ""
echo "--- Invalid fixtures (should fail) ---"
_run "wrong apiVersion (grouped form)"        "${FIXTURES_DIR}/invalid-wrong-apiversion.yaml" invalid
_run "unknown top-level field"                "${FIXTURES_DIR}/invalid-extra-field.yaml"      invalid
_run "bad MAC address format"                 "${FIXTURES_DIR}/invalid-bad-mac.yaml"          invalid

echo ""
echo "========================================"
echo "Results: ${PASS} passed, ${FAIL} failed"
echo ""

if [[ ${FAIL} -gt 0 ]]; then
    exit 1
fi

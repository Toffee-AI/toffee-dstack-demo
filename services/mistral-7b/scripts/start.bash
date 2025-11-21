#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o noclobber
set -o pipefail

main() {
    local host="${HOST:-0.0.0.0}"
    local port="${PORT:-8080}"
    local model_id="${MODEL_ID:-mistralai/Mistral-7B-Instruct-v0.2}"
    local mem_fraction_static="${MEM_FRACTION_STATIC:-0.90}"
    local context_length="${CONTEXT_LENGTH:-2048}"
    local max_prefill_tokens="${MAX_PREFILL_TOKENS:-16384}"
    local schedule_policy="${SCHEDULE_POLICY:-lpm}"
    local schedule_conservativeness="${SCHEDULE_CONSERVATIVENESS:-0.2}"
    local torch_compile_max_bs="${TORCH_COMPILE_MAX_BS:-32}"
    local enable_torch_compile="${ENABLE_TORCH_COMPILE:-true}"
    local enable_cache_report="${ENABLE_CACHE_REPORT:-true}"
    local disable_chunked_prefix_cache="${DISABLE_CHUNKED_PREFIX_CACHE:-true}"

    echo "Starting SGLang server..."
    echo "Host: ${host}"
    echo "Port: ${port}"
    echo "Model: ${model_id}"
    echo "Memory fraction: ${mem_fraction_static}"
    echo "Context length: ${context_length}"

    local cmd=(
        python3 -m sglang.launch_server
        --enable-metrics
        --model-path "${model_id}"
        --host "${host}"
        --port "${port}"
        --mem-fraction-static "${mem_fraction_static}"
        --context-length "${context_length}"
        --max-prefill-tokens "${max_prefill_tokens}"
        --schedule-policy "${schedule_policy}"
        --schedule-conservativeness "${schedule_conservativeness}"
    )

    if [[ "${enable_torch_compile}" == "true" ]]; then
        cmd+=(--enable-torch-compile)
        cmd+=(--torch-compile-max-bs "${torch_compile_max_bs}")
    fi

    if [[ "${enable_cache_report}" == "true" ]]; then
        cmd+=(--enable-cache-report)
    fi

    if [[ "${disable_chunked_prefix_cache}" == "true" ]]; then
        cmd+=(--disable-chunked-prefix-cache)
    fi

    echo "Executing: ${cmd[*]}"
    exec "${cmd[@]}"
}

main "$@"

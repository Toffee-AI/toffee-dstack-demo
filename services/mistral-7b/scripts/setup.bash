#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o noclobber
set -o pipefail

main() {
    echo "Installing system dependencies..."
    apt-get update
    apt-get install -y jq libnuma1

    echo "Installing uv package manager..."
    local uv_version='0.8.18'
    curl -LsSf "https://astral.sh/uv/${uv_version}/install.sh" | sh
    source "${HOME}/.local/bin/env"

    echo "Installing sglang..."
    local sglang_version='0.5.2'
    uv pip install \
        --system \
        --find-links https://flashinfer.ai/whl/cu124/torch2.5/flashinfer-python \
        "sglang[all]==${sglang_version}" \
        accelerate==1.10.1

    echo "Setup completed successfully."

    return 0
}

main "$@"

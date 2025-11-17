#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

help() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Renders the dstack service configuration by substituting environment variables.

OPTIONS:
    -e, --env-file FILE    Path to .env file (default: .env)
    -o, --output FILE      Output file path (default: stdout)
    -h, --help             Show this help message

EXAMPLES:
    # Render using .env file and output to stdout
    $(basename "$0")

    # Render using custom env file
    $(basename "$0") --env-file .env.production

    # Render and save to file
    $(basename "$0") --output service.yaml

NOTES:
    - If no .env file is found, you must export all required variables manually
    - The script looks for the service.yaml template in the dstack/ directory
    - All undefined variables will be left as-is in the output

EOF
}

main() {
    local env_file=".env"
    local output_file=""

    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--env-file)
                env_file="$2"
                shift 2
                ;;
            -o|--output)
                output_file="$2"
                shift 2
                ;;
            -h|--help)
                help
                return 0
                ;;
            *)
                echo "Error: Unknown option: $1"
                help
                return 1
                ;;
        esac
    done

    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local service_dir
    service_dir="$(cd "${script_dir}/.." && pwd)"
    local project_root
    project_root="$(cd "${service_dir}/../.." && pwd)"
    local template_file="${service_dir}/dstack/template.service.yaml"

    if [[ ! -f "${template_file}" ]]; then
        echo "Error: Template file not found: ${template_file}"
        return 1
    fi

    if [[ -f "${env_file}" ]]; then
        echo "Loading environment variables from: ${env_file}" >&2
        set -o allexport
        source "${env_file}"
        set +o allexport
    elif [[ "${env_file}" != ".env" ]]; then
        echo "Error: Specified env file not found: ${env_file}"
        return 1
    else
        echo "No .env file found. Using existing environment variables." >&2
    fi

    echo "Rendering configuration from: ${template_file}" >&2

    local rendered
    rendered=$(envsubst < "${template_file}")

    if [[ -n "${output_file}" ]]; then
        echo "Writing rendered configuration to: ${output_file}" >&2
        echo "${rendered}" > "${output_file}"
        echo "Configuration rendered successfully!" >&2
    else
        echo "${rendered}"
    fi

    return 0
}

main "$@"

#!/usr/bin/env bash
#
# Run the integration test optionally downloading Bitcoin Core binary if TAPYRUSVERSION is set.

set -euo pipefail

REPO_DIR=$(git rev-parse --show-toplevel)

# Make all cargo invocations verbose.
export CARGO_TERM_VERBOSE=true

main() {
    # If a specific version of Bitcoin Core is set then download the binary.
    if [ -n "${TAPYRUSVERSION+x}" ]; then
        download_binary
    fi

    need_cmd tapyrusd

    cd integration_test
    ./run.sh
}

download_binary() {
    wget https://github.com/chaintope/tapyrus-core/releases/download/v$TAPYRUSVERSION/tapyrus-core-$TAPYRUSVERSION-$ARCH-linux-gnu.tar.gz
    tar -xzvf tapyrus-core-$TAPYRUSVERSION-$ARCH-linux-gnu.tar.gz
    export PATH=$PATH:$(pwd)/tapyrus-core-$TAPYRUSVERSION/bin
}

err() {
    echo "$1" >&2
    exit 1
}

need_cmd() {
    if ! command -v "$1" > /dev/null 2>&1
    then err "need '$1' (command not found)"
    fi
}

#
# Main script
#
main "$@"
exit 0

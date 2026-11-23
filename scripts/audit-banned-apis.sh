#!/usr/bin/env bash
# Fails if any source file uses an API banned by the iPhone Duo layout rules.
# Layout must come from geometry (GeometryProxy, reserved regions, size classes),
# never from screen size, device orientation or interface idiom.
set -euo pipefail

cd "$(dirname "$0")/.."

PATTERN='UIScreen\.main|UIDevice\.current\.orientation|statusBarOrientation|userInterfaceIdiom'
DIRS=(App Features Shared Widgets Core/Sources Core/Tests Tests)

existing=()
for dir in "${DIRS[@]}"; do
    [[ -d "$dir" ]] && existing+=("$dir")
done

if hits=$(grep -rnE "$PATTERN" --include='*.swift' --include='*.m' --include='*.h' --include='*.metal' "${existing[@]}"); then
    echo "Banned API usage found:" >&2
    echo "$hits" >&2
    exit 1
fi

echo "Banned-API audit passed: 0 occurrences of UIScreen.main, UIDevice.current.orientation, statusBarOrientation, userInterfaceIdiom."

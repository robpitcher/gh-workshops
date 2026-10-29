#!/usr/bin/env bash
# Build src/workshops/<slug>/slides.md into <slug>/slides/, matching the upstream deploy layout.
# Usage: src/build-slides.sh <slug>
set -euo pipefail

SLIDEV_VERSION=52.12.0
slug=${1:?usage: src/build-slides.sh <slug>}
root=$(cd "$(dirname "$0")/.." && pwd)
entry="$root/src/workshops/$slug/slides.md"
out="$root/$slug/slides"
cli="$root/.tools/node_modules/.bin/slidev"

[ -f "$entry" ] || { echo "missing $entry" >&2; exit 1; }

# Pinned CLI in a gitignored folder, so repeat builds don't re-download it.
if [ ! -x "$cli" ] || ! "$cli" --version 2>/dev/null | grep -q "$SLIDEV_VERSION"; then
  npm install --prefix "$root/.tools" --no-audit --no-fund "@slidev/cli@$SLIDEV_VERSION"
fi

rm -rf "$out"
(cd "$root/src/workshops/$slug" && "$cli" build slides.md --base "/gh-workshops/$slug/slides/" --out "$out")

# GitHub Pages ignores _redirects, so upstream copies the SPA shell to 1..200 for deep links.
for i in $(seq 1 200); do
  mkdir -p "$out/$i"
  cp "$out/index.html" "$out/$i/index.html"
done

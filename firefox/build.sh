#!/usr/bin/env bash
# Build the Firefox version.
#
# Firefox needs a different manifest (event page instead of service worker,
# blocking webRequest instead of declarativeNetRequest, a gecko extension ID).
# Everything else is shared with the Chrome build.

set -euo pipefail
cd "$(dirname "$0")"

OUT="build"
rm -rf "$OUT"
mkdir -p "$OUT"

# shared files
for f in background.js style.css \
         onboarding.html onboarding.js \
         blocked.html blocked.js \
         options.html options.js \
         popup.html popup.js \
         PRIVACY.md; do
  cp "../$f" "$OUT/"
done

cp -r ../icons "$OUT/"
cp -r ../lib "$OUT/"

# Firefox-specific manifest. No declarative_net_request block and no
# rules_youtube.json — Firefox sets the YouTube header via webRequest instead,
# which background.js feature-detects.
cp manifest.template.json "$OUT/manifest.json"

cp README.md "$OUT/README.md"

echo
echo "  Built Firefox extension in: firefox/$OUT"
echo
echo "  Load it:"
echo "    1. about:debugging#/runtime/this-firefox"
echo "    2. Load Temporary Add-on..."
echo "    3. Pick this exact file:"
echo
echo "         $(pwd)/$OUT/manifest.json"
echo
echo "  IMPORTANT: it must be the manifest.json inside $OUT/ - not the one"
echo "  in the firefox/ folder. That one is only a template and has no code"
echo "  next to it, which fails with \"Loading failed for the script\"."
echo
echo "  Temporary add-ons are removed when Firefox restarts. For a permanent"
echo "  install you need a signed .xpi from addons.mozilla.org, or Firefox"
echo "  Developer Edition with xpinstall.signatures.required set to false."
echo

#!/usr/bin/env bash
# Threshold — lock the browser (Linux)
#
# Uses Chrome's ExtensionSettings policy with force_installed. That removes
# every route to removing Threshold — greyed out on the extensions page AND in
# the toolbar icon's right-click menu — while leaving every other extension
# completely untouched and manageable.
#
# Also forces SafeSearch on and disables private browsing, both of which sit
# below the extension and can't be changed from inside the browser.

set -euo pipefail

# Threshold's Chrome Web Store extension ID. Permanent: assigned when the
# listing was created, and unchanged by updates. This is what the policy
# force-installs and protects from removal.
EXTID="geciepejjdhbcafgbfkfnofjlcaholok"

if [[ $EUID -ne 0 ]]; then
  echo
  echo "  This needs root. Run it with:"
  echo "      sudo bash install-threshold.sh"
  echo
  exit 1
fi

CHROME_DIRS=(
  "/etc/opt/chrome/policies/managed"
  "/etc/chromium/policies/managed"
  "/etc/chromium-browser/policies/managed"
  "/etc/brave/policies/managed"
  "/etc/opt/edge/policies/managed"
  "/etc/opt/vivaldi/policies/managed"
  "/etc/opera/policies/managed"
)

FIREFOX_DIRS=(
  "/etc/firefox/policies"
  "/usr/lib/firefox/distribution"
  "/usr/lib64/firefox/distribution"
  "/opt/firefox/distribution"
)

cat <<'BANNER'

  THRESHOLD - LOCK THE BROWSER
  ============================

  This writes browser policy that:

    * Stops Threshold being removed or disabled - and ONLY Threshold.
      Your other extensions carry on working and stay manageable.
    * Forces Google SafeSearch on, browser-wide
    * Disables private browsing, which otherwise bypasses everything
    * Blocks about:config in Firefox

  None of it can be changed from inside the browser.

  To undo it later, run remove-threshold.sh as root with the code
  Threshold gives you after its cooling-off period.

BANNER

echo
echo "  Filter YouTube? Restricted Mode also disables YouTube comments."
echo "  YouTube isn't a porn site, so most people leave this off."
read -rp "  Turn on YouTube filtering? (y/N): " YT
if [[ "$YT" =~ ^[Yy]$ ]]; then
  YT_POLICY=',
  "ForceYouTubeRestrict": 2'
  echo "  YouTube filtering ON - comments will be unavailable."
else
  YT_POLICY=""
  echo "  YouTube filtering off - comments keep working."
fi

echo
read -rp "  Continue? (y/n): " CONFIRM
[[ "$CONFIRM" =~ ^[Yy]$ ]] || { echo "  Cancelled. Nothing was changed."; exit 0; }

POLICY="{
  \"IncognitoModeAvailability\": 1,
  \"ForceGoogleSafeSearch\": true${YT_POLICY},
  \"ExtensionSettings\": {
    \"${EXTID}\": {
      \"installation_mode\": \"force_installed\",
      \"update_url\": \"https://clients2.google.com/service/update2/crx\",
      \"incognito_mode\": \"enabled\",
      \"toolbar_pin\": \"force_pinned\"
    }
  }
}"

echo
for dir in "${CHROME_DIRS[@]}"; do
  parent="$(dirname "$(dirname "$dir")")"
  if [[ -d "$parent" ]]; then
    mkdir -p "$dir"
    printf '%s\n' "$POLICY" > "$dir/threshold.json"
    chmod 644 "$dir/threshold.json"
    echo "  wrote $dir/threshold.json"
  fi
done

FF_POLICY='{
  "policies": {
    "DisablePrivateBrowsing": true,
    "BlockAboutConfig": true,
    "ExtensionSettings": {
      "threshold@localhost": { "installation_mode": "locked" }
    }
  }
}'

for dir in "${FIREFOX_DIRS[@]}"; do
  parent="$(dirname "$dir")"
  if [[ -d "$parent" ]]; then
    mkdir -p "$dir"
    if [[ -f "$dir/policies.json" ]] && ! grep -q 'DisablePrivateBrowsing' "$dir/policies.json" 2>/dev/null; then
      cp "$dir/policies.json" "$dir/policies.json.threshold-backup"
      echo "  backed up existing $dir/policies.json"
    fi
    printf '%s\n' "$FF_POLICY" > "$dir/policies.json"
    echo "  wrote $dir/policies.json"
  fi
done

cat <<'DONE'

  Done. Now QUIT ALL BROWSERS COMPLETELY and reopen them.
  Closing the window isn't enough - check with: pgrep -a chrome

  Check it worked:
    chrome://policy       the entries should be listed
    chrome://extensions   Threshold's Remove button should be greyed out,
                          and every other extension should still be fine
    Right-click the Threshold icon - Remove should be unavailable

  Private browsing should be gone from the menu.

DONE

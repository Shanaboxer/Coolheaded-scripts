#!/usr/bin/env bash
# CoolHeaded — lock the browser (Linux)
#
# Uses Chrome's ExtensionSettings policy with force_installed. That removes
# every route to removing CoolHeaded — greyed out on the extensions page AND in
# the toolbar icon's right-click menu — while leaving every other extension
# completely untouched and manageable.
#
# Also forces SafeSearch on and disables private browsing, both of which sit
# below the extension and can't be changed from inside the browser.

set -euo pipefail
#
# ON THE REMOVAL CODE
#
# The code is SHA256("coolheaded-removal-" + UTC YYYYMMDDHH), first 8 hex
# characters, uppercased. It changes hourly and the previous hour is also
# accepted, so reading it off the screen near an hour boundary still works.
#
# It is NOT a secret. The algorithm is in this public repository, and it has to
# be in the extension too, because the extension must display the same code
# without contacting any server. Anyone who reads either can compute the current
# code in one line, without waiting out the cooling-off period.
#
# That is a deliberate limit of a free, local-only, no-account tool rather than
# an oversight, and for something self-imposed it may be the right trade. But it
# means this is a pause, not a lock, and nothing here should imply otherwise.
#
# Closing it properly needs an extension change, not a script change: the
# extension would generate a random secret per installation, show it once during
# install, and the install script would store its hash — the way In'Seine's
# removal PIN works. The cooling-off delay would still come from the extension.
#

# CoolHeaded's Chrome Web Store extension ID. Permanent: assigned when the
# listing was created, and unchanged by updates. This is what the policy
# force-installs and protects from removal.
EXTID="geciepejjdhbcafgbfkfnofjlcaholok"

# CoolHeaded's add-on download URL on addons.mozilla.org. SET THIS.
#
# Firefox cannot "lock an extension where it already is" the way Chrome can.
# Its ExtensionSettings policy takes three installation_mode values — allowed,
# blocked and force_installed — and only force_installed prevents removal. It
# REQUIRES install_url, because Firefox fetches the add-on itself.
#
# Earlier versions wrote "installation_mode": "locked", which is not a Firefox
# value at all. Firefox ignored the entry, so the Firefox extension lock this
# script claimed to apply had never once worked.
#
# The "latest" form, not a version-numbered one — Firefox re-fetches on update,
# and a pinned .xpi would strand every locked machine on 0.1.1 forever.
#
# Leave empty and the Firefox extension lock is skipped and SAID to be skipped,
# rather than written in a form that quietly does nothing.
FFURL="https://addons.mozilla.org/firefox/downloads/latest/coolheaded/latest.xpi"

if [[ $EUID -ne 0 ]]; then
  echo
  echo "  This needs root. Run it with:"
  echo "      sudo bash install-coolheaded.sh"
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

  COOLHEADED - LOCK THE BROWSER
  ============================

  ALWAYS APPLIED, to every browser found on this computer, in every account,
  because browser policy is set system-wide:

    * Private browsing disabled. Without it, a private window bypasses
      everything CoolHeaded does.
    * Google SafeSearch forced on in Chrome, Edge and other Chromium
      browsers, below the extension and unchangeable from inside it.
    * about:config blocked in Firefox.

  ALSO APPLIED, where the store details are known:

    * CoolHeaded installed automatically and made impossible to remove or
      disable - and ONLY CoolHeaded. Your other extensions carry on working
      and stay manageable.

  You will be told at the end exactly which browsers that last part reached.
  It needs the extension to be published, because the browser installs it
  FROM the store.

  To undo it later, run remove-coolheaded.sh as root with the code
  CoolHeaded gives you after its cooling-off period.

  This is a pause you choose to keep, not a cage. Someone determined to get
  round it can. The point is the delay between wanting to and being able to.

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
    printf '%s\n' "$POLICY" > "$dir/coolheaded.json"
    chmod 644 "$dir/coolheaded.json"
    echo "  wrote $dir/coolheaded.json"
  fi
done

# "_coolheaded_marker" is not a Firefox policy and Firefox ignores it. It is
# here so remove-coolheaded.sh can recognise a policies.json as ours and know it
# is safe to delete. Without a reliable marker the removal script left the file
# in place and the lock could not be lifted at all — private browsing disabled
# permanently, on a tool whose entire premise is that you can stop using it.
if [[ -n "$FFURL" ]]; then
  FF_EXT=",
    \"ExtensionSettings\": {
      \"threshold@shanaboxer.github.io\": {
        \"installation_mode\": \"force_installed\",
        \"install_url\": \"${FFURL}\"
      }
    }"
else
  FF_EXT=""
fi

# "_coolheaded_marker" is not a Firefox policy and Firefox ignores it. It is
# here so remove-coolheaded.sh can recognise a policies.json as ours and know it
# is safe to delete. Without a reliable marker the removal script left the file
# in place and the lock could not be lifted at all — private browsing disabled
# permanently, on a tool whose entire premise is that you can stop using it.
FF_POLICY="{
  \"policies\": {
    \"DisablePrivateBrowsing\": true,
    \"BlockAboutConfig\": true${FF_EXT}
  },
  \"_coolheaded_marker\": \"written by CoolHeaded install-coolheaded.sh - safe to remove with remove-coolheaded.sh\"
}"

for dir in "${FIREFOX_DIRS[@]}"; do
  parent="$(dirname "$dir")"
  if [[ -d "$parent" ]]; then
    mkdir -p "$dir"
    if [[ -f "$dir/policies.json" ]] && ! grep -q '_coolheaded_marker\|threshold@shanaboxer' "$dir/policies.json" 2>/dev/null; then
      cp "$dir/policies.json" "$dir/policies.json.coolheaded-backup"
      echo "  backed up existing $dir/policies.json"
    fi
    printf '%s\n' "$FF_POLICY" > "$dir/policies.json"
    echo "  wrote $dir/policies.json"
  fi
done

echo
echo "  Done. Now QUIT ALL BROWSERS COMPLETELY and reopen them."
echo "  Closing the window isn't enough - check with: pgrep -a chrome"
echo
echo "  APPLIED EVERYWHERE, in every account on this computer:"
echo "    * Private browsing disabled"
echo "    * Google SafeSearch forced on in Chromium browsers"
echo "    * about:config blocked in Firefox"
if [[ -n "$YT_POLICY" ]]; then
  echo "    * YouTube Restricted Mode"
fi
echo
echo "  CHROME / EDGE: CoolHeaded installs itself and cannot be removed."
echo

if [[ -n "$FFURL" ]]; then
  echo "  FIREFOX: CoolHeaded installs itself and cannot be removed."
else
  echo "  FIREFOX: NOT installed or locked. Private browsing and about:config"
  echo "  are still blocked there, but CoolHeaded itself can be removed."
  echo "  (FFURL is unset at the top of this script.)"
fi

cat <<'DONE'

  Check it worked:
    chrome://policy       the entries should be listed
    chrome://extensions   CoolHeaded's Remove button should be greyed out,
                          and every other extension should still be fine
    about:policies        the Firefox equivalent

  Private browsing should be gone from the menu in both.

  Worth doing NOW rather than when you need it: run remove-coolheaded.sh
  once with the current code, check it works, then run this again.

DONE

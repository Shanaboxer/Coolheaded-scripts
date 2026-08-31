#!/usr/bin/env bash
# CoolHeaded — remove protection (Linux)

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

if [[ $EUID -ne 0 ]]; then
  echo
  echo "  This needs root. Run it with:"
  echo "      sudo ./remove-coolheaded.sh"
  echo
  exit 1
fi

cat <<'BANNER'

  COOLHEADED - REMOVING PROTECTION
  ==============================

  To remove CoolHeaded you need the removal code.

  Get it by opening CoolHeaded's settings in your browser, clicking
  "Start removal", and waiting out the cooling-off period. The code
  appears at the end of it.

  If you don't have a code yet, close this and go and do that first.
  Cancelling costs nothing.

  The wait is the whole point. Nothing here can stop you working around it -
  only you can decide the pause was worth keeping.

BANNER

read -rp "  Removal code: " CODE
CODE=$(echo "$CODE" | tr -d '[:space:]' | tr 'a-f' 'A-F')

# Accept the current hour and the previous one, so an hour boundary can't
# invalidate a code you just read off the screen.
VALID=0
for offset in 0 1; do
  STAMP=$(date -u -d "-${offset} hour" +%Y%m%d%H 2>/dev/null || date -u -v-${offset}H +%Y%m%d%H)
  EXPECT=$(printf '%s' "coolheaded-removal-${STAMP}" | sha256sum | cut -c1-8 | tr 'a-f' 'A-F')
  [[ "$CODE" == "$EXPECT" ]] && VALID=1
done

if [[ $VALID -ne 1 ]]; then
  echo
  echo "  That code isn't right, or it has expired."
  echo "  Codes last one hour. Open CoolHeaded's settings and read the current one."
  echo
  exit 1
fi

echo
echo "  Code accepted. Removing policy..."

REMOVED=0
for dir in \
  "/etc/opt/chrome/policies/managed" \
  "/etc/chromium/policies/managed" \
  "/etc/chromium-browser/policies/managed" \
  "/etc/brave/policies/managed" \
  "/etc/opt/edge/policies/managed" \
  "/etc/vivaldi/policies/managed" "/etc/opt/vivaldi/policies/managed" \
  "/etc/opera/policies/managed"
do
  if [[ -f "$dir/coolheaded.json" ]]; then
    rm -f "$dir/coolheaded.json"
    echo "  removed $dir/coolheaded.json"
    REMOVED=$((REMOVED+1))
  fi
done

# Firefox: restore the backup if we made one, otherwise remove our file.
for dir in "/etc/firefox/policies" "/usr/lib/firefox/distribution" \
           "/usr/lib64/firefox/distribution" "/opt/firefox/distribution"; do
  if [[ -f "$dir/policies.json.coolheaded-backup" ]]; then
    mv "$dir/policies.json.coolheaded-backup" "$dir/policies.json"
    echo "  restored previous $dir/policies.json"
    REMOVED=$((REMOVED+1))
  # Recognise the file we wrote. This looked for "BlockAboutAddons", which
  # install-coolheaded.sh has never written — so on any machine with no
  # pre-existing policies.json there was no backup to restore AND no match here,
  # and the Firefox lock could not be lifted at all.
  elif [[ -f "$dir/policies.json" ]] && \
       grep -q '_coolheaded_marker\|threshold@shanaboxer\|BlockAboutAddons' \
            "$dir/policies.json" 2>/dev/null; then
    rm -f "$dir/policies.json"
    echo "  removed $dir/policies.json"
    REMOVED=$((REMOVED+1))
  fi
done

[[ $REMOVED -eq 0 ]] && echo "  Nothing to remove - no policy files found."

cat <<'DONE'

  Policy removed. QUIT THE BROWSER COMPLETELY and reopen it.

  The extensions page will work again, and you can remove the CoolHeaded
  extension from there in the normal way.

  If you want it back later, run install-coolheaded.sh as root.

DONE

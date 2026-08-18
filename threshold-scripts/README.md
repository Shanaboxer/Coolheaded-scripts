# Threshold — browser lock scripts

Optional setup scripts for the Threshold browser extension. **You don't need
these for Threshold to work.** They add a layer the extension can't provide on
its own.

Everything here is plain text. Nothing is compiled or obfuscated. You're asked
to run these with administrator rights, so read them first — that's exactly why
they're published.

---

## Why these exist

A browser extension cannot stop itself being removed. Anyone can open the
browser's extensions page and delete it in two clicks. That's deliberate on the
browser's part: you should always have the final say over what runs in your own
browser.

Which is fine, until the moment you'd rather your earlier self had made the
decision. These scripts put a real obstacle in that path, using **browser
policy** — the same mechanism schools and companies use to manage their
computers. Policy lives outside the browser, so the browser obeys it and won't
let anyone change it from the inside.

## What they do

| Setting | Effect |
|---|---|
| `ExtensionSettings` (force install) | Threshold can't be removed or disabled — not from the extensions page, not from the toolbar icon's menu. **Only Threshold is affected.** Every other extension you have carries on as normal and stays fully manageable. |
| `IncognitoModeAvailability` | Private browsing disabled. Otherwise it's a one-click way around everything. |
| `ForceGoogleSafeSearch` | Google SafeSearch forced on browser-wide, whatever your account settings say |
| `ForceYouTubeRestrict` | *Optional, off by default.* YouTube restricted mode. Note this also turns off YouTube comments — that's YouTube's behaviour, not something that can be separated. |
| `BlockAboutConfig` | *(Firefox)* stops the underlying settings being edited to get round the above |

## What they do NOT do

- No network requests. None at all.
- No information about you is collected, read, or transmitted.
- No file outside the locations listed below is touched.
- No other software is installed, downloaded, or run.
- Nothing about your computer changes beyond browser settings.

---

## Exactly what gets written, and where

**Linux** — one JSON file per browser found:

```
/etc/opt/chrome/policies/managed/threshold.json
/etc/chromium/policies/managed/threshold.json
/etc/chromium-browser/policies/managed/threshold.json
/etc/brave/policies/managed/threshold.json
/etc/opt/edge/policies/managed/threshold.json
/etc/opt/vivaldi/policies/managed/threshold.json
/etc/opera/policies/managed/threshold.json
/etc/firefox/policies/policies.json
```

**Windows** — registry values under:

```
HKLM\SOFTWARE\Policies\Google\Chrome
HKLM\SOFTWARE\Policies\Microsoft\Edge
HKLM\SOFTWARE\Policies\Mozilla\Firefox
```

That's the complete list. Nothing else on your system is touched.

If Firefox already has a `policies.json`, the script backs it up alongside
before writing, and restores it when you remove the lock.

---

## Why administrator rights are needed

Policy settings are machine-wide by design. That's the point — a setting you
could change from inside the browser would be no use as a lock. Writing to
`/etc` on Linux or `HKLM` on Windows requires administrator rights.

If you're not comfortable running something with those rights, that's a
perfectly reasonable position, and you should skip this. Threshold still blocks
sites, still forces SafeSearch, and still holds the gate. You'd be missing the
removal protection and the private-browsing block, not the product.

---

## Before you start

You need **Threshold installed from the Chrome Web Store**, not loaded from a
folder. The lock works by telling Chrome to force-install a specific extension,
and Chrome verifies that against the store.

---

## Running them

**Always use `bash script.sh`, never `./script.sh`.** Downloading a zip strips
the Unix executable bit, so `./` gives *Permission denied*, and `sudo ./` then
reports a confusing *command not found*.

### Linux

```bash
cd linux
sudo bash install-threshold.sh
```

### Windows

Right-click `windows\install-threshold.bat` → **Run as administrator**.

### Then

Quit every browser completely and reopen. Closing the window isn't enough — on
Linux, check with `pgrep -a chrome` and kill anything left.

### Check it worked

- `chrome://policy` — the entries should be listed
- `chrome://extensions` — Threshold's Remove greyed out, everything else normal
- Right-click the Threshold icon — no Remove option
- Private browsing gone from the menu

---

## Undoing it

1. Open Threshold's settings and click **Start removal**
2. Wait out the 30-minute cooling-off. You can cancel at any point, free, and
   nothing is recorded.
3. Click **Show removal code**
4. Run the removal script and enter it:

```bash
cd linux
sudo bash remove-threshold.sh
```

On Windows, right-click `windows\remove-threshold.bat` → Run as administrator.

The code is derived from the current hour, so it can't be written down in
advance and kept in your pocket. The script accepts the current hour and the
previous one, so an hour boundary can't strand you mid-flow.

### If you're locked out or something's gone wrong

There's always a way out, needing no code and no waiting.

**Linux:**
```bash
sudo rm -f /etc/opt/chrome/policies/managed/threshold.json
sudo rm -f /etc/chromium/policies/managed/threshold.json
sudo rm -f /etc/firefox/policies/policies.json
```

**Windows** — open `regedit` as Administrator and delete:
```
HKLM\SOFTWARE\Policies\Google\Chrome
HKLM\SOFTWARE\Policies\Microsoft\Edge
HKLM\SOFTWARE\Policies\Mozilla\Firefox
```

Restart the browser afterwards. Everything returns to normal.

This route is documented deliberately. Threshold is a threshold, not a cage,
and nobody should ever be genuinely trapped by it.

---

## Honest limits

**Anyone with administrator access can undo all of this**, using the commands
directly above. That's true of every tool of this kind, and no software running
on a computer you control can change it.

What these scripts buy you is the difference between *two clicks* and *a
deliberate act at an administrator prompt*. For a tool whose whole purpose is
putting a pause between an impulse and an action, that gap is the entire point.

**Force-install requires the Web Store version.** A copy loaded from a folder
has a different extension ID and can't be force-installed.

**Windows and Linux only.** macOS uses configuration profiles and isn't
supported.

---

## Licence

See LICENSE.txt. You may read, audit, and run these. You may not redistribute
or sell them.

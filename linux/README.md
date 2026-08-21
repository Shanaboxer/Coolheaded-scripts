# CoolHeaded — Linux protection layer

The extension alone can be removed in two clicks from `chrome://extensions`.
No browser extension can prevent that. This folder fixes it using Chrome
**managed policy**, which on Linux is a JSON file in `/etc`.

## Install

1. Install the CoolHeaded extension first (Load unpacked).
2. In a terminal:

   ```bash
   cd linux
   sudo bash install-coolheaded.sh
   ```

   **Use `bash install-coolheaded.sh`, not `./install-coolheaded.sh`.** Unzipping
   usually strips the executable bit, so `./` gives `Permission denied` —
   and `sudo ./install-coolheaded.sh` then reports the confusing
   `command not found`. Running it through `bash` avoids both.

3. Leave the extension ID blank while testing locally.
4. **Quit the browser completely** and reopen it. Closing the window is not
   enough — check with `pgrep -a chrome` and kill anything left.

Verify: `chrome://policy` should list the entries. `chrome://extensions`
should refuse to load.

## What it does

| Setting | Effect | Undoable from the browser? |
|---|---|---|
| `ExtensionSettings` force_installed | CoolHeaded can't be removed or disabled — anywhere, including the toolbar icon menu. Other extensions unaffected. | No |
| `ForceGoogleSafeSearch` | SafeSearch forced on browser-wide | No |
| `ForceYouTubeRestrict: 2` | YouTube locked to strict mode | No |
| `IncognitoModeAvailability: 1` | Incognito disabled | No |
| `ExtensionInstallForcelist` *(optional)* | Remove button greyed out entirely | No |

The script writes to whichever of these exist:

```
/etc/opt/chrome/policies/managed/coolheaded.json        Google Chrome
/etc/chromium/policies/managed/coolheaded.json          Chromium
/etc/chromium-browser/policies/managed/coolheaded.json  Chromium (older)
/etc/brave/policies/managed/coolheaded.json             Brave
/etc/opt/edge/policies/managed/coolheaded.json          Edge
/etc/opt/vivaldi/policies/managed/coolheaded.json       Vivaldi
/etc/opera/policies/managed/coolheaded.json             Opera
```

## Removing it

1. CoolHeaded settings → **Start removal**
2. Wait out the 30-minute cooling-off. Cancel any time, free.
3. **Show removal code**
4. `sudo bash remove-coolheaded.sh`, enter the code
5. Quit and reopen the browser

The code is derived from the current UTC hour and isn't stored anywhere, so it
can't be written down in advance. The script accepts the current hour and the
previous one so a boundary can't catch you out.

## Honest limitations

**Root can always undo this.** `sudo rm /etc/opt/chrome/policies/managed/coolheaded.json`
and it's gone. On your own machine you have root. This turns two clicks into a
deliberate act at a terminal — that's the gap between an impulse and a decision.
It is friction, not a cage, and anything claiming otherwise is lying to you.

**The removal code is friction, not security.** The salt is in the source,
which is public on purpose. Someone determined can compute it. What it stops is
running the uninstaller *without sitting out the wait* — the honest path.

**If you want this to properly hold:** browse from a user account that isn't in
`sudo`/`wheel`. Then the policy can't be touched from the account you use, and
the root password lives somewhere inconvenient. That's the real version.

**Blocking the extensions page blocks it for everything** — you won't be able
to manage your other extensions while this is on.

**Firefox is not covered.** It uses its own `policies.json` and the extension
itself needs porting.

## If something goes wrong

```bash
sudo rm -f /etc/*/policies/managed/coolheaded.json \
           /etc/opt/*/policies/managed/coolheaded.json
```

Then restart the browser. Nothing else on your system is touched.

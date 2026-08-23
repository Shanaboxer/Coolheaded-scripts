# CoolHeaded — Windows protection layer

The extension on its own can be removed in two clicks from `chrome://extensions`.
That is a hard limit of browser extensions and no extension can get round it.

This folder fixes that using Chrome and Edge **policy**, the same mechanism
schools and companies use. It is the only way to make a browser-based blocker
hold.

## Install

1. Install the CoolHeaded extension first (Load unpacked, or from the Web Store).
2. Right-click **install-coolheaded.bat** → **Run as administrator**.
3. Read what it's about to do, type `y`.
4. **Close Chrome completely** and reopen it.

Check it worked: go to `chrome://policy` and you should see the entries. Then
try `chrome://extensions` — it should refuse to load.

## What it actually does

| Setting | Effect | Can the user undo it in the browser? |
|---|---|---|
| `URLBlocklist` on `chrome://extensions` | The extensions page won't open, so CoolHeaded can't be removed or disabled from it | No |
| `ForceGoogleSafeSearch` | Google SafeSearch forced on, browser-wide | No |
| `ForceYouTubeRestrict` *(optional, off by default)* | YouTube strict mode — **also disables YouTube comments** | No |
| `ForceBingSafeSearch` (Edge) | Bing SafeSearch forced to strict | No |
| `IncognitoModeAvailability` | Incognito disabled — otherwise it's the obvious way round everything | No |
| `ExtensionInstallForcelist` *(optional)* | Chrome greys out **Remove** on the extension entirely | No |

The SafeSearch and incognito policies are worth having on their own. They work
at the browser level, below the extension, and they hold even if the extension
itself is somehow disabled.

## The force-install option

`ExtensionInstallForcelist` is the strongest setting — Chrome physically greys
out the Remove button. 



## Removing it

By design, this can't be undone in a hurry:

1. Open CoolHeaded's settings in the browser → **Start removal**.
2. Wait out the 30-minute cooling-off period. Cancel any time, free.
3. When it finishes, click **Show removal code**.
4. Right-click **remove-coolheaded.bat** → **Run as administrator**, enter the code.
5. Close Chrome and reopen. The extensions page works again and you can remove
   the extension normally.

The code is derived from the current hour, so it expires after an hour and you
can't write it down in advance and keep it in your pocket.

## Honest limitations — read these

**An administrator can always undo this.** Anyone who can open regedit as admin
can delete `HKLM\SOFTWARE\Policies\Google\Chrome` and be done in a minute. If
you're the only user of your PC, you are that administrator. No software on a
machine you control can beat that, and anything claiming otherwise is lying.

What this buys you is the difference between **two clicks** and **elevating to
admin and editing the registry**. That's the whole point: the gap between an
impulse and a deliberate act. It is friction, not a cage.

**The removal code is friction, not security.** The salt is in the source code,
which is public on purpose. Someone determined can compute the code themselves.
What it prevents is running the uninstaller *without first sitting out the
cooling-off period* — which is the honest path, and the one that matters.

**Blocking `chrome://extensions` blocks it for everything.** You won't be able
to manage your other extensions while this is on. That's genuine collateral
friction and you should decide whether it's worth it.

**Standard-user accounts are much stronger.** If you set up a second Windows
account without admin rights and browse from that one, the policy can't be
removed from it at all. That's the real answer if you want this to properly
hold — the admin password lives with someone else, or somewhere inconvenient.

**This is Windows only.** macOS uses configuration profiles and plists instead;
Linux uses JSON policy files. Same idea, different mechanism.

## If something goes wrong

Everything lives under two registry keys:

```
HKLM\SOFTWARE\Policies\Google\Chrome
HKLM\SOFTWARE\Policies\Microsoft\Edge
```

Delete those and Chrome and Edge return to normal on next restart. Nothing else
on your system is touched.

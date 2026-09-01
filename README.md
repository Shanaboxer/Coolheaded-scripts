# CoolHeaded — browser lockdown scripts

CoolHeaded (the extension) can't stop two things on its own: a private window,
which bypasses it completely, and removing the extension itself, which takes
two clicks. No browser extension can fix either of those — the fix has to
happen one level down, in the browser's own policy settings, which normally
only IT departments and schools touch.

These scripts do that. They're free, they need administrator rights (that's
the only place these settings live), and they're plain text on purpose — read
them before you run them. You don't have to edit anything in them; the
extension ID and Firefox download link are already filled in and point at the
real, published CoolHeaded.

**Install CoolHeaded itself first**, from the [Chrome Web
Store](https://chromewebstore.google.com/detail/coolheaded/geciepejjdhbcafgbfkfnofjlcaholok)
or [addons.mozilla.org](https://addons.mozilla.org/firefox/addon/coolheaded/).
These scripts are the optional second step, not a replacement for it.

## Get the scripts

Click the green **Code** button near the top of this page → **Download ZIP**
— or, if you use git:

```
git clone https://github.com/Shanaboxer/Coolheaded-scripts.git
```

Unzip it somewhere you'll remember. You'll see three folders: `linux`,
`windows`, and `firefox` (that last one is for building CoolHeaded itself for
Firefox from source — most people don't need it, since Firefox users should
just install from addons.mozilla.org above).

## What "locking it down" actually does

Everything below applies **to every browser and every user account on the
computer at once** — this is a machine-wide setting, not a per-browser or
per-profile one. You only run it once, as administrator, and it covers
whoever else uses the computer too.

Always applied, regardless of which store details you have:

- Private browsing switched off, in every Chromium browser and Firefox
- SafeSearch forced on, underneath the extension, unchangeable from inside
  the browser
- `about:config` blocked in Firefox

Applied on top of that, once CoolHeaded is properly published (it already is,
so this applies to you):

- CoolHeaded itself can't be removed or disabled — not from the extensions
  page, not from the toolbar icon's own menu. Every other extension you have
  is left completely alone and still manageable normally.

You'll be told exactly which of this actually took effect at the end — if a
browser you have isn't covered for some reason, the script says so rather
than staying quiet about it.

---

## Linux

**1. Open a terminal in the `linux` folder and run:**

```bash
cd linux
sudo bash install-coolheaded.sh
```

Use `bash install-coolheaded.sh`, **not** `./install-coolheaded.sh` —
downloading and unzipping usually strips the executable permission, so `./`
fails with *Permission denied*. Running it through `bash` sidesteps that
entirely.

**2. It'll ask two questions:**

- Whether to turn on YouTube's Restricted Mode. This also switches off
  YouTube comments as a side effect, so most people leave it off — it's there
  for anyone who wants it, not a default recommendation.
- Whether to continue, after showing you exactly what it's about to do.

**3. When it finishes, quit every browser completely and reopen it.** Closing
the window isn't enough while the process is still running in the background
— check with `pgrep -a chrome` if you're not sure, and close anything that's
still there.

**Check it worked:**

- `chrome://policy` should list the new entries
- `chrome://extensions` — CoolHeaded's Remove button should be greyed out;
  every other extension should be untouched
- `about:policies` is the Firefox equivalent

**Browsers covered:** Chrome, Chromium, Brave, Edge, Vivaldi, Opera, and
Firefox — all locked, all at once. If you've installed any of these as a
**Flatpak or Snap package**, the script will tell you at the end — that
packaging format sandboxes its own settings folder, so nothing run on the
host system can reach inside it. CoolHeaded still filters normally there;
what's missing is the removal-lock and private browsing being switched off in
that specific copy. The fix is installing the regular `.deb`/`.rpm` version
instead, if that matters to you.

---

## Windows

**1. In the `windows` folder, right-click `install-coolheaded.bat` → Run as
administrator.**

**2. It'll ask the same two questions as Linux** — YouTube Restricted Mode
(off by default, disables comments if you turn it on), then a final
confirmation before it changes anything.

**3. When it finishes, close every browser completely and reopen it.**

**Check it worked:**

- `chrome://policy` should list the new entries
- `chrome://extensions` — CoolHeaded's Remove button greyed out, everything
  else normal
- Right-click the CoolHeaded toolbar icon — Remove should be unavailable
  there too

**Browsers covered:** Chrome, Edge, Brave, Chromium, Vivaldi, Opera, and
Firefox, all in one run.

---

## Removing it

By design, this is deliberately not quick — that's the entire point of the
tool. You can't skip the wait by reading ahead; the code genuinely doesn't
exist until you've sat through it.

1. Open CoolHeaded's own settings page in the browser → **Start removal**.
2. Wait out the 30-minute cooling-off period. You can cancel at any point
   during the wait, for free, with nothing recorded.
3. When it ends, click **Show removal code**.
4. Run the matching script for your system, and enter the code when it asks:
   - **Linux:** `sudo bash remove-coolheaded.sh`
   - **Windows:** right-click `remove-coolheaded.bat` → Run as administrator
5. Close the browser completely and reopen it. The extensions page works
   normally again, and you can remove the CoolHeaded extension itself the
   usual way, if you want to.

**The code changes every hour** and isn't stored anywhere — it's calculated
fresh from the current time, so there's nothing to write down in advance or
find lying around. It also accepts the *previous* hour as well as the current
one, so reading it off the screen right as the hour ticks over still works.

If you want CoolHeaded back later, just run the install script again.

---

## Honest limitations — read these before you rely on it

**Whoever has administrator rights on the computer can always undo this.**
On Linux, `sudo rm` on the policy file in `/etc` removes it in one line. On
Windows, deleting the relevant key under
`HKLM\SOFTWARE\Policies` in the registry does the same. If you're the only
user of your own computer, you are that administrator, and no script — this
one included — can protect you from yourself. What this buys is the gap
between an *impulse* (two clicks) and a *deliberate act* (opening a terminal
or regedit as admin and doing it on purpose). That gap is the whole idea.
Anyone telling you a browser-level tool is unbeatable is not being straight
with you.

**The removal code is friction, not a secret.** The way it's calculated is
right there in the script you're reading, in plain text, on purpose — and it
has to be, because the extension needs to compute and display the identical
code without ever talking to a server. Someone who reads either the script or
the extension's source can work out the current code without waiting.
That's a deliberate trade for a tool that's free, local-only, and needs no
account — not an oversight. What it actually stops is running the remover
*without* sitting out the wait first, which is the only path that's meant to
be easy.

**If you want this to genuinely hold, the real answer isn't a stronger
script — it's a standard account.** Set up a second account on the computer
without administrator rights, and browse from that one. The policy can't be
touched from an account that isn't an admin at all, and the admin password
can live somewhere less immediately reachable than your own head. That's the
version of this that actually resists you in a bad moment, rather than just
slowing you down.

**macOS isn't supported.** The extension itself still filters normally on a
Mac, but these scripts don't — macOS uses configuration profiles rather than
the policy files Windows and Linux use, and porting that hasn't been done.

---

## If something goes wrong

Everything these scripts write can be removed by hand, without the removal
code, if you're already at an administrator prompt:

**Linux:**
```bash
sudo rm -f /etc/*/policies/managed/coolheaded.json \
           /etc/opt/*/policies/managed/coolheaded.json
sudo rm -f /etc/firefox/policies/policies.json
```

**Windows:** delete these two registry keys, then restart the browser:
```
HKLM\SOFTWARE\Policies\Google\Chrome
HKLM\SOFTWARE\Policies\Microsoft\Edge
```

Either way, nothing else on your system is touched — these scripts only ever
write to the specific policy locations listed above.

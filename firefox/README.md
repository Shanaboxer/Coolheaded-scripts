# CoolHeaded — Firefox

**Installing it? See [../INSTALL.md](../INSTALL.md#firefox) for the full
walkthrough.** This file covers what's different about the Firefox build.

Same extension, different plumbing. Firefox needs its own manifest because it
uses an event-page background script rather than a service worker, and blocking
`webRequest` rather than `declarativeNetRequest`.

## Build and load

```bash
cd firefox
bash build.sh
```

**Use `bash build.sh`, not `./build.sh`.** Zip files don't reliably preserve
Unix permissions, so the script usually arrives without its executable bit and
`./build.sh` gives you `Permission denied`. Running it with `bash` sidesteps
that entirely. (`chmod +x build.sh` then `./build.sh` also works, if you prefer.)

Then in Firefox:

1. `about:debugging#/runtime/this-firefox`
2. **Load Temporary Add-on…**
3. Select `firefox/build/manifest.json` — **the one inside `build/`**, not
   `firefox/manifest.template.json`, which is only a template with no code
   beside it

## The catch: temporary add-ons don't survive a restart

Firefox will only permanently install **signed** extensions. Three options:

**For testing** — load it temporarily as above. Fine for your fortnight, but
you'll re-load it after every Firefox restart.

**For yourself, permanently** — Firefox Developer Edition or Nightly, with
`xpinstall.signatures.required` set to `false` in `about:config`. Note that the
policy script blocks `about:config`, so do this *before* running it.

**For distribution** — submit to addons.mozilla.org. Free, no developer fee
(unlike Chrome's $5), and they'll sign it. This is the real answer if you
publish.

## What Firefox does better

Firefox kept blocking `webRequest`, which Chrome removed in MV3. So on Firefox,
CoolHeaded enforces YouTube restricted mode with a real request header rather
than a declarative rule — more reliable. `background.js` feature-detects this,
so the same file works on both.

Firefox policy is also stronger for our purposes:

| Policy | Effect |
|---|---|
| `DisablePrivateBrowsing` | Private windows removed entirely |
| `BlockAboutAddons` | `about:addons` won't open, so the extension can't be removed from the UI |
| `BlockAboutConfig` | `about:config` blocked, so the underlying prefs can't be edited round it |

Chrome has no direct equivalent of `BlockAboutAddons` — we approximate it with
`URLBlocklist`. Firefox's is a first-class policy.

## Policy install

The same scripts cover Firefox — no separate step:

```bash
sudo ../linux/install-coolheaded.sh
```

On Windows, `windows\install-coolheaded.bat` as administrator.

Check it worked at `about:policies`.

## Known wrinkles

**Snap Firefox** (default on Ubuntu) reads policy from
`/etc/firefox/policies/policies.json` on recent versions, but confinement has
caused problems historically. If policy doesn't apply, check `about:policies`
and consider the `.deb` or tarball build instead.

**policies.json is shared.** Firefox keeps *all* enterprise policy in one file,
so the installer backs up any existing `policies.json` before writing, and the
remover restores it. If you already use Firefox policies for something else,
check the merge by hand.

**Firefox's SafeSearch story is weaker.** There's no `ForceGoogleSafeSearch`
equivalent, so on Firefox that enforcement comes from the extension's URL
rewriting only — which still works, but sits above the browser rather than
below it.

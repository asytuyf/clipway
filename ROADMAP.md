# Roadmap

Each phase produces something usable on its own, so the project is never stuck half-built.

| Phase | Goal | Result |
|:-:|---|---|
| **0** | Groundwork | Universal Clipboard fixed, Tailscale on all devices, dev setup ready |
| **1** | Windows clipboard manager | A better `Win + V` |
| **2** | macOS app | The same app on the Mac |
| **3** | Sync over Tailscale | Mac ⇄ Windows, anywhere |
| **4** | iPhone | iPhone ⇄ Mac ⇄ Windows |
| **5** | Polish and release | Installers, auto-updates, and a landing page |

---

## Phase 0: Groundwork

The goal is to prove the risky parts work before building on top of them.

- [ ] **Fix Universal Clipboard between the Mac and iPhone**
  - Check that both devices use the same Apple ID and have Wi-Fi and Bluetooth on
  - Turn Handoff off and back on: on the Mac under *System Settings → General → AirDrop & Handoff*, on the iPhone under *Settings → General → AirPlay & Continuity*
  - Look for dotfiles or Homebrew tools that changed `defaults`, especially anything touching the pasteboard or Handoff
  - If nothing else works, sign out of iCloud and back in on the Mac
- [ ] **Spike: can a Mac app see items from Universal Clipboard?** Write a tiny script that watches the Mac pasteboard, copy on the iPhone, and check that the script sees it.
- [ ] **Spike: does the reverse direction work?** When a program writes to the Mac pasteboard, can the iPhone paste it?
- [ ] Install Tailscale on Windows, Mac, and iPhone, and check that each device can ping the others
- [ ] Install Rust, Node.js, and the Tauri prerequisites on Windows
- [ ] Create the Tauri 2 + React + TypeScript project

> The two spikes decide whether the iPhone plan in Phase 4 works. Do them first.

## Phase 1: Windows clipboard manager

The goal is a clipboard manager good enough to use every day, even with no sync.

**Core**
- [ ] Background app with a system tray icon that starts at login
- [ ] Clipboard watcher that captures text, links, and images
- [ ] SQLite database for history (content, type, source app, timestamp)
- [ ] Images stored as files on disk with thumbnails, and only their paths kept in the database
- [ ] Duplicates bumped to the top instead of saved twice
- [ ] History limit (for example the last 1,000 items or 30 days, adjustable)

**Popup**
- [ ] Global shortcut (`Ctrl + Shift + V`) opens the popup near the cursor
- [ ] Search that filters as you type
- [ ] Arrow keys to move, `Enter` to paste into the previous app, `Esc` to close
- [ ] Previews for each type: text snippet, image thumbnail, color swatch
- [ ] Pin and delete items

**Privacy**
- [ ] Ignore content marked as sensitive (Windows: `ExcludeClipboardContentFromMonitorProcessing`)
- [ ] App blocklist (for example password managers)
- [ ] "Pause capture" toggle in the tray

## Phase 2: macOS app

The goal is the same app, built from the same code, working on the Mac.

- [ ] Build and run the app on macOS
- [ ] Menu bar icon instead of a tray icon
- [ ] Shortcut `Cmd + Shift + V`
- [ ] Ask for Accessibility permission, which is needed to paste into other apps
- [ ] Ignore concealed content (`org.nspasteboard.ConcealedType`, the marker password managers use)
- [ ] Respect light and dark mode on both platforms

## Phase 3: Sync over Tailscale

The goal is that copying on one computer makes the item show up on the other, even when you're away from home.

- [ ] Small local server inside each app, reachable only through Tailscale
- [ ] Pairing: link devices once with a shared secret, and reject everything else
- [ ] Send new items to paired devices as they're copied
- [ ] **Echo prevention**: each item gets a unique ID and an origin device, so synced items are never sent back (otherwise you get an endless loop)
- [ ] Outbox: items copied while a device is offline are sent when it reconnects
- [ ] Size limits and compression for large images
- [ ] Sync settings: on/off per device and per content type

## Phase 4: iPhone

The goal is to get the iPhone into the loop without keyboard tricks or constant paste prompts.

**Main route: the Mac as a bridge**
- [ ] Clipway on the Mac picks up items arriving from the iPhone through Universal Clipboard and forwards them to Windows
- [ ] Items from Windows are written to the Mac's clipboard, where Universal Clipboard passes them to the iPhone
- [ ] Mark bridged items so they aren't forwarded twice

> Limits: the Mac has to be nearby and awake, and Universal Clipboard items expire after about 2 minutes.

**Fallback: Shortcuts + Back Tap (for when the Mac isn't around)**
- [ ] "Send" Shortcut: double back tap sends the iPhone clipboard to Clipway over Tailscale
- [ ] "Receive" Shortcut: triple back tap fetches the latest item and copies it
- [ ] Shareable Shortcut links and a setup guide in `docs/`

## Phase 5: Polish and release

- [ ] Themes, animations, and a settings window
- [ ] Windows installer and macOS `.dmg` through GitHub Releases
- [ ] Auto-updates
- [ ] Screenshots and a demo GIF in the README
- [ ] Landing page on GitHub Pages

---

## Ideas for later

- File and rich-text (formatted) support
- Text recognition (OCR) on copied images
- Snippets with placeholders (`{date}`, `{clipboard}`)
- Android app
- Native iOS app, if the $99/year Apple developer fee ever makes sense

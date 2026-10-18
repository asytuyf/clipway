# Roadmap

Each phase produces something usable on its own, so the project is never stuck half-built.

| Phase | Goal | Result |
|:-:|---|---|
| **0** | Groundwork | Universal Clipboard fixed, the risky parts tested, Tailscale on all devices |
| **1** | Windows app | A better `Win + V` with a 24-hour history |
| **2** | Mac agent and sync | Copy on the Mac or iPhone, find it on Windows, and the other way around |
| **3** | iPhone web app | The 24-hour history on the iPhone, and a way to send from it |
| **4** | Polish and release | Installers, auto-updates, and a landing page |

**Who does what**

| Device | Clipway runs as | UI |
|---|---|---|
| Windows PC | Tauri app in the system tray | Clipway popup (`Ctrl + Shift + V`) |
| Mac | The same Tauri app, in the menu bar with no window | Raycast's Clipboard History |
| iPhone | Web app (PWA) served by the computers over Tailscale | The web app, plus Back Tap Shortcuts |

Every device keeps clipboard history for **24 hours**, then deletes it.

---

## Phase 0: Groundwork

The goal is to prove the risky parts work before building on top of them.

- [ ] **Fix Universal Clipboard between the Mac and iPhone**
  - [x] Mac side checked (2026-10-18): Universal Clipboard and Handoff on, Wi-Fi and Bluetooth on, AirDrop link up, firewall not blocking, no management profile
  - [ ] iPhone signed in to the same Apple Account as the Mac (*Settings → your name*)
  - [ ] Handoff on: *Settings → General → AirPlay & Continuity → Handoff*
  - [ ] Bluetooth and Wi-Fi on in *Settings*, not just Control Center
  - [ ] Handoff test: open a page in Safari on the iPhone, and a Safari icon should appear at the right end of the Mac's Dock
  - [ ] AirDrop test between the two devices
  - [ ] If it's still broken: turn Handoff off and on on both, restart both, and as a last resort sign out of iCloud on the Mac and back in
- [ ] **Spike: can a Mac app see items from Universal Clipboard?** Run `swift spikes/pasteboard.swift watch`, copy on the iPhone, and check that it prints `remote=true` with the content.
- [ ] **Spike: does the reverse direction work?** Run `swift spikes/pasteboard.swift write "hello"` and paste on the iPhone.
- [ ] **Spike: how awake does the Mac need to be?** Repeat the first spike with the Mac's screen locked, then with the display off.
- [ ] **Check Raycast:** after copying on the iPhone, open Raycast's Clipboard History. If the item is there, Raycast already keeps iPhone copies past 2 minutes on the Mac.
- [ ] Install Tailscale on Windows, Mac, and iPhone, and check that each device can ping the others
- [ ] Turn on **MagicDNS** and **HTTPS certificates** in the Tailscale admin console (the iPhone web app needs HTTPS)
- [x] Install Rust, Node.js, and the Tauri prerequisites on the Mac
- [ ] Install Rust, Node.js, and the Tauri prerequisites on Windows
- [x] Create the Tauri 2 + React + TypeScript project

> The spikes decide how much of the iPhone plan can rely on Universal Clipboard. Do them first.

## Phase 1: Windows app

The goal is a clipboard manager good enough to use every day, even with no sync.

**Core**
- [ ] Background app with a system tray icon that starts at login
- [ ] Clipboard watcher that captures text, links, and images
- [ ] SQLite database for history (content, type, source app, time copied)
- [ ] Images stored as files on disk with thumbnails, and only their paths kept in the database
- [ ] Duplicates bumped to the top instead of saved twice
- [ ] **24-hour history**: items are deleted 24 hours after they were last copied, image files included (checked at startup and every minute)

**Popup**
- [ ] Global shortcut (`Ctrl + Shift + V`) opens the popup near the cursor
- [ ] Search that filters as you type
- [ ] Arrow keys to move, `Enter` to paste into the previous app, `Esc` to close
- [ ] Previews for each type: text snippet, image thumbnail, color swatch
- [ ] Delete items

**Privacy**
- [ ] Ignore content marked as sensitive (Windows: `ExcludeClipboardContentFromMonitorProcessing`)
- [ ] App blocklist (for example password managers)
- [ ] "Pause capture" toggle in the tray

## Phase 2: Mac agent and sync

The goal is that copying on the Mac or the iPhone makes the item show up on Windows, and the other way around, even when you're away from home.

**Mac agent** (the same app built from the same code, minus the window: Raycast is the UI on the Mac)
- [ ] Runs in the menu bar only (no Dock icon, no popup) and starts at login
- [ ] Watches the Mac clipboard about 4 times a second (macOS has no "clipboard changed" event)
- [ ] **Saves Universal Clipboard items before they expire**: when an item from the iPhone arrives (it carries the `com.apple.is-remote-clipboard` marker), read its full content immediately and save it, labelled "iPhone"
- [ ] Ignore concealed and temporary content (`org.nspasteboard.ConcealedType` and `org.nspasteboard.TransientType`, the markers password managers use)
- [ ] The same 24-hour history as on Windows
- [ ] Menu bar menu: pause capture, last item received, quit
- [ ] The popup stays available behind a setting (off by default), which also makes it easy to work on the popup from the Mac
- [ ] *Optional:* a Raycast extension, only if Raycast's built-in Clipboard History isn't enough (see [why](docs/ARCHITECTURE.md#why-these-choices))

**Sync over Tailscale**
- [ ] Small local server inside each app, reachable only through Tailscale
- [ ] Pairing: link devices once with a shared secret, and reject everything else
- [ ] Send new items to paired devices as they're copied
- [ ] Items received from another device go on the local clipboard (on the Mac, that also puts them in Raycast's history and hands them to the iPhone through Universal Clipboard). A setting keeps them in history only.
- [ ] **Echo prevention**: each item gets a unique ID and an origin device, so synced items are never sent back (otherwise you get an endless loop)
- [ ] Outbox: items copied while a device is offline are sent when it reconnects, unless they're already 24 hours old
- [ ] The 24 hours count from when the item was copied on its original device, not from when it arrived
- [ ] Size limits and compression for large images
- [ ] Sync settings: on/off per device and per content type

## Phase 3: iPhone web app

The goal is the 24-hour history on the iPhone, without keyboard tricks or a paid developer account.

**Web app (PWA), the main route**
- [ ] Each computer's sync server also serves the web app and a small API, only over Tailscale
- [ ] HTTPS through `tailscale serve` (iOS only allows clipboard access and *Add to Home Screen* on HTTPS pages)
- [ ] Pairing: the desktop app shows a QR code with its address and a one-time code, which you scan with the iPhone camera
- [ ] History: everything from the last 24 hours on all devices, newest first, with search
- [ ] Tap an item to copy it on the iPhone
- [ ] "Send clipboard" button: iOS shows a small Paste prompt, then the item goes to the computers
- [ ] Connects to whichever computer is online (Mac or PC)
- [ ] Keeps no history on the phone, so nothing outlives the 24 hours
- [ ] Reuses the popup's React components

**Universal Clipboard (automatic when the Mac is nearby)**
- [ ] iPhone copies saved by the Mac agent (Phase 2) appear in the web app and on Windows for 24 hours
- [ ] Items from Windows reach the iPhone's clipboard through the Mac for about 2 minutes, and stay in the web app for 24 hours

**Back Tap Shortcuts (fastest, nothing to open)**
- [ ] "Send" Shortcut: double back tap sends the iPhone clipboard to Clipway over Tailscale
- [ ] "Receive" Shortcut: triple back tap fetches the latest item and copies it
- [ ] Shareable Shortcut links and a setup guide in `docs/`

## Phase 4: Polish and release

- [ ] Themes, animations, and a settings window
- [ ] Windows installer and macOS `.dmg` through GitHub Releases
- [ ] Auto-updates
- [ ] Screenshots and a demo GIF in the README
- [ ] Landing page on GitHub Pages

---

## Ideas for later

- Pins, which would need an exception to the 24-hour rule
- File and rich-text (formatted) support
- Text recognition (OCR) on copied images
- Snippets with placeholders (`{date}`, `{clipboard}`)
- Android app
- Native iOS app, if the $99/year Apple developer fee ever makes sense

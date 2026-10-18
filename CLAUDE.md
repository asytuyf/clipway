# clipway — project context

**Clipway** — a cross-device clipboard manager (Windows · macOS · iPhone), built with **Tauri 2**.

- **Windows:** full Tauri app with the popup UI. **Mac:** the same app as a menu-bar agent with no window; Raycast is the UI. **iPhone:** a PWA served by the computers over Tailscale HTTPS. History keeps **24 hours**, fixed.
- **Status: Phase 0.** Tauri 2 + React + TypeScript + Tailwind v4 scaffold is in place; no clipboard features and no UI yet. See `README.md`, `ROADMAP.md`, and `docs/`.
- Repo: public `asytuyf/clipway` (HTTPS/gh).

## Layout

- `src/` — React + TypeScript UI (Vite, Tailwind v4 via `@tailwindcss/vite`)
- `src-tauri/` — Rust side; plugins registered in `src-tauri/src/lib.rs`: single-instance (must stay first), autostart, global-shortcut, opener
- `src-tauri/capabilities/` — `default.json` (all platforms), `desktop.json` (desktop-only plugin permissions)
- `spikes/` — throwaway Phase 0 experiments (e.g. `swift spikes/pasteboard.swift watch`)

## Commands

- `pnpm install` — JS deps
- `pnpm tauri dev` — run the app with hot reload
- `pnpm tauri build` — release build + installers
- `pnpm build` — frontend type-check + build only
- `cargo check` / `cargo clippy` in `src-tauri/` — Rust only
- `pnpm tauri add <plugin>` — add an official Tauri plugin (wires Cargo, npm, lib.rs, and capabilities)

Rust is installed via rustup (`~/.cargo/bin`).

Commit as Abdel, no Claude co-author trailer.

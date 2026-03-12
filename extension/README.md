# ArkAI Browser Extension

A Chromium (Chrome/Edge/Brave) extension that mirrors the full functionality and UI of the **ArkAI Flutter app** — giving you instant Green Analysis for products on Amazon, Flipkart, and Nykaa.

## Features

| Feature             | Description                                                    |
| ------------------- | -------------------------------------------------------------- |
| 🔐 **Login**        | Same email/password auth flow as the Flutter app               |
| 🏠 **Home Screen**  | Favourites grid (Amazon, Flipkart, Nykaa) + Green Report card  |
| 🌱 **Green FAB**    | Injected floating button on supported product pages            |
| 💰 **Pocket Score** | Price-based affordability score /10                            |
| 🧪 **Health Score** | Material safety analysis (Safe / Caution)                      |
| 🌍 **Planet Score** | Carbon footprint estimate with Low/Moderate/High rating        |
| ⭐ **ArkAI Rating** | Computed star rating combining customer reviews + pocket score |
| 🏷️ **Best Offers**  | Scraped bank offers, coupons, EMI, exchange deals              |

## Tech Stack

- **Vite 5** + **@crxjs/vite-plugin** — bundles and hot-reloads the MV3 extension
- **Vanilla JS (ES Modules)** — zero framework, fast and minimal
- **Chrome Manifest V3** — service worker background, content scripts, storage API

## Project Structure

```
extension/
├── manifest.json          # MV3 manifest
├── vite.config.js         # Vite + crxjs config
├── package.json
├── popup.html             # Main extension popup
├── generate-icons.js      # Utility: SVG → PNG icons
├── icons/
│   ├── icon128.svg        # Source icon
│   ├── icon16.png
│   ├── icon32.png
│   ├── icon48.png
│   └── icon128.png
└── src/
    ├── popup.js           # Popup controller (router + state)
    ├── popup.css          # All styles — dark theme matching Flutter app
    ├── auth.js            # AuthProvider port (chrome.storage.local)
    ├── analysis.js        # Green Analysis engine (direct JS port from Flutter)
    ├── content.js         # Content script — injects FAB on product pages
    └── background.js      # Service worker — badge updates, message routing
```

## Development

```bash
cd extension
npm install
npm run dev          # Watch mode — auto-rebuilds on change
```

Then load `extension/dist` as an unpacked extension in Chrome:

1. Open `chrome://extensions`
2. Enable **Developer mode**
3. Click **Load unpacked** → select the `dist/` folder

## Production Build

```bash
npm run build
```

Output is in `extension/dist/`. Load this folder as an unpacked extension.

## How It Works

### Content Script (`content.js`)

Injected on every Amazon/Flipkart/Nykaa page. On product pages (detected by URL pattern matching the Flutter `BrowserProvider._checkIfProductPage`) it injects a green FAB button. Clicking it runs the full analysis and shows a bottom-sheet overlay — identical to the Flutter app's JavaScript injection.

### Analysis Engine (`analysis.js`)

A complete ES module port of the JavaScript injection script from `browser_screen.dart`. All the same extraction logic: price selectors, material detection, carbon estimation, offers scraping.

### Popup (`popup.js` + `popup.html`)

Three-state UI matching the Flutter navigation:

- `/` → Login Screen
- `/home` → Home Screen
- Analysis overlay → triggered by content script or popup button

### Auth (`auth.js`)

Mirrors `AuthProvider`: any non-empty email + password succeeds. State persisted via `chrome.storage.local`.

# 🛒 ArkAI – Privacy-First AI Shopping Browser

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://docs.flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)]()

> 🚀 An intelligent, privacy-first shopping browser built with Flutter that overlays real-time AI insights directly onto e-commerce websites.

---

## ✨ Why ArkAI?

Unlike traditional browsers, **ArkAI** is purpose-built for smarter shopping decisions.

When you browse popular stores like **Amazon**, **Flipkart**, or **Nykaa**, ArkAI:

- Injects intelligent JavaScript into the page
- Extracts product information in real-time
- Calculates sustainability & savings insights
- Displays an AI-powered overlay directly on the product page

⚡ All processing happens **on-device** — no server-side scraping, no tracking, no privacy compromise.

---

## 🧠 AI Appliance Insight Card

ArkAI overlays a floating bottom sheet that provides:

### 💰 Pocket Score  
Estimate how much you could save based on appliance efficiency.

### 🌍 Planet Score  
Understand environmental impact (e.g., tree-equivalent carbon savings).

### 🛡 Safety-Life  
Quick safety and longevity ratings for smarter long-term decisions.

---

## 📱 Features

### 🏠 Store Hub
- Dark-themed modern UI
- Quick access to favorite stores
- Smart navigation grid

### 🌐 Smart WebView Engine
- Custom WebView implementation
- Injected JavaScript extraction logic
- No backend scraping required

### 🪄 Dynamic Overlay UI
- Floating AI Insight bottom sheet
- Seamless integration with store mobile sites
- Non-intrusive UX

### 🌱 Green Report
- Tracks sustainable alternatives discovered
- Displays eco-impact trends
- Encourages greener purchasing habits

### 🔄 Cross-Platform
Built entirely with Flutter → works smoothly on:
- Android
- iOS

---

## 🚀 Getting Started

### 🔧 Prerequisites

- Flutter SDK (3.x recommended)  
  https://docs.flutter.dev/get-started/install
- Android Studio / VS Code
- Emulator or Physical Device

---

### 📦 Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/ark_ai.git

# Navigate into the project
cd ark_ai

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## 🗂 Project Structure

```
lib/
 ├── core/
 │    └── constants/        # Store URLs & configuration
 │
 ├── features/
 │    ├── home/             # Store hub + Green Report
 │    └── browser/          # WebView + JS extraction logic
 │
 └── main.dart
```

### Key Components

| Folder | Responsibility |
|--------|---------------|
| `home/` | Favorites grid, dashboard UI |
| `browser/` | WebViewWidget + JS injection + bottom nav |
| `constants/` | Store URLs & configuration |

---

## 🔐 Privacy First

ArkAI is designed with privacy in mind:

- ✅ No server-side scraping  
- ✅ No data tracking  
- ✅ No cloud processing  
- ✅ On-device AI logic  

Your browsing stays yours.

---

## 🤝 Contributing

We love contributions!

1. Fork the repo
2. Create a new feature branch
3. Commit your changes
4. Submit a PR 🚀

Ideas to contribute:
- Improve extraction logic
- Add new store compatibility
- Enhance UI animations
- Optimize WebView performance

---

## ⭐ Support the Project

If you like ArkAI:

- ⭐ Star the repository  
- 🍴 Fork it  
- 🧠 Suggest new features  

---

## 📄 License

This project is licensed under the **MIT License** – see the [LICENSE](LICENSE) file for details.

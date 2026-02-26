# ArkAI

ArkAI is an intelligent, privacy-first shopping browser built with Flutter. Unlike a regular browser, ArkAI is designed specifically to help you make better purchasing decisions by overlaying smart insights directly onto e-commerce pages.

## What it does

When you browse popular shopping sites (like Amazon, Flipkart, or Nykaa) using ArkAI, the app automatically extracts product details from the page using injected JavaScript. It then calculates and displays an "AI Appliance Insight" card right over the product page. 

This helps you quickly understand:
- **Pocket Score**: How much you might save based on the appliance's efficiency.
- **Planet Score**: The environmental impact (e.g., how many trees it's equivalent to).
- **Safety-Life**: Quick safety and longevity ratings.

All of this happens right on your device while you browse.

## Features

- **Store Hub:** A clean, dark-themed home screen with quick access to your favorite shopping destinations (Amazon, Flipkart, Nykaa, etc.).
- **Smart WebView Engine:** Uses a custom webview implementation that injects analysis scripts directly into store pages without needing server-side scraping.
- **Dynamic Overlay UI:** Displays a floating "AI Insight" bottom sheet that integrates naturally with the store's mobile website.
- **Green Report:** A tracking feature on the home screen that keeps a log of sustainable alternatives identified during your recent searches.
- **Cross-Platform:** Built completely with Flutter, meaning it runs smoothly across different devices.

## Getting Started

To get this project up and running on your local machine, follow these steps:

### Prerequisites

Make sure you have [Flutter](https://docs.flutter.dev/get-started/install) installed on your system. 

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/ark_ai.git
   cd ark_ai
   ```

2. Install the necessary dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

- `lib/features/home/`: Contains the main hub UI, including the favorites grid and the green report dashboard.
- `lib/features/browser/`: This is where the magic happens. It handles the `WebViewWidget`, JavaScript extraction (`browser_screen.dart`), and standardizes the bottom address bar navigation.
- `lib/core/constants/`: Holds the main URLs and configuration constants for the supported stores.

## Contributing

Feel free to fork the project and submit a PR if you have ideas on how to improve the extraction logic or add support for more stores!

## License

This project is licensed under the MIT License.

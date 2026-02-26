import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../providers/browser_provider.dart';

class BrowserScreen extends StatefulWidget {
  final String? initialUrl;

  const BrowserScreen({super.key, this.initialUrl});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setOnJavaScriptAlertDialog((
        JavaScriptAlertDialogRequest request,
      ) async {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Message from Website'),
            content: Text(request.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      })
      ..addJavaScriptChannel(
        'ArkAIChannel',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint('ArkAI JS Message Received: ${message.message}');
          if (mounted) {
            context.read<BrowserProvider>().setWebsite(message.message);
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              context.read<BrowserProvider>().setLoading(true);
              context.read<BrowserProvider>().setUrl(url);
            }
          },
          onPageFinished: (String url) async {
            if (mounted) {
              context.read<BrowserProvider>().setLoading(false);
            }

            // Inject JavaScript
            const String script = r'''
function render() {
  function extractAmazonApplianceDetails() {
    const getText = (selector) =>
      document.querySelector(selector)?.innerText?.trim() || null;

    const getMeta = (name) =>
      document.querySelector(`meta[name="${name}"]`)?.content || null;

    const data = {};

    data.title = getText("#productTitle") || getMeta("title");

    data.brand =
      getText("#bylineInfo")?.replace("Brand:", "").trim() || getMeta("brand");

    data.rating =
      getText("span[data-hook=rating-out-of-text]") || getText(".a-icon-alt");

    data.reviewCount = getText("#acrCustomerReviewText");

    data.price = getText(".a-price .a-offscreen");

    data.category =
      document.querySelector("#wayfinding-breadcrumbs_feature_div a")
        ?.innerText || null;

    const specTable = document.querySelectorAll(
      "#productDetails_techSpec_section_1 tr"
    );

    specTable.forEach((row) => {
      const key = row.querySelector("th")?.innerText?.toLowerCase();
      const value = row.querySelector("td")?.innerText?.trim();

      if (!key || !value) return;

      if (key.includes("watt")) data.powerRating = value;
      if (key.includes("capacity")) data.capacity = value;
      if (key.includes("energy")) data.annualEnergyConsumption = value;
      if (key.includes("star")) data.energyStarRating = value;
    });

    Object.keys(data).forEach(
      (key) =>
        (data[key] === null || data[key] === undefined || data[key] === "") &&
        delete data[key]
    );

    return data;
  }

  function calculateScores(d) {
    let pocketScore = 5;

    if (d.energyStarRating) {
      const match = d.energyStarRating.match(/\d/);
      if (match) pocketScore = parseInt(match[0]) + 4;
    }

    const safetyScore = "Safe";

    let treeEquivalent = "2 Trees";

    if (d.energyStarRating) {
      const match = d.energyStarRating.match(/\d/);
      if (match) {
        const stars = parseInt(match[0]);
        treeEquivalent = `${stars * 2} Trees`;
      }
    }

    return {
      pocketScore: Math.min(pocketScore, 10),
      safetyScore,
      treeEquivalent,
    };
  }

  const data = extractAmazonApplianceDetails();
  const scores = calculateScores(data);

  const box = document.createElement("div");

  box.style.position = "fixed";
  box.style.bottom = "0";
  box.style.left = "0";
  box.style.width = "100%";
  box.style.background = "#111";
  box.style.color = "#fff";
  box.style.padding = "16px";
  box.style.borderTopLeftRadius = "16px";
  box.style.borderTopRightRadius = "16px";
  box.style.boxShadow = "0 -5px 20px rgba(0,0,0,0.5)";
  box.style.zIndex = "99999";
  box.style.fontFamily = "system-ui";
  box.style.maxHeight = "70vh";
  box.style.overflowY = "auto";

  box.innerHTML = `
    <div style="font-size:16px;font-weight:600;margin-bottom:8px;">
      ⚡ AI Appliance Insight
    </div>

    <div style="margin-bottom:12px;">
      💰 <b>Pocket Score:</b> ${scores.pocketScore}/10 (High Savings)
      <br/>
      🛡 <b>Safety-Life:</b> ${scores.safetyScore}
      <br/>
      🌍 <b>Planet Score:</b> ${scores.treeEquivalent}
    </div>

    <button id="viewMoreBtn"
      style="
        background:#ff9900;
        border:none;
        padding:8px 12px;
        border-radius:8px;
        font-weight:600;
        cursor:pointer;
        width:100%;
      ">
      View More Details
    </button>

    <div id="moreDetails"
      style="display:none;margin-top:12px;font-size:13px;">
      ${Object.entries(data)
        .map(
          ([key, value]) =>
            `<div style="margin-bottom:6px;">
              <b>${key}:</b> ${value}
            </div>`
        )
        .join("")}
    </div>
  `;

  document.body.appendChild(box);

  document.getElementById("viewMoreBtn").addEventListener("click", () => {
    const more = document.getElementById("moreDetails");
    more.style.display = more.style.display === "none" ? "block" : "none";
  });
}

if (window.location.origin === "https://www.amazon.in" || window.location.origin === "https://amazon.in" || window.location.origin === "https://www.amazon.in/" || window.location.origin === "https://amazon.in/") {
  render();
  ArkAIChannel.postMessage("AMAZON INDIA");
} else if (window.location.origin === "https://www.flipkart.com" || window.location.origin === "https://flipkart.com" || window.location.origin === "https://www.flipkart.com/" || window.location.origin === "https://flipkart.com/") {
  alert("FLIPKART");
  window.document.write("<h1>FLIPKART</h1>");
  ArkAIChannel.postMessage("FLIPKART");
} else if (window.location.origin === "https://www.nykaa.com" || window.location.origin === "https://nykaa.com" || window.location.origin === "https://www.nykaa.com/" || window.location.origin === "https://nykaa.com/") {
  alert("NYKAA");
  window.document.write("<h1>NYKAA</h1>");
  ArkAIChannel.postMessage("NYKAA");
} else {
  alert("OTHER WEBSITE");
  window.document.write("<h1>Other Website</h1>");
  ArkAIChannel.postMessage("OTHER WEBSITE");
}
''';

            try {
              await _controller.runJavaScript(script);
            } catch (e) {
              debugPrint('Failed to run javascript: $e');
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );

    if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) {
      _loadUrl(widget.initialUrl!);
    }
  }

  void _loadUrl(String url) {
    _controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            Consumer<BrowserProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.currentUrl.isEmpty) {
                  return Center(
                    child: Text(
                      'Select a store to begin searching',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Consumer<BrowserProvider>(
              builder: (context, provider, child) {
                if (provider.isProductPage) {
                  return Positioned(
                    bottom:
                        24, // Positioned slightly above the bottom navigation bar
                    right: 24,
                    child: FloatingActionButton(
                      onPressed: () {
                        context.push('/analysis', extra: provider.currentUrl);
                      },
                      backgroundColor: Colors.purpleAccent,
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAddressBar(),
    );
  }

  Widget _buildBottomAddressBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Match dark background
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Left navigation arrows (active look)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              color: Colors.white,
              onPressed: () async {
                if (await _controller.canGoBack()) {
                  _controller.goBack();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 20),
              color: Colors.white,
              onPressed: () async {
                if (await _controller.canGoForward()) {
                  _controller.goForward();
                }
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Consumer<BrowserProvider>(
                  builder: (context, provider, child) {
                    String displayUrl = provider.currentUrl;
                    if (displayUrl.isEmpty) {
                      displayUrl = 'arkai://browser';
                    }
                    return Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          provider.currentUrl.isEmpty
                              ? Icons.search
                              : Icons.lock_outline,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: displayUrl),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                            readOnly: true, // Just for display parity for now
                          ),
                        ),
                        if (provider.isLoading)
                          const Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.purpleAccent,
                              ),
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 16),
                            color: Colors.white.withValues(alpha: 0.5),
                            onPressed: () =>
                                _controller.reload(), // Reload the webview
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.only(right: 12),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.close), // Cross icon
              color: Colors.white,
              onPressed: () =>
                  context.go('/home'), // Close the page by going home
            ),
          ],
        ),
      ),
    );
  }
}

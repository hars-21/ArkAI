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
            (() => {
  "use strict";

  const CONFIG = {
    productPathIndicator: "/dp/",
    overlayId: "arkai-overlay",
    buttonId: "arkai-fab",
    zIndex: 2147483647,
  };

  function init() {
    if (!window.location.pathname.includes(CONFIG.productPathIndicator)) return;
    if (document.getElementById(CONFIG.buttonId)) return;
    injectFloatingButton();
  }

  function injectFloatingButton() {
    const button = document.createElement("div");
    button.id = CONFIG.buttonId;
    button.textContent = "✨";

    Object.assign(button.style, {
      position: "fixed",
      bottom: "40px",
      right: "20px",
      width: "60px",
      height: "60px",
      borderRadius: "50%",
      backgroundColor: "#6d28d9",
      color: "#fff",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      fontSize: "26px",
      cursor: "pointer",
      zIndex: CONFIG.zIndex,
      boxShadow: "0 8px 20px rgba(0,0,0,0.4)",
    });

    button.addEventListener("click", openOverlay);
    document.body.appendChild(button);
  }

  function openOverlay() {
    if (document.getElementById(CONFIG.overlayId)) return;
    const data = extractProductData();
    const analysis = analyze(data);
    renderOverlay(analysis);
  }

  function extractProductData() {
    const getText = (selector) =>
      document.querySelector(selector)?.textContent.trim() || null;

    const getAllText = (selector) =>
      Array.from(document.querySelectorAll(selector))
        .map((el) => el.textContent.trim())
        .filter(Boolean);

    const title =
      getText("#productTitle") || getText("#title") || "Unknown Product";

    function extractPrice() {
      const el =
        document.querySelector(".a-price .a-offscreen") ||
        document.querySelector("#corePrice_feature_div .a-offscreen") ||
        document.querySelector("#priceblock_ourprice") ||
        document.querySelector("#priceblock_dealprice");

      if (el && el.textContent.trim()) return el.textContent.trim();

      const whole = document.querySelector(".a-price-whole")?.textContent;
      const fraction = document.querySelector(".a-price-fraction")?.textContent;
      if (whole) return fraction ? `${whole}.${fraction}` : whole;

      return "Price unavailable";
    }

    const price = extractPrice();
    const rating = getText(".a-icon-alt") || "0";
    const reviewCount = getText("#acrCustomerReviewText") || "0 reviews";

    const features = getAllText("#feature-bullets li span")
      .filter((t) => t.length > 20)
      .slice(0, 5);

    const reviews = getAllText(".review-text-content span").slice(0, 5);

    return { title, price, rating, reviewCount, features, reviews };
  }

  function analyze(data) {
    const ratingValue = parseFloat(data.rating) || 0;
    const priceNumber =
      parseFloat((data.price || "").replace(/[^0-9.]/g, "")) || 0;

    const textBlob = (
      data.features.join(" ") +
      " " +
      data.reviews.join(" ")
    ).toLowerCase();

    const pros = data.features.slice(0, 3);

    const negativeKeywords = ["not", "poor", "bad", "issue", "problem"];
    const cons = data.reviews
      .filter((r) =>
        negativeKeywords.some((k) => r.toLowerCase().includes(k))
      )
      .slice(0, 3);

    let efficiencyScore = 5;
    if (ratingValue >= 4.3) efficiencyScore += 2;
    if (priceNumber && priceNumber < 50000) efficiencyScore += 1;
    if (textBlob.includes("energy efficient")) efficiencyScore += 2;
    efficiencyScore = Math.min(10, efficiencyScore);

    const efficiencyLabel =
      efficiencyScore >= 8
        ? "High Savings"
        : efficiencyScore >= 5
        ? "Moderate Efficiency"
        : "Low Efficiency";

    let safetyStatus = "Safe";
    if (textBlob.match(/radiation|overheat|fire/)) safetyStatus = "Warning";
    if (textBlob.match(/toxic|hazard|explosion/))
      safetyStatus = "Hazardous";

    let carbonScore = 3;
    if (priceNumber > 70000) carbonScore = 6;
    if (textBlob.match(/low power|eco mode/)) carbonScore = 2;
    const treeEquivalent = Math.max(1, carbonScore);

    const summary = `
${data.title}

Price: ${data.price}
Rating: ${data.rating} (${data.reviewCount})

AI extracted product signals suggest balanced performance with moderate long-term efficiency.
`.trim();

    const recommendation =
      ratingValue >= 4
        ? "Recommended based on rating and extracted signals."
        : "Mixed signals. Review carefully before purchase.";

    return {
      summary,
      pros: pros.length ? pros : ["No major strengths extracted"],
      cons: cons.length ? cons : ["No significant concerns detected"],
      recommendation,
      efficiencyScore,
      efficiencyLabel,
      safetyStatus,
      treeEquivalent,
    };
  }

  function renderOverlay(analysis) {
    const overlay = document.createElement("div");
    overlay.id = CONFIG.overlayId;

    Object.assign(overlay.style, {
      position: "fixed",
      inset: "0",
      background: "#111",
      color: "#fff",
      zIndex: CONFIG.zIndex,
      overflowY: "auto",
      fontFamily: "system-ui, -apple-system, sans-serif",
      padding: "24px",
    });

    overlay.innerHTML = `
      <div style="max-width:720px;margin:0 auto;">
        ${renderHeader()}
        ${renderCard("AI Summary", analysis.summary)}
        ${renderSustainabilitySection(analysis)}
        ${renderProsCons(analysis.pros, analysis.cons)}
        ${renderCard("Final Recommendation", analysis.recommendation)}
      </div>
    `;

    document.body.appendChild(overlay);
    document
      .getElementById("arkai-close")
      .addEventListener("click", () => overlay.remove());
  }

  function renderHeader() {
    return `
      <div style="display:flex;align-items:center;margin-bottom:30px;">
        <div id="arkai-close" style="cursor:pointer;margin-right:16px;font-size:20px;">←</div>
        <h1 style="margin:0;font-size:24px;font-weight:600;">ArkAI Analysis</h1>
      </div>
    `;
  }

  function renderCard(title, content) {
    return `
      <div style="background:#1a1a1a;padding:20px;border-radius:14px;margin-bottom:20px;">
        <div style="font-weight:600;margin-bottom:8px;color:#ffffff;">${title}</div>
        <div style="line-height:1.6;white-space:pre-line;color:#ffffff;">
          ${content}
        </div>
      </div>
    `;
  }

  function renderSustainabilitySection(analysis) {
    return `
      <div style="background:#1a1a1a;padding:22px;border-radius:14px;margin-bottom:20px;">
        <div style="font-weight:600;font-size:18px;margin-bottom:16px;color:#ffffff;">
          Sustainability Intelligence
        </div>
        <div style="display:flex;flex-direction:column;gap:14px;color:#ffffff;">

          <div style="display:flex;justify-content:space-between;">
            <span>Efficiency Grade (Pocket Score)</span>
            <span style="font-weight:600;">
              ${analysis.efficiencyScore}/10 — ${analysis.efficiencyLabel}
            </span>
          </div>

          <div style="display:flex;justify-content:space-between;">
            <span>Safety-Life Shield (Health Score)</span>
            <span style="font-weight:600;">
              ${analysis.safetyStatus}
            </span>
          </div>

          <div style="display:flex;justify-content:space-between;">
            <span>Carbon Footprint (Planet Score)</span>
            <span style="font-weight:600;">
              Equivalent to planting ${analysis.treeEquivalent} trees
            </span>
          </div>

        </div>
      </div>
    `;
  }

  function renderProsCons(pros, cons) {
    return `
      <div style="display:flex;gap:16px;flex-wrap:wrap;margin-bottom:20px;">
        ${renderListCard("Pros", pros)}
        ${renderListCard("Cons", cons)}
      </div>
    `;
  }

  function renderListCard(title, items) {
    return `
      <div style="flex:1;min-width:260px;background:#1a1a1a;padding:20px;border-radius:14px;color:#ffffff;">
        <div style="font-weight:600;margin-bottom:10px;color:#ffffff;">${title}</div>
        <ul style="padding-left:18px;margin:0;color:#ffffff;">
          ${items
            .map(
              (i) =>
                `<li style="margin-bottom:6px;color:#ffffff;">${i}</li>`
            )
            .join("")}
        </ul>
      </div>
    `;
  }

  init();
})();

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
          color: const Color(0xFF1E1E1E),
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
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
                            readOnly: true,
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
                            onPressed: () => _controller.reload(),
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
              icon: const Icon(Icons.close),
              color: Colors.white,
              onPressed: () => context.go('/home'),
            ),
          ],
        ),
      ),
    );
  }
}

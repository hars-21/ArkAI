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
(function () {
  if (!location.pathname.includes("/dp/")) {
    console.log("Not a product page");
    return;
  }

  if (document.getElementById("arkai-fab")) return;

  const fab = document.createElement("div");
  fab.id = "arkai-fab";
  fab.innerHTML = "✨";

  Object.assign(fab.style, {
    position: "fixed",
    bottom: "40px",
    right: "20px",
    width: "65px",
    height: "65px",
    borderRadius: "50%",
    background: "#7c3aed",
    color: "white",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontSize: "28px",
    cursor: "pointer",
    zIndex: "2147483647",
    boxShadow: "0 10px 25px rgba(0,0,0,0.5)",
  });

  document.body.appendChild(fab);

  function renderArkAIUI(productUrl) {
    if (document.getElementById("arkai-overlay")) return;

    const overlay = document.createElement("div");
    overlay.id = "arkai-overlay";

    Object.assign(overlay.style, {
      position: "fixed",
      inset: "0",
      background: "#0f0f0f",
      color: "white",
      zIndex: "2147483647",
      overflowY: "auto",
      fontFamily: "system-ui, sans-serif",
      padding: "20px",
    });

    overlay.innerHTML = `
      <div style="max-width:700px;margin:auto;">

        <div style="display:flex;align-items:center;margin-bottom:30px;">
          <div id="arkai-close" style="font-size:22px;cursor:pointer;margin-right:15px;">←</div>
          <h1 style="font-size:26px;margin:0;">ArkAI Analysis</h1>
        </div>

        ${card("🔗", "Product Source", productUrl)}

        ${card("✨", "AI Summary", "Mock Summary from Service.")}

        <div style="display:flex;gap:15px;flex-wrap:wrap;">
          ${miniCard("✅", "Pros", ["Mock Pro 1", "Mock Pro 2"], "#22c55e")}
          ${miniCard("❌", "Cons", ["Mock Con 1", "Mock Con 2"], "#ef4444")}
        </div>

        ${card("💡", "Final Recommendation", "Mock Recommendation.")}

      </div>
    `;

    document.body.appendChild(overlay);

    document.getElementById("arkai-close").onclick = () => {
      overlay.remove();
    };
  }

  function card(icon, title, content) {
    return `
      <div style="
        background:#1c1c1c;
        padding:20px;
        border-radius:16px;
        margin-bottom:20px;
        box-shadow:0 4px 20px rgba(0,0,0,0.4);
      ">
        <div style="font-weight:600;font-size:18px;margin-bottom:10px;">
          ${icon} ${title}
        </div>
        <div style="opacity:0.8;line-height:1.6;word-break:break-word;">
          ${content}
        </div>
      </div>
    `;
  }

  function miniCard(icon, title, items, color) {
    return `
      <div style="
        flex:1;
        min-width:250px;
        background:#1c1c1c;
        padding:20px;
        border-radius:16px;
        margin-bottom:20px;
        box-shadow:0 4px 20px rgba(0,0,0,0.4);
      ">
        <div style="font-weight:600;font-size:18px;margin-bottom:10px;color:${color}">
          ${icon} ${title}
        </div>
        <ul style="padding-left:18px;opacity:0.85;">
          ${items.map((i) => `<li style="margin-bottom:6px;">${i}</li>`).join("")}
        </ul>
      </div>
    `;
  }

  fab.onclick = () => {
    renderArkAIUI(location.href);
  };
})();

if (window.location.origin === "https://www.amazon.in" || window.location.origin === "https://amazon.in" || window.location.origin === "https://www.amazon.in/" || window.location.origin === "https://amazon.in/") {
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
                    bottom: 24,
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

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
    buttonId: "arkai-fab",
    overlayId: "arkai-modal-overlay",
    zIndex: 2147483647,
  };

  function init() {
    if (!location.pathname.includes(CONFIG.productPathIndicator)) return;
    if (document.getElementById(CONFIG.buttonId)) return;
    injectButton();
  }

  function injectButton() {
    const btn = document.createElement("div");
    btn.id = CONFIG.buttonId;
    btn.innerHTML = "✨";

    Object.assign(btn.style, {
      position: "fixed",
      bottom: "90px",
      right: "20px",
      width: "60px",
      height: "60px",
      borderRadius: "50%",
      background: "#c4b5fd",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      fontSize: "24px",
      cursor: "pointer",
      zIndex: CONFIG.zIndex,
    });

    btn.onclick = openModal;
    document.body.appendChild(btn);
  }

  function openModal() {
    if (document.getElementById(CONFIG.overlayId)) return;

    const data = extractData();
    const analysis = analyze(data);

    const overlay = document.createElement("div");
    overlay.id = CONFIG.overlayId;

    Object.assign(overlay.style, {
      position: "fixed",
      inset: "0",
      background: "rgba(0,0,0,0.4)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      zIndex: CONFIG.zIndex,
    });

    overlay.innerHTML = renderModal(analysis);

    overlay.onclick = (e) => {
      if (e.target.id === CONFIG.overlayId) overlay.remove();
    };

    document.body.appendChild(overlay);
  }

  function extractData() {
    const rating =
      parseFloat(
        document.querySelector(".a-icon-alt")?.textContent
      ) || 4;
    return { rating };
  }

  function analyze(data) {
    const pocketScore = 8;
    const healthScore = "Safe";
    const planetScore = "5 trees";
    const arkaiRating = Math.min(5, Math.round(data.rating));

    return { pocketScore, healthScore, planetScore, arkaiRating };
  }

  function renderStars(count) {
    let output = "";
    for (let i = 1; i <= 5; i++) {
      output += i <= count ? "★" : "☆";
    }
    return output;
  }

  function renderModal(analysis) {
    return `
      <div style="
        width:380px;
        background:#ffffff;
        border-radius:14px;
        padding:28px;
        font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;
        color:#111;
      ">

        <div style="font-size:20px;font-weight:700;
            background:linear-gradient(90deg,#ef4444,#3b82f6);
            -webkit-background-clip:text;
            -webkit-text-fill-color:transparent;">
          ArkAI
        </div>

        <div style="border-top:1px solid #e5e7eb;margin:16px 0 22px;"></div>

        <div style="display:flex;justify-content:space-between;align-items:center;">
          <div>
            <div style="font-size:28px;font-weight:700;color:#22c55e;">
              Green
            </div>
            <div style="font-size:28px;font-weight:700;">
              Analysis
            </div>
          </div>
          <div style="font-size:32px;">🌱</div>
        </div>

        <div style="margin-top:28px;">

          ${metricRow(
            "Pocket Score",
            "( How much this product costs to run compared to the best available alternative. )",
            analysis.pocketScore
          )}

          ${metricRow(
            "Health Score",
            "( Does the appliance use harmful materials or emit anything unsafe like ozone or excessive EMF? )",
            analysis.healthScore
          )}

          ${metricRow(
            "Planet Score",
            "( The environmental \"cost\" of manufacturing and running this device. )",
            analysis.planetScore
          )}

        </div>

        <div style="border-top:1px solid #e5e7eb;margin:24px 0;"></div>

        <div style="display:flex;align-items:center;justify-content:space-between;">
          <div style="font-weight:600;">ArkAI Rating</div>
          <div style="color:#facc15;font-size:20px;">
            ${renderStars(analysis.arkaiRating)}
          </div>
        </div>

      </div>
    `;
  }

  function metricRow(title, desc, value) {
    return `
      <div style="margin-bottom:24px;">
        <div style="display:flex;justify-content:space-between;">
          <div style="font-weight:600;font-size:16px;">${title}</div>
          <div style="font-weight:600;font-size:16px;">${value}</div>
        </div>
        <div style="font-size:12px;color:#6b7280;margin-top:6px;line-height:1.4;width:80%;">
          ${desc}
        </div>
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

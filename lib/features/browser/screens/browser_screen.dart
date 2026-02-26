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
            const String script = '''
              if (window.location.origin === "https://www.amazon.in" || window.location.origin === "https://amazon.in" || window.location.origin === "https://www.amazon.in/" || window.location.origin === "https://amazon.in/") {
                alert("AMAZON INDIA");
                ArkAIChannel.postMessage("AMAZON INDIA");
              } else if (window.location.origin === "https://www.flipkart.com" || window.location.origin === "https://flipkart.com" || window.location.origin === "https://www.flipkart.com/" || window.location.origin === "https://flipkart.com/") {
                alert("FLIPKART");
                ArkAIChannel.postMessage("FLIPKART");
              } else if (window.location.origin === "https://www.nykaa.com" || window.location.origin === "https://nykaa.com" || window.location.origin === "https://www.nykaa.com/" || window.location.origin === "https://nykaa.com/") {
                alert("NYKAA");
                ArkAIChannel.postMessage("NYKAA");
              } else {
                alert("OTHER WEBSITE");
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
      appBar: AppBar(
        title: const Text('ArkAI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: Stack(
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
                  bottom: 80, // Adjusted to be above the address bar correctly
                  right: 24,
                  child: FloatingActionButton(
                    onPressed: () {
                      context.push('/analysis', extra: provider.currentUrl);
                    },
                    backgroundColor: Colors.purpleAccent,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.auto_awesome, color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Bottom Address Bar (iOS Style)
          // Bottom Address Bar (iOS Style)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
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
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      displayUrl,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                      icon: const Icon(
                        Icons.close,
                      ), // Replaced filter/tabs icon with close cross icon
                      color: Colors.white,
                      onPressed: () => context.go('/home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

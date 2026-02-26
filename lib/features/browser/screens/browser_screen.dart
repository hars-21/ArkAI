import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/browser_provider.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

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
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              context.read<BrowserProvider>().setLoading(true);
              context.read<BrowserProvider>().setUrl(url);
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              context.read<BrowserProvider>().setLoading(false);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );
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
          onPressed: () => context.go('/'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSiteButton(
                  title: 'Amazon',
                  url: AppConstants.amazonUrl,
                  color: Colors.orange,
                ),
                _buildSiteButton(
                  title: 'Flipkart',
                  url: AppConstants.flipkartUrl,
                  color: Colors.blue,
                ),
                _buildSiteButton(
                  title: 'Myntra',
                  url: AppConstants.myntraUrl,
                  color: Colors.pinkAccent,
                ),
              ],
            ),
          ),
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
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
                                  child: Text(
                                    displayUrl,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
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

  Widget _buildSiteButton({
    required String title,
    required String url,
    required Color color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton(
          onPressed: () => _loadUrl(url),
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.2),
            foregroundColor: color,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: color.withValues(alpha: 0.5)),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

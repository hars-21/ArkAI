import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _navigateToUrl(String url) {
    if (url.trim().isNotEmpty) {
      context.push('/browser', extra: url.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark theme like Arc Search
      body: Stack(
        children: [
          // Center Arc-like Logo
          Center(child: _buildDynamicLogo()),

          // Bottom Elements (Cards + Search Bar)
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStoreCardsRow(context),
                const SizedBox(height: 24),
                _buildSearchBar(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicLogo() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Blue pill
          Positioned(
            left: 20,
            bottom: 10,
            child: Transform.rotate(
              angle: -0.6,
              child: Container(
                width: 36,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade900, Colors.blueAccent],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Pink pill (overlapping)
          Positioned(
            right: 15,
            top: 25,
            child: Transform.rotate(
              angle: 0.6,
              child: Container(
                width: 36,
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pinkAccent.shade100, Colors.redAccent],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withValues(alpha: 0.3),
                      blurRadius: 10,
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

  Widget _buildStoreCardsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSmallStoreCard(
          context: context,
          title: 'Amazon',
          url: AppConstants.amazonUrl,
          icon: Icons.local_mall,
          color: Colors.orange,
        ),
        _buildSmallStoreCard(
          context: context,
          title: 'Flipkart',
          url: AppConstants.flipkartUrl,
          icon: Icons.shopping_cart,
          color: Colors.blue,
        ),
        _buildSmallStoreCard(
          context: context,
          title: 'Myntra',
          url: AppConstants.myntraUrl,
          icon: Icons.checkroom,
          color: Colors.pinkAccent,
        ),
      ],
    );
  }

  Widget _buildSmallStoreCard({
    required BuildContext context,
    required String title,
    required String url,
    required IconData icon,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _navigateToUrl(url),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E), // Slightly lighter than background
        borderRadius: BorderRadius.circular(10), // Pill shape
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 22,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Paste a product link...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (value) => _navigateToUrl(value),
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.url,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            onPressed: () => _navigateToUrl(_urlController.text),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

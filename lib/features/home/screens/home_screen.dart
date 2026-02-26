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
      backgroundColor: const Color(0xFF1E1E1E), // Dark theme
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Centered Background Dynamic Logo
            Positioned.fill(
              child: Center(
                child: Opacity(
                  opacity: 0.15, // Make it light and translucent
                  child: IgnorePointer(
                    child: Transform.scale(
                      scale: 1.2, // Slightly larger for background effect
                      child: _buildDynamicLogo(),
                    ),
                  ),
                ),
              ),
            ),
            // Main Content
            SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 40,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Favourites Section
                  const Text(
                    'Favourites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFavouritesGrid(),

                  const SizedBox(height: 40),

                  // Green Report Section
                  const Text(
                    'Green Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGreenReportCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAddressBar(),
    );
  }

  Widget _buildFavouritesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 20,
      crossAxisSpacing: 10,
      childAspectRatio: 0.75, // Adjust to fit icon and text
      children: [
        _buildFavouriteItem(
          title: 'Amazon',
          url: AppConstants.amazonUrl,
          icon: Icons.local_mall,
          color: Colors.white,
          backgroundColor: Colors.orange,
        ),
        _buildFavouriteItem(
          title: 'Flipkart',
          url: AppConstants.flipkartUrl,
          icon: Icons.shopping_cart,
          color: Colors.white,
          backgroundColor: Colors.blue,
        ),
        _buildFavouriteItem(
          title: 'Nykaa',
          url: AppConstants.nykaaUrl,
          icon: Icons.face_retouching_natural,
          color: Colors.white,
          backgroundColor: Colors.pinkAccent,
        ),
        // Placeholder for Add button (looks like an empty Safari slot)
        _buildFavouriteItem(
          title: 'Add',
          url: '',
          icon: Icons.add,
          color: Colors.white.withValues(alpha: 0.5),
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          isAdd: true,
        ),
      ],
    );
  }

  Widget _buildFavouriteItem({
    required String title,
    required String url,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
    bool isAdd = false,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isAdd) _navigateToUrl(url);
      },
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGreenReportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.eco, // Green leaf icon to represent "Green Report"
                color: Colors.green,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'In the last seven days, ArkAI has identified 0 sustainable alternatives for your searches.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
            // Left navigation arrows (inactive look)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 20),
              color: Colors.white.withValues(alpha: 0.3),
              onPressed: null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 20),
              color: Colors.white.withValues(alpha: 0.3),
              onPressed: null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      Icons.search,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search or enter website name',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ), // Adjust vertical alignment
                        ),
                        onSubmitted: (value) => _navigateToUrl(value),
                        textInputAction: TextInputAction.go,
                        keyboardType: TextInputType.url,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 16),
                      color: Colors.white.withValues(alpha: 0.5),
                      onPressed: () {
                        // On home screen, refresh doesn't do much, maybe clear or reset? For now simply empty action for UI consistency
                      },
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.only(right: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.close), // Cross icon
              color: Colors.white,
              onPressed: () {
                _urlController
                    .clear(); // Clear the text field as a helpful action
              },
            ),
          ],
        ),
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
}

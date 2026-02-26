import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnalysisScreen extends StatefulWidget {
  final String url;

  const AnalysisScreen({super.key, required this.url});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Mock loading delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('ArkAI Analysis'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/browser');
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.purpleAccent),
                  SizedBox(height: 16),
                  Text(
                    'Analyzing product data...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 16),
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildProsCard()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildConsCard()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendationCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link, color: Colors.purpleAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Product Source',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.url,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return _buildSectionCard(
      title: 'AI Summary',
      icon: Icons.auto_awesome,
      iconColor: Colors.blueAccent,
      child: Text(
        'This product appears to be highly rated for its durability and battery life. It is positioned as a premium offering in its category. Based on aggregated reviews, the general sentiment is overwhelmingly positive, citing excellent build quality but noting a slightly steep learning curve for new users.',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildProsCard() {
    return _buildSectionCard(
      title: 'Pros',
      icon: Icons.check_circle_outline,
      iconColor: Colors.greenAccent,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ListItem('Excellent battery life'),
          _ListItem('Premium build quality'),
          _ListItem('Fast charging'),
          _ListItem('Great display'),
        ],
      ),
    );
  }

  Widget _buildConsCard() {
    return _buildSectionCard(
      title: 'Cons',
      icon: Icons.cancel_outlined,
      iconColor: Colors.redAccent,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ListItem('High price point'),
          _ListItem('No included charger'),
          _ListItem('Heavy weight'),
          _ListItem('Steep learning curve'),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return _buildSectionCard(
      title: 'Final Recommendation',
      icon: Icons.lightbulb_outline,
      iconColor: Colors.amberAccent,
      child: Text(
        'Buy if you are a power user looking for premium features and can ignore the high price tag. Casual users might want to consider mid-tier alternatives that offer better value for money.',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Card(
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final String text;

  const _ListItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white70)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),
        ],
      ),
    );
  }
}

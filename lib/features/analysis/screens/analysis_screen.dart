import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import '../../../core/models/analysis_model.dart';

class AnalysisScreen extends StatefulWidget {
  final String url;

  const AnalysisScreen({super.key, required this.url});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalysisProvider>().analyzeProduct(widget.url);
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
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.analysisData == null) {
            return _buildErrorState();
          }

          return _buildSuccessState(provider.analysisData!);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
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
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Failed to analyze product',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try a different URL or try again later.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<AnalysisProvider>().analyzeProduct(widget.url);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(AnalysisModel data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(),
          const SizedBox(height: 16),
          _buildSummaryCard(data.summary),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildProsCard(data.pros)),
              const SizedBox(width: 16),
              Expanded(child: _buildConsCard(data.cons)),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecommendationCard(data.recommendation),
        ],
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

  Widget _buildSummaryCard(String summary) {
    return _buildSectionCard(
      title: 'AI Summary',
      icon: Icons.auto_awesome,
      iconColor: Colors.blueAccent,
      child: Text(
        summary,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.8),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildProsCard(List<String> pros) {
    return _buildSectionCard(
      title: 'Pros',
      icon: Icons.check_circle_outline,
      iconColor: Colors.greenAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: pros.map((pro) => _ListItem(pro)).toList(),
      ),
    );
  }

  Widget _buildConsCard(List<String> cons) {
    return _buildSectionCard(
      title: 'Cons',
      icon: Icons.cancel_outlined,
      iconColor: Colors.redAccent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cons.map((con) => _ListItem(con)).toList(),
      ),
    );
  }

  Widget _buildRecommendationCard(String recommendation) {
    return _buildSectionCard(
      title: 'Final Recommendation',
      icon: Icons.lightbulb_outline,
      iconColor: Colors.amberAccent,
      child: Text(
        recommendation,
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

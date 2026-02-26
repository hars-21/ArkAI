import 'package:flutter/material.dart';
import 'package:arkai/core/theme/app_theme.dart';
import 'package:arkai/core/models/analysis_model.dart';

class AnalysisScreen extends StatelessWidget {
  final AnalysisModel? analysisData;
  final bool isLoading;

  const AnalysisScreen({super.key, this.analysisData, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        title: const Text('Product Analysis'),
        backgroundColor: AppTheme.primaryBackground,
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.accentColor),
                  SizedBox(height: 16),
                  Text(
                    'Analyzing product...',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          : analysisData == null
          ? const Center(
              child: Text(
                'No analysis data available',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    'AI Summary',
                    analysisData!.summary,
                    Icons.summarize,
                  ),
                  const SizedBox(height: 16),
                  _buildSustainabilityCard(),
                  const SizedBox(height: 16),
                  _buildProsCons(),
                  const SizedBox(height: 16),
                  _buildSection(
                    'Final Recommendation',
                    analysisData!.recommendation,
                    Icons.recommend,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSustainabilityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco, color: AppTheme.successColor, size: 20),
              SizedBox(width: 8),
              Text(
                'Sustainability Intelligence',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildScoreRow(
            'Efficiency Grade (Pocket Score)',
            '7/10 - Moderate Efficiency',
            AppTheme.infoColor,
          ),
          const Divider(color: AppTheme.textHint, height: 24),
          _buildScoreRow(
            'Safety-Life Shield (Health Score)',
            'Safe',
            AppTheme.successColor,
          ),
          const Divider(color: AppTheme.textHint, height: 24),
          _buildScoreRow(
            'Carbon Footprint (Planet Score)',
            'Equivalent to planting 3 trees',
            AppTheme.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProsCons() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.thumb_up,
                      color: AppTheme.successColor,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Pros',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...analysisData!.pros.map(
                  (pro) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $pro',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.thumb_down,
                      color: AppTheme.warningColor,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Cons',
                      style: TextStyle(
                        color: AppTheme.warningColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...analysisData!.cons.map(
                  (con) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $con',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

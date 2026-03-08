class AnalysisModel {
  final String summary;
  final List<String> pros;
  final List<String> cons;
  final String recommendation;

  AnalysisModel({
    required this.summary,
    required this.pros,
    required this.cons,
    required this.recommendation,
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) {
    return AnalysisModel(
      summary: json['summary'] ?? '',
      pros: List<String>.from(json['pros'] ?? []),
      cons: List<String>.from(json['cons'] ?? []),
      recommendation: json['recommendation'] ?? '',
    );
  }
}

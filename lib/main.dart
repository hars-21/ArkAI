import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:arkai/core/theme/app_theme.dart';
import 'package:arkai/core/router/app_router.dart';
import 'package:arkai/features/auth/providers/auth_provider.dart';
import 'package:arkai/features/browser/providers/browser_provider.dart';
import 'package:arkai/features/analysis/providers/analysis_provider.dart';

void main() {
  runApp(const ArkAIApp());
}

class ArkAIApp extends StatelessWidget {
  const ArkAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BrowserProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisProvider()),
      ],
      child: MaterialApp.router(
        title: 'ArkAI',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}

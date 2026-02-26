import 'package:go_router/go_router.dart';
import 'package:arkai/features/auth/screens/splash_screen.dart';
import 'package:arkai/features/auth/screens/login_screen.dart';
import 'package:arkai/features/home/screens/home_screen.dart';
import 'package:arkai/features/browser/screens/browser_screen.dart';
import 'package:arkai/features/analysis/screens/analysis_screen.dart';
import 'package:arkai/features/analysis/providers/analysis_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/browser',
      builder: (context, state) {
        final url = state.extra as String?;
        return BrowserScreen(initialUrl: url);
      },
    ),
    GoRoute(
      path: '/analysis',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => AnalysisProvider(),
          child: Consumer<AnalysisProvider>(
            builder: (context, provider, child) {
              return AnalysisScreen(
                analysisData: provider.analysisData,
                isLoading: provider.isLoading,
              );
            },
          ),
        );
      },
    ),
  ],
);

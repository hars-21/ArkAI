import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/browser/screens/browser_screen.dart';
import '../../features/analysis/screens/analysis_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
        final url = state.extra as String?;
        return AnalysisScreen(url: url ?? '');
      },
    ),
  ],
);

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'features/auth/providers/auth_provider.dart';

void main() {
  runApp(const ArkAIApp());
}

class ArkAIApp extends StatelessWidget {
  const ArkAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp.router(
        title: 'ArkAI',
        theme: ThemeData.dark(useMaterial3: true),
        routerConfig: appRouter,
      ),
    );
  }
}

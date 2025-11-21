import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/view/login_page.dart';
import 'features/auth/controller/auth_controller.dart';
import 'features/auth/state/auth_state.dart';
import 'features/settings/view/settings_page.dart';
import 'features/webview/view/webview_page.dart';

class EasaccApp extends ConsumerWidget {
  const EasaccApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    // Listen to auth state changes and navigate accordingly
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated) {
        // Use WidgetsBinding to ensure context is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            final navigator = Navigator.maybeOf(context);
            if (navigator != null) {
              if (next.isAuthenticated) {
                // User logged in, navigate to settings
                navigator.pushReplacementNamed(AppRoutes.settings);
              } else if (previous?.isAuthenticated == true) {
                // User logged out, navigate to home (which will be login page)
                // Since we're using home, we can't use pushReplacementNamed for '/'
                // Instead, we'll push and remove all previous routes
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            }
          }
        });
      }
    });

    // Show loading screen while checking auth state
    if (authState.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'EASACC Browser',
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // Use home instead of initialRoute to avoid null check issues
    // Cannot use home with route '/' in routes, so we exclude '/' from routes
    final homeWidget =
        authState.isAuthenticated ? const SettingsPage() : const LoginPage();

    // Build routes map - exclude '/' (login route) when using home
    final routesMap = <String, WidgetBuilder>{
      AppRoutes.settings: (context) => const SettingsPage(),
      AppRoutes.webView: (context) => const WebViewPage(),
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EASACC Browser',
      theme: AppTheme.light,
      home: homeWidget,
      routes: routesMap,
      // Add onUnknownRoute as final fallback
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const LoginPage());
      },
    );
  }
}

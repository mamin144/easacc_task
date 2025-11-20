import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/permissions/permissions_page.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/view/settings_page.dart';
import 'features/webview/view/webview_page.dart';

class EasaccApp extends ConsumerWidget {
  const EasaccApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EASACC Browser',
      theme: AppTheme.light,
      // Start the app on the Settings page (contains URL input and devices).
      // Permissions are requested only when the user attempts network device
      // actions (for example, pressing Scan) and are handled explicitly by
      // the Settings page flow.
      initialRoute: AppRoutes.settings,
      routes: {
        AppRoutes.permissions: (_) => const PermissionsPage(),
        AppRoutes.settings: (_) => const SettingsPage(),
        AppRoutes.webView: (_) => const WebViewPage(),
      },
    );
  }
}

// Settings page is the app's entry point now; permission checks are
// performed when the user attempts network actions (e.g. scanning).

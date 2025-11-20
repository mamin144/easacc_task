import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/permissions/permissions_controller.dart';
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
      initialRoute: AppRoutes.permissions,
      routes: {
        AppRoutes.permissions: (_) => const PermissionsPage(),
        AppRoutes.settings: (_) => const _GuardedSettingsPage(),
        AppRoutes.webView: (_) => const _GuardedWebViewPage(),
      },
    );
  }
}

class _GuardedSettingsPage extends ConsumerWidget {
  const _GuardedSettingsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermissions = ref.watch(
      permissionsControllerProvider.select((s) => s.hasAllPermissions),
    );

    if (!hasPermissions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.permissions);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return const SettingsPage();
  }
}

class _GuardedWebViewPage extends ConsumerWidget {
  const _GuardedWebViewPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermissions = ref.watch(
      permissionsControllerProvider.select((s) => s.hasAllPermissions),
    );

    if (!hasPermissions) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.permissions);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return const WebViewPage();
  }
}

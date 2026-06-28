import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'routes.dart';

class CloudOrionApp extends StatelessWidget {
  const CloudOrionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloud Orion Assessment',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'routes.dart';
import '../data/providers/recent_files_provider.dart';

class XlsViewApp extends StatelessWidget {
  const XlsViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => RecentFilesProvider()..init(),
        ),
      ],
      child: MaterialApp.router(
        title: 'XLSX File Viewer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}

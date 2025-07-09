import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/recent_files/recent_files_screen.dart';
import '../presentation/screens/file_viewer/file_viewer_screen.dart';
import '../presentation/screens/about/about_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String home = '/home';
  static const String recentFiles = '/recent-files';
  static const String fileViewer = '/file-viewer';
  static const String about = '/about';

  // GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Home Screen
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Recent Files Screen
      GoRoute(
        path: recentFiles,
        name: 'recent-files',
        builder: (context, state) => const RecentFilesScreen(),
      ),

      // File Viewer Screen
      GoRoute(
        path: fileViewer,
        name: 'file-viewer',
        builder: (context, state) {
          final filePath = state.uri.queryParameters['filePath'] ?? '';
          return FileViewerScreen(filePath: filePath);
        },
      ),

      // About Screen
      GoRoute(
        path: about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri}" could not be found.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Extension for easy navigation
extension GoRouterExtension on BuildContext {
  // Navigation methods
  void goToHome() => go(AppRoutes.home);
  void goToRecentFiles() => go(AppRoutes.recentFiles);
  void goToAbout() => go(AppRoutes.about);
  void goToFileViewer(String filePath) =>
      go('${AppRoutes.fileViewer}?filePath=$filePath');

  // Push methods
  void pushHome() => push(AppRoutes.home);
  void pushRecentFiles() => push(AppRoutes.recentFiles);
  void pushAbout() => push(AppRoutes.about);
  void pushFileViewer(String filePath) =>
      push('${AppRoutes.fileViewer}?filePath=$filePath');
}

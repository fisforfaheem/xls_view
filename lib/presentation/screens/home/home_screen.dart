import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/dimensions.dart';
import '../../../app/routes.dart';
import '../../../core/services/file_service.dart';
import '../../../data/providers/recent_files_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'widgets/file_management_illustration.dart';
import 'widgets/action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: AppStrings.home, showBackButton: false),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppDimensions.spacingLg),

                // File Management Illustration
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const FileManagementIllustration(),
                ),

                const SizedBox(height: AppDimensions.spacingXxl),

                // Action Buttons
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // View xlsx File Button
                        ActionButton(
                          icon: Icons.table_view_rounded,
                          title: AppStrings.viewXlsxFile,
                          onPressed: () => _handleViewXlsxFile(context),
                          delay: 0,
                        ),

                        const SizedBox(height: AppDimensions.spacingLg),

                        // Recent Files Button
                        ActionButton(
                          icon: Icons.history_rounded,
                          title: AppStrings.recentFilesButton,
                          onPressed: () => context.pushRecentFiles(),
                          delay: 100,
                        ),

                        const SizedBox(height: AppDimensions.spacingLg),

                        // About Us Button
                        ActionButton(
                          icon: Icons.info_outline_rounded,
                          title: AppStrings.aboutUsButton,
                          onPressed: () => context.pushAbout(),
                          delay: 200,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingXl),

                // Bottom decorative element
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background,
                          AppColors.primary.withAlpha(26),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXl,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleViewXlsxFile(BuildContext context) async {
    final fileService = FileService();
    final recentFilesProvider = Provider.of<RecentFilesProvider>(
      context,
      listen: false,
    );

    try {
      final files = await fileService.pickXlsFiles(allowMultiple: false);

      if (files == null || files.isEmpty) {
        return; // User cancelled or no files selected
      }

      final file = files.first;

      // Add to recent files
      await recentFilesProvider.addRecentFile(file);

      // Navigate to file viewer
      if (context.mounted) {
        context.pushFileViewer(file.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

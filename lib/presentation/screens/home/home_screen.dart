import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/dimensions.dart';
import '../../../app/routes.dart';
import '../../../core/services/file_service.dart';
import '../../../data/providers/recent_files_provider.dart';
import '../../widgets/common/custom_app_bar.dart';

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
      body: Column(
        children: [
          // Main content area with illustration
          Expanded(
            child: Container(
              width: double.infinity,
              color: AppColors.background,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingLg),
                    child: Image.asset(
                      'assets/images/background image.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom action buttons section
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingXl),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // View xlsx File Button
                        _buildStyledButton(
                          icon: Icons.table_view_rounded,
                          title: AppStrings.viewXlsxFile,
                          onPressed: () => _handleViewXlsxFile(context),
                          delay: 0,
                        ),

                        const SizedBox(height: AppDimensions.spacingLg),

                        // Recent Files Button
                        _buildStyledButton(
                          icon: Icons.history_rounded,
                          title: AppStrings.recentFilesButton,
                          onPressed: () => context.pushRecentFiles(),
                          delay: 100,
                        ),

                        const SizedBox(height: AppDimensions.spacingLg),

                        // About Us Button
                        _buildStyledButton(
                          icon: Icons.person_outline_rounded,
                          title: AppStrings.aboutUsButton,
                          onPressed: () => context.pushAbout(),
                          delay: 200,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyledButton({
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
    required int delay,
  }) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          onTap: onPressed,
          child: Row(
            children: [
              // Left arrow section
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
                child: ClipPath(
                  clipper: _ArrowClipper(),
                  child: Container(
                    color: AppColors.primary,
                    child: Icon(
                      icon,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              // Title section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
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

class _ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // Start from top-left
    path.moveTo(0, 0);
    
    // Line to top-right minus arrow width
    path.lineTo(size.width - 15, 0);
    
    // Arrow point to the right
    path.lineTo(size.width, size.height / 2);
    
    // Line back to bottom-right minus arrow width
    path.lineTo(size.width - 15, size.height);
    
    // Line to bottom-left
    path.lineTo(0, size.height);
    
    // Close the path
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

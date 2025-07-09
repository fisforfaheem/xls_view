import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/dimensions.dart';
import '../../widgets/common/custom_app_bar.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
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

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
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
      appBar: const CustomAppBar(title: AppStrings.aboutUs),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppDimensions.spacingXl),

                // App logo and title
                _buildAppHeader(),

                const SizedBox(height: AppDimensions.spacingXxl),

                // App description
                _buildAppDescription(),

                const SizedBox(height: AppDimensions.spacingXl),

                // App info cards
                _buildAppInfoCards(),

                const SizedBox(height: AppDimensions.spacingXl),

                // Action buttons
                _buildActionButtons(),

                const SizedBox(height: AppDimensions.spacingXl),

                // Footer
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Column(
      children: [
        // App logo
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.table_chart, size: 50, color: Colors.white),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingMd),

        // App name
        Text(
          AppStrings.appName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppDimensions.spacingSm),

        // Version
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMd,
            vertical: AppDimensions.paddingSm,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: Text(
            '${AppStrings.version} ${AppStrings.appVersion}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppDescription() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.grey200, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        AppStrings.aboutDescription,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAppInfoCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Icons.table_chart_outlined,
                title: 'File Support',
                description: 'XLS & XLSX files',
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: _buildInfoCard(
                icon: Icons.devices_rounded,
                title: 'Cross Platform',
                description: 'iOS, Android, Web',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Icons.history_rounded,
                title: 'Recent Files',
                description: 'Quick access history',
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
            Expanded(
              child: _buildInfoCard(
                icon: Icons.share_rounded,
                title: 'Easy Sharing',
                description: 'Share files instantly',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.grey200, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.primary),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Share app button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _shareApp,
            icon: const Icon(Icons.share_rounded),
            label: const Text('Share App'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingMd,
              ),
            ),
          ),
        ),

        const SizedBox(height: AppDimensions.spacingMd),

        // Rate app button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _rateApp,
            icon: const Icon(Icons.star_rounded),
            label: const Text('Rate App'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingMd,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        const Divider(thickness: 1),
        const SizedBox(height: AppDimensions.spacingMd),

        // Developer info
        Text(
          'Made with ❤️ by Flutter Developer',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
        ),

        const SizedBox(height: AppDimensions.spacingSm),

        // Copyright
        Text(
          '© 2024 Xlsx FileReader. All rights reserved.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
        ),

        const SizedBox(height: AppDimensions.spacingMd),

        // Links
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _showPrivacyPolicy,
              child: const Text(AppStrings.privacyPolicy),
            ),
            const Text(' • '),
            TextButton(
              onPressed: _showTermsOfService,
              child: const Text(AppStrings.termsOfService),
            ),
          ],
        ),
      ],
    );
  }

  void _shareApp() {
    Share.share(
      'Check out ${AppStrings.appName} - A modern XLS file reader app!\n\n'
      'View and manage your Excel files with ease.',
      subject: 'Share ${AppStrings.appName}',
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Thank you for your interest! Rating feature will be available soon.',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.privacyPolicy),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy\n\n'
            'This app respects your privacy. We do not collect, store, or share any personal information.\n\n'
            'File Access: The app only accesses files you explicitly select for viewing.\n\n'
            'Local Storage: Recent files are stored locally on your device for convenience.\n\n'
            'No Data Sharing: Your files and data are never shared with third parties.\n\n'
            'For questions about privacy, please contact us.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.termsOfService),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service\n\n'
            'By using this app, you agree to the following terms:\n\n'
            'Use License: This app is provided for viewing Excel files only.\n\n'
            'File Responsibility: You are responsible for the files you open and share.\n\n'
            'No Warranty: The app is provided "as is" without warranty.\n\n'
            'Updates: We may update these terms from time to time.\n\n'
            'Contact us for questions about these terms.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/dimensions.dart';
import '../../widgets/common/custom_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: AppStrings.aboutUs),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppDimensions.spacingXl),

            // Company logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8FF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    color: const Color(0xFF6B73FF),
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXl),

            // Company name
            Text(
              'Apex & Co LLC',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.spacingMd),

            // Company tagline
            Text(
              'Providing IT & HR Solutions for Businesses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.spacingLg),

            // Description
            Text(
              'Your Trusted Partner For Recruitment, Staffing, Software Development, Digital Marketing, and BPO Services.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),

            // const SizedBox(height: AppDimensions.spacingXl * 2),

            // Team illustration placeholder
            // Container(
            //   width: double.infinity,
            //   height: 200,
            //   decoration: BoxDecoration(
            //     color: Colors.grey[100],
            //     borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            //   ),
            //   child: Center(
            //     child: Icon(Icons.group, size: 80, color: Colors.grey[400]),
            //   ),
            // ),
            const SizedBox(height: AppDimensions.spacingXl * 2),

            // Version info
            Text(
              'App Version: 1.0.0',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: AppDimensions.spacingXl),

            // Action buttons
            _buildActionButton(
              context: context,
              icon: Icons.share,
              title: 'Share App',
              onPressed: () => _shareApp(),
            ),

            const SizedBox(height: AppDimensions.spacingLg),

            _buildActionButton(
              context: context,
              icon: Icons.star_outline,
              title: 'Rate App',
              onPressed: () => _rateApp(context),
            ),

            // const SizedBox(height: AppDimensions.spacingLg),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLg,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _shareApp() {
    Share.share(
      'Check out XLSX File Viewer by Apex & Co LLC!\n\n'
      'A beautiful and intuitive Excel file viewer app built with Flutter.\n\n'
      'Features:\n'
      '• View Excel files easily\n'
      '• Clean and modern interface\n'
      '• Cross-platform support\n'
      '• Recent files tracking\n\n'
      'Download now and make viewing Excel files a breeze!\n\n'
      'Developed by Apex & Co LLC - Your Trusted Partner for IT & HR Solutions.',
      subject: 'XLSX File Viewer - Apex & Co LLC',
    );
  }

  void _rateApp(BuildContext context) async {
    // For Android - Google Play Store
    const androidUrl =
        'https://play.google.com/store/apps/details?id=com.apexcollc.xlsxfileviewer.xlsxreader.smartxlsxviewer';

    // For iOS - App Store
    const iosUrl =
        'https://apps.apple.com/app/id1234567890'; // Replace with actual App Store ID

    try {
      // Try to open the appropriate store based on platform
      if (Theme.of(context).platform == TargetPlatform.android) {
        if (await canLaunchUrl(Uri.parse(androidUrl))) {
          await launchUrl(
            Uri.parse(androidUrl),
            mode: LaunchMode.externalApplication,
          );
        } else {
          _showRateDialog(context);
        }
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        if (await canLaunchUrl(Uri.parse(iosUrl))) {
          await launchUrl(
            Uri.parse(iosUrl),
            mode: LaunchMode.externalApplication,
          );
        } else {
          _showRateDialog(context);
        }
      } else {
        _showRateDialog(context);
      }
    } catch (e) {
      _showRateDialog(context);
    }
  }

  void _showRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rate Our App'),
          content: const Text(
            'We would love to hear your feedback! Please rate our app on your app store.\n\n'
            'Your rating helps us improve and reach more users who need a simple Excel file viewer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Maybe Later',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

class FileManagementIllustration extends StatelessWidget {
  const FileManagementIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background browser window
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.grey200, width: 1),
              ),
              child: Column(
                children: [
                  // Browser header
                  Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMd,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.radiusMd),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Browser dots
                        Row(
                          children: [
                            _buildDot(Colors.red),
                            const SizedBox(width: 6),
                            _buildDot(Colors.orange),
                            const SizedBox(width: 6),
                            _buildDot(Colors.green),
                          ],
                        ),
                        const SizedBox(width: AppDimensions.spacingMd),
                        // Title
                        Expanded(
                          child: Text(
                            'My Files',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // File grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingMd),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: AppDimensions.spacingMd,
                              crossAxisSpacing: AppDimensions.spacingMd,
                              childAspectRatio: 1.0,
                            ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return _buildFileFolder(index);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Character illustration
          Positioned(
            right: -20,
            bottom: -10,
            child: Container(
              width: 120,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: Stack(
                children: [
                  // Character head
                  Positioned(
                    top: 20,
                    left: 35,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Character body
                  Positioned(
                    top: 60,
                    left: 25,
                    child: Container(
                      width: 70,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg,
                        ),
                      ),
                    ),
                  ),
                  // Character arm holding file
                  Positioned(
                    top: 80,
                    left: 5,
                    child: Container(
                      width: 30,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSm,
                        ),
                      ),
                      child: const Icon(
                        Icons.table_chart,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Decorative plant
          Positioned(
            left: -10,
            bottom: -5,
            child: Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: Stack(
                children: [
                  // Plant pot
                  Positioned(
                    bottom: 0,
                    left: 15,
                    child: Container(
                      width: 30,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSm,
                        ),
                      ),
                    ),
                  ),
                  // Plant leaves
                  Positioned(
                    top: 10,
                    left: 20,
                    child: Container(
                      width: 20,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusLg,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildFileFolder(int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            index == 5 ? Icons.insert_drive_file_rounded : Icons.folder_rounded,
            size: 24,
            color: AppColors.primary,
          ),
          const SizedBox(height: 4),
          Container(height: 2, width: 20, color: AppColors.grey300),
        ],
      ),
    );
  }
}

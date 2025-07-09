import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/strings.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool showMessage;
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.showMessage = true,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3.0,
            ),
          ),
          if (showMessage) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              message ?? AppStrings.loading,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

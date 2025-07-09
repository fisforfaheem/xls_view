import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../data/models/excel_data_model.dart';

class SheetTabs extends StatefulWidget {
  final List<ExcelSheet> sheets;
  final int activeIndex;
  final Function(int) onSheetChanged;

  const SheetTabs({
    super.key,
    required this.sheets,
    required this.activeIndex,
    required this.onSheetChanged,
  });

  @override
  State<SheetTabs> createState() => _SheetTabsState();
}

class _SheetTabsState extends State<SheetTabs> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
      child: Row(
        children: [
          // Sheet tabs
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: widget.sheets.length,
              itemBuilder: (context, index) {
                final sheet = widget.sheets[index];
                final isActive = index == widget.activeIndex;

                return Padding(
                  padding: const EdgeInsets.only(
                    right: AppDimensions.spacingSm,
                  ),
                  child: _buildSheetTab(sheet, index, isActive),
                );
              },
            ),
          ),

          // Scroll arrows if needed
          if (widget.sheets.length > 3) ...[
            const SizedBox(width: AppDimensions.spacingSm),
            _buildScrollButton(Icons.arrow_left, () => _scrollLeft()),
            const SizedBox(width: AppDimensions.spacingXs),
            _buildScrollButton(Icons.arrow_right, () => _scrollRight()),
          ],
        ],
      ),
    );
  }

  Widget _buildSheetTab(ExcelSheet sheet, int index, bool isActive) {
    return GestureDetector(
      onTap: () => widget.onSheetChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingMd,
          vertical: AppDimensions.paddingSm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.grey200,
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 16,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Text(
              sheet.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isActive ? Colors.white : AppColors.textPrimary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingXs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
              ),
              child: Text(
                '${sheet.rowCount}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isActive ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.grey200),
      ),
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        color: AppColors.textSecondary,
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}

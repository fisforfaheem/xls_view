import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/strings.dart';
import '../../data/models/file_model.dart';

class FileItem extends StatefulWidget {
  final FileModel file;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDeleteOption;

  const FileItem({
    super.key,
    required this.file,
    this.onTap,
    this.onDelete,
    this.showDeleteOption = false,
  });

  @override
  State<FileItem> createState() => _FileItemState();
}

class _FileItemState extends State<FileItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
              padding: const EdgeInsets.all(AppDimensions.paddingMd),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: AppColors.grey200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  onTap: widget.onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingSm),
                    child: Row(
                      children: [
                        // File icon
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _getFileIconColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                          ),
                          child: Icon(
                            _getFileIcon(),
                            size: 24,
                            color: _getFileIconColor(),
                          ),
                        ),

                        const SizedBox(width: AppDimensions.spacingMd),

                        // File info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // File name
                              Text(
                                widget.file.displayName,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: AppDimensions.spacingXs),

                              // File details
                              Row(
                                children: [
                                  // File type
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.paddingSm,
                                      vertical: AppDimensions.paddingXs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getFileIconColor().withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusXs,
                                      ),
                                    ),
                                    child: Text(
                                      widget.file.extension.toUpperCase(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: _getFileIconColor(),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: AppDimensions.spacingSm,
                                  ),

                                  // File size
                                  Text(
                                    widget.file.formattedSize,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppDimensions.spacingXs),

                              // Last opened
                              Text(
                                '${AppStrings.lastOpened}${widget.file.formattedLastOpened}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textHint),
                              ),
                            ],
                          ),
                        ),

                        // Action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Share button
                            IconButton(
                              onPressed: () => _shareFile(context),
                              icon: const Icon(Icons.share_outlined),
                              color: AppColors.textSecondary,
                              tooltip: AppStrings.share,
                            ),

                            // Delete button (if enabled)
                            if (widget.showDeleteOption &&
                                widget.onDelete != null)
                              IconButton(
                                onPressed: () =>
                                    _showDeleteConfirmation(context),
                                icon: const Icon(Icons.delete_outline),
                                color: AppColors.error,
                                tooltip: AppStrings.delete,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getFileIcon() {
    switch (widget.file.extension.toLowerCase()) {
      case 'xlsx':
      case 'xls':
        return Icons.table_chart_outlined;
      case 'csv':
        return Icons.grid_on_outlined;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'doc':
      case 'docx':
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getFileIconColor() {
    switch (widget.file.extension.toLowerCase()) {
      case 'xlsx':
      case 'xls':
        return AppColors.primary;
      case 'csv':
        return AppColors.success;
      case 'pdf':
        return AppColors.error;
      case 'doc':
      case 'docx':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  void _shareFile(BuildContext context) {
    try {
      Share.shareXFiles(
        [XFile(widget.file.path)],
        subject: widget.file.displayName,
        text: 'Sharing ${widget.file.displayName}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing file: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text(
          'Are you sure you want to remove "${widget.file.displayName}" from recent files?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete?.call();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../data/models/excel_data_model.dart';

class FileInfoCard extends StatelessWidget {
  final String filePath;
  final XlsDataModel? excelData;

  const FileInfoCard({super.key, required this.filePath, this.excelData});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),

            const SizedBox(height: AppDimensions.spacingMd),

            // File info
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFileInfoSection(),
                    const SizedBox(height: AppDimensions.spacingMd),
                    if (excelData != null) _buildSheetsInfoSection(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.spacingMd),

            // Actions
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Icon(Icons.info_outline, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'File Information',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (excelData != null)
                Text(
                  excelData!.fileName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildFileInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'File Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),

        _buildInfoRow(
          icon: Icons.folder_outlined,
          label: 'Path',
          value: _getShortPath(filePath),
        ),

        if (excelData != null) ...[
          _buildInfoRow(
            icon: Icons.table_chart_outlined,
            label: 'Total Sheets',
            value: excelData!.sheets.length.toString(),
          ),

          _buildInfoRow(
            icon: Icons.view_list_outlined,
            label: 'Total Rows',
            value: excelData!.totalRows.toString(),
          ),

          _buildInfoRow(
            icon: Icons.grid_on_outlined,
            label: 'Total Cells',
            value: excelData!.totalCells.toString(),
          ),

          _buildInfoRow(
            icon: Icons.schedule_outlined,
            label: 'Last Modified',
            value: _formatDate(excelData!.lastModified),
          ),
        ],
      ],
    );
  }

  Widget _buildSheetsInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sheets Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),

        ...excelData!.sheets.asMap().entries.map((entry) {
          final index = entry.key;
          final sheet = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.table_chart_outlined,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Expanded(
                      child: Text(
                        sheet.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (index == excelData!.activeSheetIndex)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusXs,
                          ),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Row(
                  children: [
                    Text(
                      'Rows: ${sheet.rows.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Text(
                      'Columns: ${sheet.maxColumns}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: () => _shareFile(),
          icon: const Icon(Icons.share_outlined, size: 16),
          label: const Text('Share'),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  String _getShortPath(String path) {
    final parts = path.split('/');
    if (parts.length > 3) {
      return '.../${parts.sublist(parts.length - 2).join('/')}';
    }
    return path;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _shareFile() {
    Share.shareXFiles(
      [XFile(filePath)],
      subject: excelData?.fileName ?? 'XLS File',
      text: 'Sharing XLS file: ${excelData?.fileName ?? 'file'}',
    );
  }
}

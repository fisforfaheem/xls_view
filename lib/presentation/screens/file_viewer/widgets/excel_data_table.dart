import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../data/models/excel_data_model.dart';

class ExcelDataTable extends StatefulWidget {
  final XlsSheet sheet;
  final String searchQuery;

  const ExcelDataTable({
    super.key,
    required this.sheet,
    required this.searchQuery,
  });

  @override
  State<ExcelDataTable> createState() => _ExcelDataTableState();
}

class _ExcelDataTableState extends State<ExcelDataTable> {
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.sheet.hasData) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sheet info
        _buildSheetInfo(),

        // Data table
        Expanded(child: _buildDataTable()),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.table_chart_outlined, size: 64, color: AppColors.textHint),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'No data in this sheet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMd,
        vertical: AppDimensions.paddingSm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.table_chart_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Text(
            '${widget.sheet.rows.length} rows × ${widget.sheet.maxColumns} columns',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          if (widget.searchQuery.isNotEmpty)
            Text(
              'Search: "${widget.searchQuery}"',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMd),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey200),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Scrollbar(
          controller: _horizontalController,
          thumbVisibility: true,
          child: Scrollbar(
            controller: _verticalController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                controller: _verticalController,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowHeight: 48,
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 40,
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.primary.withAlpha(26),
                  ),
                  columns: _buildColumns(),
                  rows: _buildRows(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    final columns = <DataColumn>[];

    // Add row number column
    columns.add(
      DataColumn(
        label: Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            '#',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );

    // Add data columns
    for (int i = 0; i < widget.sheet.maxColumns; i++) {
      columns.add(
        DataColumn(
          label: Container(
            width: 100,
            alignment: Alignment.center,
            child: Text(
              _getColumnLetter(i),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      );
    }

    return columns;
  }

  List<DataRow> _buildRows() {
    final rows = <DataRow>[];
    final filteredRows = _getFilteredRows();

    for (int rowIndex = 0; rowIndex < filteredRows.length; rowIndex++) {
      final row = filteredRows[rowIndex];
      final cells = <DataCell>[];

      // Add row number cell
      cells.add(
        DataCell(
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '${row.index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );

      // Add data cells
      for (int colIndex = 0; colIndex < widget.sheet.maxColumns; colIndex++) {
        final cellValue = widget.sheet.getCellValue(row.index, colIndex);
        final isHighlighted =
            widget.searchQuery.isNotEmpty &&
            cellValue.toLowerCase().contains(widget.searchQuery);

        cells.add(
          DataCell(
            Container(
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                cellValue,
                style: TextStyle(
                  color: isHighlighted
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: isHighlighted
                      ? FontWeight.bold
                      : FontWeight.normal,
                  backgroundColor: isHighlighted
                      ? AppColors.primary.withAlpha(26)
                      : null,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            onTap: () => _showCellDetails(row.index, colIndex, cellValue),
          ),
        );
      }

      rows.add(DataRow(cells: cells));
    }

    return rows;
  }

  List<XlsRow> _getFilteredRows() {
    if (widget.searchQuery.isEmpty) {
      return widget.sheet.rows;
    }

    return widget.sheet.rows.where((row) {
      return row.cells.any(
        (cell) => cell.value.toLowerCase().contains(widget.searchQuery),
      );
    }).toList();
  }

  String _getColumnLetter(int columnIndex) {
    String result = '';
    while (columnIndex >= 0) {
      result = String.fromCharCode(65 + (columnIndex % 26)) + result;
      columnIndex = (columnIndex / 26).floor() - 1;
    }
    return result;
  }

  void _showCellDetails(int row, int column, String value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cell ${_getColumnLetter(column)}${row + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Value:', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Text(
                value.isEmpty ? '(empty)' : value,
                style: TextStyle(
                  color: value.isEmpty
                      ? AppColors.textHint
                      : AppColors.textPrimary,
                  fontStyle: value.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

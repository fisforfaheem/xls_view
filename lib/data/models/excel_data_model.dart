class ExcelDataModel {
  final String fileName;
  final List<ExcelSheet> sheets;
  final int activeSheetIndex;
  final DateTime lastModified;

  ExcelDataModel({
    required this.fileName,
    required this.sheets,
    this.activeSheetIndex = 0,
    required this.lastModified,
  });

  ExcelSheet get activeSheet => sheets[activeSheetIndex];

  bool get hasMultipleSheets => sheets.length > 1;

  int get totalRows => sheets.fold(0, (sum, sheet) => sum + sheet.rows.length);

  int get totalCells => sheets.fold(0, (sum, sheet) => sum + sheet.totalCells);

  ExcelDataModel copyWith({
    String? fileName,
    List<ExcelSheet>? sheets,
    int? activeSheetIndex,
    DateTime? lastModified,
  }) {
    return ExcelDataModel(
      fileName: fileName ?? this.fileName,
      sheets: sheets ?? this.sheets,
      activeSheetIndex: activeSheetIndex ?? this.activeSheetIndex,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

class ExcelSheet {
  final String name;
  final List<ExcelRow> rows;
  final int maxColumns;

  ExcelSheet({
    required this.name,
    required this.rows,
    required this.maxColumns,
  });

  int get totalCells => rows.fold(0, (sum, row) => sum + row.cells.length);

  bool get isEmpty => rows.isEmpty;

  int get rowCount => rows.length;

  int get columnCount => maxColumns;

  // Get cell value at specific position
  String getCellValue(int row, int column) {
    if (row >= rows.length || column >= maxColumns) {
      return '';
    }

    final excelRow = rows[row];
    if (column >= excelRow.cells.length) {
      return '';
    }

    return excelRow.cells[column].value;
  }

  // Get row data
  List<String> getRowData(int rowIndex) {
    if (rowIndex >= rows.length) {
      return [];
    }

    return rows[rowIndex].cells.map((cell) => cell.value).toList();
  }

  // Get column data
  List<String> getColumnData(int columnIndex) {
    if (columnIndex >= maxColumns) {
      return [];
    }

    return rows.map((row) {
      if (columnIndex < row.cells.length) {
        return row.cells[columnIndex].value;
      }
      return '';
    }).toList();
  }

  // Search for text in the sheet
  List<CellPosition> searchText(String searchText) {
    final results = <CellPosition>[];
    final lowerSearchText = searchText.toLowerCase();

    for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];
      for (int colIndex = 0; colIndex < row.cells.length; colIndex++) {
        final cell = row.cells[colIndex];
        if (cell.value.toLowerCase().contains(lowerSearchText)) {
          results.add(
            CellPosition(row: rowIndex, column: colIndex, value: cell.value),
          );
        }
      }
    }

    return results;
  }
}

class ExcelRow {
  final int index;
  final List<ExcelCell> cells;

  ExcelRow({required this.index, required this.cells});

  bool get isEmpty => cells.isEmpty;

  int get cellCount => cells.length;

  // Get cell by column index
  ExcelCell? getCellByIndex(int columnIndex) {
    if (columnIndex >= cells.length) {
      return null;
    }
    return cells[columnIndex];
  }
}

class ExcelCell {
  final String value;
  final ExcelCellType type;
  final int row;
  final int column;

  ExcelCell({
    required this.value,
    required this.type,
    required this.row,
    required this.column,
  });

  bool get isEmpty => value.isEmpty;

  bool get isNumeric => type == ExcelCellType.number;

  bool get isText => type == ExcelCellType.text;

  bool get isDate => type == ExcelCellType.date;

  bool get isBoolean => type == ExcelCellType.boolean;

  // Get formatted value based on type
  String get formattedValue {
    switch (type) {
      case ExcelCellType.number:
        final num? number = num.tryParse(value);
        if (number != null) {
          if (number == number.toInt()) {
            return number.toInt().toString();
          }
          return number.toStringAsFixed(2);
        }
        return value;
      case ExcelCellType.date:
        final DateTime? date = DateTime.tryParse(value);
        if (date != null) {
          return '${date.day}/${date.month}/${date.year}';
        }
        return value;
      case ExcelCellType.boolean:
        return value.toLowerCase() == 'true' ? 'Yes' : 'No';
      default:
        return value;
    }
  }

  // Get cell reference (e.g., A1, B2)
  String get cellReference {
    return '${_getColumnLetter(column)}${row + 1}';
  }

  String _getColumnLetter(int columnIndex) {
    String result = '';
    while (columnIndex >= 0) {
      result = String.fromCharCode(65 + (columnIndex % 26)) + result;
      columnIndex = (columnIndex / 26).floor() - 1;
    }
    return result;
  }
}

enum ExcelCellType { text, number, date, boolean, formula }

class CellPosition {
  final int row;
  final int column;
  final String value;

  CellPosition({required this.row, required this.column, required this.value});

  String get cellReference {
    return '${_getColumnLetter(column)}${row + 1}';
  }

  String _getColumnLetter(int columnIndex) {
    String result = '';
    while (columnIndex >= 0) {
      result = String.fromCharCode(65 + (columnIndex % 26)) + result;
      columnIndex = (columnIndex / 26).floor() - 1;
    }
    return result;
  }
}

class ExcelParseResult {
  final ExcelDataModel? data;
  final String? error;
  final bool success;

  ExcelParseResult({this.data, this.error, required this.success});

  factory ExcelParseResult.success(ExcelDataModel data) {
    return ExcelParseResult(data: data, success: true);
  }

  factory ExcelParseResult.error(String error) {
    return ExcelParseResult(error: error, success: false);
  }
}

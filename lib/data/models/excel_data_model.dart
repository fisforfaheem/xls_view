class XlsDataModel {
  final String fileName;
  final List<XlsSheet> sheets;
  final int activeSheetIndex;
  final DateTime lastModified;

  XlsDataModel({
    required this.fileName,
    required this.sheets,
    this.activeSheetIndex = 0,
    required this.lastModified,
  });

  XlsSheet get activeSheet => sheets[activeSheetIndex];

  // Get total number of rows across all sheets
  int get totalRows => sheets.fold(0, (sum, sheet) => sum + sheet.rows.length);

  // Get total number of cells across all sheets
  int get totalCells => sheets.fold(
    0,
    (sum, sheet) =>
        sum + sheet.rows.fold(0, (sum, row) => sum + row.cells.length),
  );

  // Check if has multiple sheets
  bool get hasMultipleSheets => sheets.length > 1;

  XlsDataModel copyWith({
    String? fileName,
    List<XlsSheet>? sheets,
    int? activeSheetIndex,
    DateTime? lastModified,
  }) {
    return XlsDataModel(
      fileName: fileName ?? this.fileName,
      sheets: sheets ?? this.sheets,
      activeSheetIndex: activeSheetIndex ?? this.activeSheetIndex,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}

class XlsSheet {
  final String name;
  final List<XlsRow> rows;
  final int maxColumns;

  XlsSheet({required this.name, required this.rows, this.maxColumns = 0});

  // Get cell value by row and column index
  String getCellValue(int row, int column) {
    if (row >= rows.length) {
      return '';
    }

    final xlsRow = rows[row];
    if (column >= xlsRow.cells.length) {
      return '';
    }

    return xlsRow.cells[column].value;
  }

  // Get cell by row and column index
  XlsCell? getCell(int row, int column) {
    if (row >= rows.length) {
      return null;
    }

    final xlsRow = rows[row];
    if (column >= xlsRow.cells.length) {
      return null;
    }

    return xlsRow.cells[column];
  }

  // Get row by index
  XlsRow? getRow(int index) {
    if (index >= rows.length) {
      return null;
    }
    return rows[index];
  }

  // Get total number of cells in this sheet
  int get totalCells => rows.fold(0, (sum, row) => sum + row.cells.length);

  // Get non-empty rows
  List<XlsRow> get nonEmptyRows => rows.where((row) => row.hasData).toList();

  // Check if sheet has data
  bool get hasData => rows.any((row) => row.hasData);

  // Search for text in sheet
  List<XlsCell> searchCells(String query) {
    final List<XlsCell> results = [];
    for (final row in rows) {
      for (final cell in row.cells) {
        if (cell.value.toLowerCase().contains(query.toLowerCase())) {
          results.add(cell);
        }
      }
    }
    return results;
  }

  // Get column headers (first row)
  List<String> get columnHeaders {
    if (rows.isEmpty) return [];
    return rows.first.cells.map((cell) => cell.value).toList();
  }

  // Get data rows (excluding first row if it's headers)
  List<XlsRow> get dataRows {
    if (rows.length <= 1) return [];
    return rows.skip(1).toList();
  }

  // Get column data
  List<String> getColumnData(int columnIndex) {
    return rows.map((row) {
      if (columnIndex < row.cells.length) {
        return row.cells[columnIndex].value;
      }
      return '';
    }).toList();
  }

  @override
  String toString() {
    return 'XlsSheet(name: $name, rows: ${rows.length}, maxColumns: $maxColumns)';
  }
}

class XlsRow {
  final int index;
  final List<XlsCell> cells;

  XlsRow({required this.index, required this.cells});

  // Check if row has any data
  bool get hasData => cells.any((cell) => cell.value.isNotEmpty);

  // Get cell by column index
  XlsCell? getCellByIndex(int columnIndex) {
    if (columnIndex >= cells.length) {
      return null;
    }
    return cells[columnIndex];
  }

  @override
  String toString() {
    return 'XlsRow(index: $index, cells: ${cells.length})';
  }
}

class XlsCell {
  final String value;
  final XlsCellType type;
  final int row;
  final int column;

  XlsCell({
    required this.value,
    required this.type,
    required this.row,
    required this.column,
  });

  // Type checks
  bool get isNumeric => type == XlsCellType.number;

  bool get isText => type == XlsCellType.text;

  bool get isDate => type == XlsCellType.date;

  bool get isBoolean => type == XlsCellType.boolean;

  // Get formatted value based on type
  String get formattedValue {
    switch (type) {
      case XlsCellType.number:
        final num = double.tryParse(value);
        if (num != null && num == num.toInt()) {
          return num.toInt().toString();
        }
        return value;
      case XlsCellType.date:
        // TODO: Implement date formatting
        return value;
      case XlsCellType.boolean:
        return value.toLowerCase() == 'true' ? 'Yes' : 'No';
      case XlsCellType.text:
      case XlsCellType.formula:
        return value;
    }
  }

  // Get numeric value
  double? get numericValue {
    if (type == XlsCellType.number) {
      return double.tryParse(value);
    }
    return null;
  }

  // Get boolean value
  bool? get booleanValue {
    if (type == XlsCellType.boolean) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }

  // Check if cell is empty
  bool get isEmpty => value.isEmpty;

  // Check if cell has data
  bool get hasData => value.isNotEmpty;

  @override
  String toString() {
    return 'XlsCell(value: $value, type: $type, row: $row, column: $column)';
  }
}

enum XlsCellType { text, number, date, boolean, formula }

// Extension for XlsCellType
extension XlsCellTypeExtension on XlsCellType {
  String get displayName {
    switch (this) {
      case XlsCellType.text:
        return 'Text';
      case XlsCellType.number:
        return 'Number';
      case XlsCellType.date:
        return 'Date';
      case XlsCellType.boolean:
        return 'Boolean';
      case XlsCellType.formula:
        return 'Formula';
    }
  }
}

class XlsParseResult {
  final XlsDataModel? data;
  final String? error;
  final bool success;

  XlsParseResult({this.data, this.error, required this.success});

  factory XlsParseResult.success(XlsDataModel data) {
    return XlsParseResult(data: data, success: true);
  }

  factory XlsParseResult.error(String error) {
    return XlsParseResult(error: error, success: false);
  }
}

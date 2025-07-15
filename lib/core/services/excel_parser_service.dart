import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/excel_data_model.dart';

class XlsParserService {
  /// Parse XLS/XLSX file and convert to XlsDataModel
  Future<XlsParseResult> parseXlsFile(String filePath) async {
    return compute(_parseInIsolate, filePath);
  }

  /// Parse XLS/XLSX file in a separate isolate to prevent UI freeze
  static Future<XlsParseResult> _parseInIsolate(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return XlsParseResult.error('File not found');
      }

      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      if (excel.sheets.isEmpty) {
        return XlsParseResult.error('No sheets found in the XLSX file');
      }

      final sheets = <XlsSheet>[];
      for (final sheetName in excel.sheets.keys) {
        final sheet = excel.sheets[sheetName];
        if (sheet == null) continue;

        final xlsSheet = await _parseSheet(sheet, sheetName);
        if (xlsSheet != null) {
          sheets.add(xlsSheet);
        }
      }

      if (sheets.isEmpty) {
        return XlsParseResult.error('No valid sheets found');
      }

      final xlsData = XlsDataModel(
        fileName: file.path.split('/').last,
        sheets: sheets,
        activeSheetIndex: 0,
        lastModified: await file.lastModified(),
      );

      return XlsParseResult.success(xlsData);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing XLSX file in isolate: $e');
      }
      return XlsParseResult.error('Failed to parse XLSX file: ${e.toString()}');
    }
  }

  /// Parse a single sheet
  static Future<XlsSheet?> _parseSheet(Sheet sheet, String sheetName) async {
    try {
      final rows = <XlsRow>[];
      int maxColumns = 0;

      // Process each row
      for (int rowIndex = 0; rowIndex < sheet.maxRows; rowIndex++) {
        final cells = <XlsCell>[];

        // Process each cell in the row
        for (int colIndex = 0; colIndex < sheet.maxColumns; colIndex++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(
              columnIndex: colIndex,
              rowIndex: rowIndex,
            ),
          );

          final cellValue = _getCellValue(cell);
          final cellType = _getCellType(cell);

          final xlsCell = XlsCell(
            value: cellValue,
            type: cellType,
            row: rowIndex,
            column: colIndex,
          );

          cells.add(xlsCell);
        }

        // Only add row if it has content
        if (cells.any((cell) => cell.value.isNotEmpty)) {
          rows.add(XlsRow(index: rowIndex, cells: cells));
          maxColumns = cells.length > maxColumns ? cells.length : maxColumns;
        }
      }

      return XlsSheet(name: sheetName, rows: rows, maxColumns: maxColumns);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing sheet $sheetName: $e');
      }
      return null;
    }
  }

  /// Get cell value as string
  static String _getCellValue(Data? cell) {
    if (cell == null || cell.value == null) {
      return '';
    }

    final value = cell.value;

    if (value is SharedString) {
      return value.toString();
    }

    // Convert to string based on type
    return value.toString();
  }

  /// Determine cell type
  static XlsCellType _getCellType(Data? cell) {
    if (cell == null || cell.value == null) {
      return XlsCellType.text;
    }

    final value = cell.value;

    if (value is String) {
      return XlsCellType.text;
    } else if (value is int || value is double) {
      return XlsCellType.number;
    } else if (value is bool) {
      return XlsCellType.boolean;
    }

    return XlsCellType.text;
  }
}

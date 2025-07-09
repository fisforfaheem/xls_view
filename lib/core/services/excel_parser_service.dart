import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/excel_data_model.dart';

class ExcelParserService {
  /// Parse Excel file and convert to ExcelDataModel
  Future<ExcelParseResult> parseExcelFile(String filePath) async {
    try {
      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        return ExcelParseResult.error('File not found');
      }

      // Read file bytes
      final bytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;
      final lastModified = await file.lastModified();

      // Parse Excel file
      final excel = Excel.decodeBytes(bytes);

      if (excel.sheets.isEmpty) {
        return ExcelParseResult.error('No sheets found in the Excel file');
      }

      // Convert to our data model
      final sheets = <ExcelSheet>[];

      for (final sheetName in excel.sheets.keys) {
        final sheet = excel.sheets[sheetName];
        if (sheet == null) continue;

        final excelSheet = await _parseSheet(sheet, sheetName);
        if (excelSheet != null) {
          sheets.add(excelSheet);
        }
      }

      if (sheets.isEmpty) {
        return ExcelParseResult.error('No valid sheets found');
      }

      final excelData = ExcelDataModel(
        fileName: fileName,
        sheets: sheets,
        activeSheetIndex: 0,
        lastModified: lastModified,
      );

      return ExcelParseResult.success(excelData);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing Excel file: $e');
      }
      return ExcelParseResult.error(
        'Failed to parse Excel file: ${e.toString()}',
      );
    }
  }

  /// Parse a single sheet
  Future<ExcelSheet?> _parseSheet(Sheet sheet, String sheetName) async {
    try {
      final rows = <ExcelRow>[];
      int maxColumns = 0;

      // Process each row
      for (int rowIndex = 0; rowIndex < sheet.maxRows; rowIndex++) {
        final cells = <ExcelCell>[];

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

          final excelCell = ExcelCell(
            value: cellValue,
            type: cellType,
            row: rowIndex,
            column: colIndex,
          );

          cells.add(excelCell);
        }

        // Only add row if it has content
        if (cells.any((cell) => cell.value.isNotEmpty)) {
          rows.add(ExcelRow(index: rowIndex, cells: cells));
          maxColumns = cells.length > maxColumns ? cells.length : maxColumns;
        }
      }

      return ExcelSheet(name: sheetName, rows: rows, maxColumns: maxColumns);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing sheet $sheetName: $e');
      }
      return null;
    }
  }

  /// Get cell value as string
  String _getCellValue(Data? cell) {
    if (cell == null || cell.value == null) {
      return '';
    }

    final value = cell.value;

    // Convert to string based on type
    return value.toString();
  }

  /// Determine cell type
  ExcelCellType _getCellType(Data? cell) {
    if (cell == null || cell.value == null) {
      return ExcelCellType.text;
    }

    final value = cell.value;

    if (value is String) {
      return ExcelCellType.text;
    } else if (value is int || value is double) {
      return ExcelCellType.number;
    } else if (value is bool) {
      return ExcelCellType.boolean;
    }

    return ExcelCellType.text;
  }

  /// Get sheet names from Excel file
  Future<List<String>> getSheetNames(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return [];
      }

      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      return excel.sheets.keys.toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting sheet names: $e');
      }
      return [];
    }
  }

  /// Get basic file info
  Future<Map<String, dynamic>> getFileInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return {};
      }

      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      int totalSheets = excel.sheets.length;
      int totalRows = 0;
      int totalCells = 0;

      for (final sheet in excel.sheets.values) {
        totalRows += sheet.maxRows;
        totalCells += sheet.maxRows * sheet.maxColumns;
      }

      return {
        'totalSheets': totalSheets,
        'totalRows': totalRows,
        'totalCells': totalCells,
        'sheetNames': excel.sheets.keys.toList(),
        'fileSize': await file.length(),
        'lastModified': await file.lastModified(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file info: $e');
      }
      return {};
    }
  }

  /// Validate Excel file
  Future<bool> validateExcelFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      return excel.sheets.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error validating Excel file: $e');
      }
      return false;
    }
  }

  /// Search text in Excel file
  Future<List<CellPosition>> searchInFile(
    String filePath,
    String searchText,
  ) async {
    try {
      final parseResult = await parseExcelFile(filePath);

      if (!parseResult.success || parseResult.data == null) {
        return [];
      }

      final results = <CellPosition>[];

      for (final sheet in parseResult.data!.sheets) {
        results.addAll(sheet.searchText(searchText));
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('Error searching in file: $e');
      }
      return [];
    }
  }
}

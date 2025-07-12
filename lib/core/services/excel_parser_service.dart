import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/excel_data_model.dart';

class XlsParserService {
  /// Parse XLS/XLSX file and convert to XlsDataModel
  Future<XlsParseResult> parseXlsFile(String filePath) async {
    try {
      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        return XlsParseResult.error('File not found');
      }

      // Read file bytes
      final bytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;
      final lastModified = await file.lastModified();

      // Parse XLS/XLSX file
      final excel = Excel.decodeBytes(bytes);

      if (excel.sheets.isEmpty) {
        return XlsParseResult.error('No sheets found in the XLS file');
      }

      // Convert to our data model
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
        fileName: fileName,
        sheets: sheets,
        activeSheetIndex: 0,
        lastModified: lastModified,
      );

      return XlsParseResult.success(xlsData);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing XLS file: $e');
      }
      return XlsParseResult.error('Failed to parse XLS file: ${e.toString()}');
    }
  }

  /// Parse a single sheet
  Future<XlsSheet?> _parseSheet(Sheet sheet, String sheetName) async {
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
  String _getCellValue(Data? cell) {
    if (cell == null || cell.value == null) {
      return '';
    }

    final value = cell.value;

    // Convert to string based on type
    return value.toString();
  }

  /// Determine cell type
  XlsCellType _getCellType(Data? cell) {
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

  /// Get sheet names from XLS/XLSX file
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

  /// Validate XLS/XLSX file
  Future<bool> validateXlsFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return false;
      }

      // Check file extension
      final fileName = file.path.toLowerCase();
      if (!fileName.endsWith('.xls') && !fileName.endsWith('.xlsx')) {
        return false;
      }

      // Try to parse the file
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      return excel.sheets.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error validating XLS file: $e');
      }
      return false;
    }
  }

  /// Get file statistics
  Future<Map<String, dynamic>> getFileStats(String filePath) async {
    try {
      final parseResult = await parseXlsFile(filePath);
      if (!parseResult.success || parseResult.data == null) {
        return {};
      }

      final xlsData = parseResult.data!;
      int totalRows = 0;
      int totalCells = 0;
      int nonEmptyRows = 0;
      int nonEmptyCells = 0;

      for (final sheet in xlsData.sheets) {
        totalRows += sheet.rows.length;
        for (final row in sheet.rows) {
          if (row.hasData) {
            nonEmptyRows++;
          }
          totalCells += row.cells.length;
          for (final cell in row.cells) {
            if (cell.hasData) {
              nonEmptyCells++;
            }
          }
        }
      }

      return {
        'totalSheets': xlsData.sheets.length,
        'totalRows': totalRows,
        'totalCells': totalCells,
        'nonEmptyRows': nonEmptyRows,
        'nonEmptyCells': nonEmptyCells,
        'fileName': xlsData.fileName,
        'lastModified': xlsData.lastModified,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file stats: $e');
      }
      return {};
    }
  }
}

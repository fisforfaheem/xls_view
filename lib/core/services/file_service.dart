import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../constants/strings.dart';
import '../../data/models/file_model.dart';

class FileService {
  // Supported file extensions
  static const List<String> _supportedExtensions = ['xlsx'];

  // Maximum file size (50MB)
  static const int _maxFileSize = 50 * 1024 * 1024;

  /// Pick XLS/XLSX files from device storage
  Future<List<FileModel>?> pickXlsFiles({bool allowMultiple = false}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _supportedExtensions,
        allowMultiple: allowMultiple,
        allowCompression: false,
        withData: false,
        withReadStream: false,
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final List<FileModel> files = [];

      for (final file in result.files) {
        if (file.path == null) continue;

        // Validate file
        final validationResult = await _validateFile(file);
        if (!validationResult.isValid) {
          if (kDebugMode) {
            print('File validation failed: ${validationResult.error}');
          }
          continue;
        }

        // Create FileModel
        final fileModel = await _createFileModel(file);
        if (fileModel != null) {
          files.add(fileModel);
        }
      }

      return files.isEmpty ? null : files;
    } catch (e) {
      if (kDebugMode) {
        print('Error picking files: $e');
      }
      rethrow;
    }
  }

  /// Validate a single file
  Future<FileValidationResult> _validateFile(PlatformFile file) async {
    // Check if file path exists
    if (file.path == null) {
      return FileValidationResult(isValid: false, error: 'File path is null');
    }

    final fileObj = File(file.path!);

    // Check if file exists
    if (!await fileObj.exists()) {
      return FileValidationResult(
        isValid: false,
        error: AppStrings.fileNotFound,
      );
    }

    // Check file extension
    final extension = file.extension?.toLowerCase();
    if (extension == null || !_supportedExtensions.contains(extension)) {
      return FileValidationResult(
        isValid: false,
        error: AppStrings.invalidFileFormat,
      );
    }

    // Check file size
    final fileSize = await fileObj.length();
    if (fileSize > _maxFileSize) {
      return FileValidationResult(
        isValid: false,
        error: AppStrings.fileTooLarge,
      );
    }

    return FileValidationResult(isValid: true);
  }

  /// Create FileModel from PlatformFile
  Future<FileModel?> _createFileModel(PlatformFile file) async {
    try {
      if (file.path == null) return null;

      final fileObj = File(file.path!);
      final fileSize = await fileObj.length();
      final fileName = file.name;
      final extension = file.extension?.toLowerCase() ?? '';

      return FileModel(
        id: _generateFileId(file.path!),
        name: fileName,
        path: file.path!,
        lastOpened: DateTime.now(),
        size: fileSize,
        type: extension,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating file model: $e');
      }
      return null;
    }
  }

  /// Generate unique file ID
  String _generateFileId(String path) {
    return path.hashCode.toString();
  }

  /// Check if file exists
  Future<bool> fileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (e) {
      return false;
    }
  }

  /// Get file size
  Future<int> getFileSize(String path) async {
    try {
      return await File(path).length();
    } catch (e) {
      return 0;
    }
  }

  /// Get file info
  Future<FileInfo?> getFileInfo(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;

      final stat = await file.stat();
      final size = await file.length();
      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();

      return FileInfo(
        name: fileName,
        path: path,
        size: size,
        extension: extension,
        createdAt: stat.changed,
        modifiedAt: stat.modified,
        isDirectory: stat.type == FileSystemEntityType.directory,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting file info: $e');
      }
      return null;
    }
  }

  /// Get app documents directory
  Future<String> getAppDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Get temporary directory
  Future<String> getTempDirectory() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  /// Copy file to app directory
  Future<String?> copyFileToAppDirectory(
    String sourcePath,
    String fileName,
  ) async {
    try {
      final appDir = await getAppDocumentsDirectory();
      final appDirPath = '$appDir/xlsx_files';

      // Create directory if it doesn't exist
      final directory = Directory(appDirPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final targetPath = '$appDirPath/$fileName';
      final sourceFile = File(sourcePath);
      final targetFile = await sourceFile.copy(targetPath);

      return targetFile.path;
    } catch (e) {
      if (kDebugMode) {
        print('Error copying file: $e');
      }
      return null;
    }
  }

  /// Delete file
  Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting file: $e');
      }
      return false;
    }
  }

  /// Get supported file extensions
  List<String> getSupportedExtensions() => _supportedExtensions;

  /// Check if file extension is supported
  bool isFileSupported(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return _supportedExtensions.contains(extension);
  }

  /// Format file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}

/// File validation result
class FileValidationResult {
  final bool isValid;
  final String? error;

  FileValidationResult({required this.isValid, this.error});
}

/// File information
class FileInfo {
  final String name;
  final String path;
  final int size;
  final String extension;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool isDirectory;

  FileInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.extension,
    required this.createdAt,
    required this.modifiedAt,
    required this.isDirectory,
  });

  String get displayName => name.split('.').first;

  String get formattedSize {
    if (size < 1024) {
      return '${size}B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/file_model.dart';
import 'dart:math';

class RecentFilesProvider extends ChangeNotifier {
  static const String _boxName = 'recent_files';
  static const int _maxRecentFiles = 50;

  Box<FileModel>? _box;
  List<FileModel> _recentFiles = [];
  bool _isLoading = false;
  String _searchQuery = '';

  // Getters
  List<FileModel> get recentFiles => _filteredFiles();
  List<FileModel> get allRecentFiles => _recentFiles;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  bool get hasRecentFiles => _recentFiles.isNotEmpty;

  // Initialize Hive box
  Future<void> init() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Register adapter if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(FileModelAdapter());
      }

      // Open box
      _box = await Hive.openBox<FileModel>(_boxName);

      // Load existing files
      _loadRecentFiles();

      // Add some sample data if no files exist (for demo purposes)
      if (_recentFiles.isEmpty) {
        await _addSampleFiles();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error initializing recent files: $e');
      }
    }
  }

  // Load recent files from Hive
  void _loadRecentFiles() {
    if (_box == null) return;

    _recentFiles = _box!.values.toList();

    // Sort by last opened (most recent first)
    _recentFiles.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));

    // Limit to max recent files
    if (_recentFiles.length > _maxRecentFiles) {
      _recentFiles = _recentFiles.take(_maxRecentFiles).toList();
    }
  }

  // Add a file to recent files
  Future<void> addRecentFile(FileModel file) async {
    if (_box == null) return;

    try {
      // Check if file already exists
      final existingIndex = _recentFiles.indexWhere((f) => f.path == file.path);

      if (existingIndex != -1) {
        // Update existing file's last opened time
        final existingFile = _recentFiles[existingIndex];
        final updatedFile = existingFile.copyWith(lastOpened: DateTime.now());

        await _box!.put(updatedFile.id, updatedFile);
        _recentFiles[existingIndex] = updatedFile;
      } else {
        // Add new file
        await _box!.put(file.id, file);
        _recentFiles.insert(0, file);
      }

      // Sort by last opened
      _recentFiles.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));

      // Limit to max recent files
      if (_recentFiles.length > _maxRecentFiles) {
        final filesToRemove = _recentFiles.skip(_maxRecentFiles).toList();
        for (final file in filesToRemove) {
          await _box!.delete(file.id);
        }
        _recentFiles = _recentFiles.take(_maxRecentFiles).toList();
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding recent file: $e');
      }
    }
  }

  // Remove a file from recent files
  Future<void> removeRecentFile(String fileId) async {
    if (_box == null) return;

    try {
      await _box!.delete(fileId);
      _recentFiles.removeWhere((file) => file.id == fileId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error removing recent file: $e');
      }
    }
  }

  // Clear all recent files
  Future<void> clearAllRecentFiles() async {
    if (_box == null) return;

    try {
      await _box!.clear();
      _recentFiles.clear();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing recent files: $e');
      }
    }
  }

  // Search functionality
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  // Filter files based on search query
  List<FileModel> _filteredFiles() {
    if (_searchQuery.isEmpty) {
      return _recentFiles;
    }

    return _recentFiles.where((file) {
      return file.displayName.toLowerCase().contains(_searchQuery) ||
          file.extension.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  // Refresh recent files
  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500)); // Simulate refresh
    _loadRecentFiles();

    _isLoading = false;
    notifyListeners();
  }

  // Add sample files for demo
  Future<void> _addSampleFiles() async {
    final sampleFiles = [
      FileModel(
        id: 'sample_1',
        name: 'Sales_Report_2024.xlsx',
        path: '/documents/Sales_Report_2024.xlsx',
        lastOpened: DateTime.now().subtract(const Duration(hours: 2)),
        size: 1024 * 500, // 500KB
        type: 'xlsx',
      ),
      FileModel(
        id: 'sample_2',
        name: 'Employee_Data.xlsx',
        path: '/documents/Employee_Data.xlsx',
        lastOpened: DateTime.now().subtract(const Duration(days: 1)),
        size: 1024 * 1024 * 2, // 2MB
        type: 'xlsx',
      ),
      FileModel(
        id: 'sample_3',
        name: 'Budget_Analysis.xls',
        path: '/documents/Budget_Analysis.xls',
        lastOpened: DateTime.now().subtract(const Duration(days: 2)),
        size: 1024 * 750, // 750KB
        type: 'xls',
      ),
      FileModel(
        id: 'sample_4',
        name: 'Inventory_List.xlsx',
        path: '/documents/Inventory_List.xlsx',
        lastOpened: DateTime.now().subtract(const Duration(days: 3)),
        size: 1024 * 1024 * 1, // 1MB
        type: 'xlsx',
      ),
      FileModel(
        id: 'sample_5',
        name: 'Customer_Database.xlsx',
        path: '/documents/Customer_Database.xlsx',
        lastOpened: DateTime.now().subtract(const Duration(days: 5)),
        size: 1024 * 1024 * 3, // 3MB
        type: 'xlsx',
      ),
    ];

    for (final file in sampleFiles) {
      await addRecentFile(file);
    }
  }

  // Get file by ID
  FileModel? getFileById(String id) {
    try {
      return _recentFiles.firstWhere((file) => file.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get files by type
  List<FileModel> getFilesByType(String type) {
    return _recentFiles.where((file) => file.type == type).toList();
  }

  // Get files opened today
  List<FileModel> getFilesOpenedToday() {
    final today = DateTime.now();
    return _recentFiles.where((file) {
      return file.lastOpened.day == today.day &&
          file.lastOpened.month == today.month &&
          file.lastOpened.year == today.year;
    }).toList();
  }

  // Get files opened this week
  List<FileModel> getFilesOpenedThisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return _recentFiles.where((file) {
      return file.lastOpened.isAfter(weekStart);
    }).toList();
  }

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }
}

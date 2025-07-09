import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/services/excel_parser_service.dart';
import '../../../data/models/excel_data_model.dart';
import '../../../data/providers/recent_files_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/loading_widget.dart';
import 'widgets/excel_data_table.dart';
import 'widgets/sheet_tabs.dart';
import 'widgets/file_info_card.dart';

class FileViewerScreen extends StatefulWidget {
  final String filePath;

  const FileViewerScreen({super.key, required this.filePath});

  @override
  State<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends State<FileViewerScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final ExcelParserService _excelParser = ExcelParserService();
  ExcelDataModel? _excelData;
  bool _isLoading = true;
  String? _errorMessage;
  int _activeSheetIndex = 0;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadExcelFile();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadExcelFile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final parseResult = await _excelParser.parseExcelFile(widget.filePath);

      if (parseResult.success && parseResult.data != null) {
        setState(() {
          _excelData = parseResult.data;
          _isLoading = false;
        });

        // Update recent files
        if (mounted) {
          _updateRecentFiles();
        }

        _fadeController.forward();
      } else {
        setState(() {
          _errorMessage = parseResult.error ?? 'Failed to load file';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading file: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _updateRecentFiles() {
    final recentFilesProvider = Provider.of<RecentFilesProvider>(
      context,
      listen: false,
    );
    // This would typically create a FileModel from the current file
    // For now, we'll skip this implementation
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _excelData?.fileName ?? 'File Viewer',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExcelFile,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showFileInfo,
            tooltip: 'File Info',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading Excel file...');
    }

    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_excelData == null) {
      return _buildErrorView();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // Sheet tabs (if multiple sheets)
          if (_excelData!.hasMultipleSheets) _buildSheetTabs(),

          // Data table
          Expanded(child: _buildDataTable()),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              'Error Loading File',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingXl),
            ElevatedButton.icon(
              onPressed: _loadExcelFile,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Search in sheet...',
          hintStyle: TextStyle(color: AppColors.textHint),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            borderSide: BorderSide(color: AppColors.grey200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
      ),
    );
  }

  Widget _buildSheetTabs() {
    return SheetTabs(
      sheets: _excelData!.sheets,
      activeIndex: _activeSheetIndex,
      onSheetChanged: (index) {
        setState(() {
          _activeSheetIndex = index;
        });
      },
    );
  }

  Widget _buildDataTable() {
    final activeSheet = _excelData!.sheets[_activeSheetIndex];

    return ExcelDataTable(sheet: activeSheet, searchQuery: _searchQuery);
  }

  void _showFileInfo() {
    showDialog(
      context: context,
      builder: (context) =>
          FileInfoCard(filePath: widget.filePath, excelData: _excelData),
    );
  }
}

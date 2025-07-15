import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/dimensions.dart';
import '../../../app/routes.dart';
import '../../../data/providers/recent_files_provider.dart';
import '../../../data/models/file_model.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/file_item.dart';
import '../../widgets/common/loading_widget.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/search_bar_widget.dart';

class RecentFilesScreen extends StatefulWidget {
  const RecentFilesScreen({super.key});

  @override
  State<RecentFilesScreen> createState() => _RecentFilesScreenState();
}

class _RecentFilesScreenState extends State<RecentFilesScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _listController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _listController, curve: Curves.easeOutCubic),
        );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _listController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _listController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: AppStrings.recentFiles,
        actions: [
          Consumer<RecentFilesProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) => _handleMenuAction(value, provider),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 18),
                        SizedBox(width: 12),
                        Text(AppStrings.refresh),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all, size: 18),
                        SizedBox(width: 12),
                        Text('Clear All'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<RecentFilesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingWidget();
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingMd),
                  child: SearchBarWidget(
                    controller: _searchController,
                    onChanged: (query) => provider.setSearchQuery(query),
                    onClear: () {
                      _searchController.clear();
                      provider.setSearchQuery('');
                    },
                  ),
                ),

                // File list
                Expanded(
                  child: provider.hasRecentFiles
                      ? _buildFileList(provider)
                      : SlideTransition(
                          position: _slideAnimation,
                          child: const EmptyStateWidget(),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFileList(RecentFilesProvider provider) {
    final files = provider.recentFiles;

    if (files.isEmpty && provider.searchQuery.isNotEmpty) {
      return SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppColors.textHint,
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Text(
                'No files found for "${provider.searchQuery}"',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                'Try adjusting your search terms',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      color: AppColors.primary,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMd,
            vertical: AppDimensions.paddingSm,
          ),
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            return FileItem(
              file: file,
              onTap: () => _openFile(file),
              onDelete: () => _deleteFile(provider, file),
              showDeleteOption: true,
            );
          },
        ),
      ),
    );
  }

  void _handleMenuAction(String action, RecentFilesProvider provider) {
    switch (action) {
      case 'refresh':
        provider.refresh();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Refreshed recent files'),
            backgroundColor: AppColors.success,
          ),
        );
        break;
      case 'clear_all':
        _showClearAllConfirmation(provider);
        break;
    }
  }

  void _showClearAllConfirmation(RecentFilesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Recent Files'),
        content: const Text(
          'Are you sure you want to clear all recent files? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.clearAllRecentFiles();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All recent files cleared'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _openFile(FileModel file) {
    // Update last opened time
    final provider = Provider.of<RecentFilesProvider>(context, listen: false);
    provider.addRecentFile(file.copyWith(lastOpened: DateTime.now()));

    // Navigate to file viewer
    context.pushFileViewer(file.path);
  }

  void _deleteFile(RecentFilesProvider provider, FileModel file) {
    provider.removeRecentFile(file.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${file.displayName} removed from recent files'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () => provider.addRecentFile(file),
        ),
      ),
    );
  }
}

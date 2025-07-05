import 'dart:io';

import 'package:cultura/presentation/translation/translation_loading_screen.dart';
import 'package:cultura/presentation/translation/translation_result_page.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cultura/common/constants.dart';
import 'package:cultura/common/services/document_scanning_service.dart';
import 'package:cultura/common/helpers/navigator/app_navigator.dart';

enum MediaType { all, documents, audio, images }

class MediaLibraryPage extends StatefulWidget {
  const MediaLibraryPage({super.key});

  @override
  State<MediaLibraryPage> createState() => _MediaLibraryPageState();
}

class _MediaLibraryPageState extends State<MediaLibraryPage> {
  MediaType selectedFilter = MediaType.all;
  List<MediaItem> mediaItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMediaItems();
  }

  Future<void> _loadMediaItems() async {
    setState(() => isLoading = true);

    try {
      final documentService = DocumentScanningService();
      final documents = await documentService.getSavedDocuments();

      // Convert documents to media items with proper type detection
      final documentItems = documents
          .map((doc) => MediaItem(
                id: doc.id,
                name: doc.fileName,
                type: _getMediaTypeFromFileType(
                    doc.fileType), // Updated this line
                filePath: doc.localPath,
                fileSize: doc.fileSize,
                createdAt: doc.scannedAt,
                icon: getDocumentIcon(doc.fileType),
                metadata: {
                  'fileType': doc.fileType,
                  'size': doc.formattedFileSize,
                },
              ))
          .toList();

      // TODO: Add audio items when audio service is implemented
      // TODO: Add image items when image service is implemented

      setState(() {
        mediaItems = documentItems;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      // Handle error
    }
  }

  // Update the _getMediaTypeFromFileType method to only support specified types
  MediaItemType _getMediaTypeFromFileType(String fileType) {
    final lowerFileType = fileType.toLowerCase();

    // Image types - only jpg, jpeg, png
    if (['jpg', 'jpeg', 'png'].contains(lowerFileType)) {
      return MediaItemType.image;
    }

    // Document types - pdf, doc, docx (default for all others)
    return MediaItemType.document;
  }

// Simplify the thumbnail method to use only HugeIcons
  IconData getDocumentIcon(String fileType) {
    final lowerFileType = fileType.toLowerCase();

    // Image files
    if (['jpg', 'jpeg', 'png'].contains(lowerFileType)) {
      return HugeIcons.strokeRoundedImage01;
    }

    // PDF files
    if (lowerFileType == 'pdf') {
      return HugeIcons.strokeRoundedFile02;
    }

    // Word documents
    if (['doc', 'docx'].contains(lowerFileType)) {
      return HugeIcons.strokeRoundedFileEdit;
    }

    // Default document icon
    return HugeIcons.strokeRoundedFile02;
  }

  List<MediaItem> get filteredItems {
    switch (selectedFilter) {
      case MediaType.all:
        return mediaItems;
      case MediaType.documents:
        return mediaItems
            .where((item) => item.type == MediaItemType.document)
            .toList();
      case MediaType.audio:
        return mediaItems
            .where((item) => item.type == MediaItemType.audio)
            .toList();
      case MediaType.images:
        return mediaItems
            .where((item) => item.type == MediaItemType.image)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.grey[800]),
        title: Text(
          'Media Library',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon:
                Icon(HugeIcons.strokeRoundedSearch01, color: Colors.grey[600]),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            child: FilterTabs(
              selectedFilter: selectedFilter,
              onFilterChanged: (filter) {
                setState(() => selectedFilter = filter);
              },
            ),
          ),
          // Content
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                    ? EmptyState(selectedFilter: selectedFilter)
                    : MediaGrid(
                        mediaItems: filteredItems,
                        onItemTap: _showMediaActions,
                        onItemDelete: _deleteMediaItem,
                      ),
          ),
        ],
      ),
    );
  }

  void _showMediaActions(MediaItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MediaActionsBottomSheet(
        mediaItem: item,
        onTranslate: () => _translateMedia(item),
        onAskQuestions: () => _askQuestionsAboutMedia(item),
      ),
    );
  }

  // Update the _translateMedia method in MediaLibraryPage:
  void _translateMedia(MediaItem item) {
    Navigator.pop(context); // Close bottom sheet

    // Navigate to loading screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TranslationLoadingScreen(
          fileName: item.name,
          onTranslationComplete: (result) {
            // Navigate to result page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => TranslationResultPage(
                  translationResult: result,
                ),
              ),
            );
          },
          onError: (error) {
            // Go back and show error
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      ),
    );
  }

  void _askQuestionsAboutMedia(MediaItem item) {
    Navigator.pop(context);
    // TODO: Navigate to Q&A page with media item
    print('Ask questions about: ${item.name}');
  }

  Future<void> _deleteMediaItem(MediaItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Media'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (item.type == MediaItemType.document) {
        final documentService = DocumentScanningService();
        await documentService.deleteDocument(item.id);
      }
      // TODO: Handle deletion for other media types

      _loadMediaItems(); // Refresh the list
    }
  }
}

// Filter Tabs Widget
class FilterTabs extends StatelessWidget {
  const FilterTabs({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final MediaType selectedFilter;
  final ValueChanged<MediaType> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', MediaType.all),
                  SizedBox(width: 12),
                  _buildFilterChip('Documents', MediaType.documents),
                  SizedBox(width: 12),
                  _buildFilterChip('Audio', MediaType.audio),
                  SizedBox(width: 12),
                  _buildFilterChip('Images', MediaType.images),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, MediaType type) {
    final isSelected = selectedFilter == type;
    return GestureDetector(
      onTap: () => onFilterChanged(type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFFF6B35) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Media Grid Widget
class MediaGrid extends StatelessWidget {
  const MediaGrid({
    super.key,
    required this.mediaItems,
    required this.onItemTap,
    required this.onItemDelete,
  });

  final List<MediaItem> mediaItems;
  final ValueChanged<MediaItem> onItemTap;
  final ValueChanged<MediaItem> onItemDelete;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.65,
      ),
      itemCount: mediaItems.length,
      itemBuilder: (context, index) {
        final item = mediaItems[index];
        return MediaCard(
          mediaItem: item,
          onTap: () => onItemTap(item),
          onDelete: () => onItemDelete(item),
        );
      },
    );
  }
}

class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    required this.mediaItem,
    required this.onTap,
    required this.onDelete,
  });

  final MediaItem mediaItem;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Stack(
                  children: [
                    // Show actual image preview for image files, otherwise show icon
                    if (mediaItem.type == MediaItemType.image)
                      _buildImagePreview()
                    else
                      Center(
                        child: Icon(
                          mediaItem.icon,
                          size: 40,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    // Delete button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onDelete,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    // Type badge
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTypeBadgeColor().withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getTypeLabel(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mediaItem.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      mediaItem.metadata['size'] ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Spacer(),
                    Text(
                      _formatDate(mediaItem.createdAt),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      child: Image.file(
        File(mediaItem.filePath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to icon if image fails to load
          return Center(
            child: Icon(
              HugeIcons.strokeRoundedImage01,
              size: 40,
              color: Color(0xFFFF6B35),
            ),
          );
        },
      ),
    );
  }

  Color _getTypeBadgeColor() {
    switch (mediaItem.type) {
      case MediaItemType.document:
        return Colors.blue;
      case MediaItemType.image:
        return Colors.green;
      default:
        return Colors.green;
    }
  }

  String _getTypeLabel() {
    switch (mediaItem.type) {
      case MediaItemType.document:
        return 'DOC';
      case MediaItemType.image:
        return 'IMG';
      default:
        return 'AUD';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }
}

// Empty State Widget
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.selectedFilter});

  final MediaType selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getEmptyIcon(),
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            _getEmptyTitle(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _getEmptyMessage(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEmptyIcon() {
    switch (selectedFilter) {
      case MediaType.all:
        return HugeIcons.strokeRoundedFolder01;
      case MediaType.documents:
        return HugeIcons.strokeRoundedFile02;
      case MediaType.audio:
        return HugeIcons.strokeRoundedMic01;
      case MediaType.images:
        return HugeIcons.strokeRoundedImage01;
    }
  }

  String _getEmptyTitle() {
    switch (selectedFilter) {
      case MediaType.all:
        return 'No Media Found';
      case MediaType.documents:
        return 'No Documents';
      case MediaType.audio:
        return 'No Audio Files';
      case MediaType.images:
        return 'No Images';
    }
  }

  String _getEmptyMessage() {
    switch (selectedFilter) {
      case MediaType.all:
        return 'Start by scanning documents, recording audio,\nor importing images.';
      case MediaType.documents:
        return 'Scan or import documents to see them here.';
      case MediaType.audio:
        return 'Record audio files to see them here.';
      case MediaType.images:
        return 'Import images to see them here.';
    }
  }
}

// Media Actions Bottom Sheet
class MediaActionsBottomSheet extends StatelessWidget {
  const MediaActionsBottomSheet({
    super.key,
    required this.mediaItem,
    required this.onTranslate,
    required this.onAskQuestions,
  });

  final MediaItem mediaItem;
  final VoidCallback onTranslate;
  final VoidCallback onAskQuestions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),
          // Media info
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFFFF6B35).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(),
                  color: Color(0xFFFF6B35),
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mediaItem.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      mediaItem.metadata['size'] ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          // Actions
          ActionTile(
            icon: HugeIcons.strokeRoundedTranslate,
            title: 'Translate',
            subtitle: 'Translate content to another language',
            onTap: onTranslate,
          ),
          SizedBox(height: 15),
          ActionTile(
            icon: HugeIcons.strokeRoundedQuestion,
            title: 'Ask Questions',
            subtitle: 'Get AI-powered answers about this content',
            onTap: onAskQuestions,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (mediaItem.type) {
      case MediaItemType.document:
        return HugeIcons.strokeRoundedFile02;
      case MediaItemType.audio:
        return HugeIcons.strokeRoundedMic01;
      case MediaItemType.image:
        return HugeIcons.strokeRoundedImage01;
    }
  }
}

// Action Tile Widget
class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: Color(0xFFFF6B35),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Data Models
enum MediaItemType { document, audio, image }

class MediaItem {
  final String id;
  final String name;
  final MediaItemType type;
  final String filePath;
  final int fileSize;
  final DateTime createdAt;
  final IconData icon;
  final Map<String, String> metadata;

  MediaItem({
    required this.id,
    required this.name,
    required this.type,
    required this.filePath,
    required this.fileSize,
    required this.createdAt,
    required this.icon,
    required this.metadata,
  });
}

import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cultura/common/services/document_scanning_service.dart';

class FileImportService {
  static final FileImportService _instance = FileImportService._internal();
  factory FileImportService() => _instance;
  FileImportService._internal();

  /// Import documents from device storage
  Future<List<String>?> importDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final documentService = DocumentScanningService();
        final files = <File>[];

        // Convert PlatformFile to File objects
        for (final file in result.files) {
          if (file.path != null) {
            files.add(File(file.path!));
          }
        }

        // Import all documents at once
        final savedDocuments = await documentService.importDocuments(files);
        
        if (savedDocuments.isNotEmpty) {
          return savedDocuments.map((doc) => doc.localPath).toList();
        }
      }
      
      return null;
    } catch (e) {
      log('Import error: $e');
      return null;
    }
  }

  /// Import single document
  Future<String?> importSingleDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final sourceFile = File(result.files.single.path!);
        final documentService = DocumentScanningService();
        
        final savedDoc = await documentService.saveImportedDocument(sourceFile);
        if (savedDoc != null) {
          // Save to preferences
          await documentService.saveDocumentsToPreferences([savedDoc]);
          return savedDoc.localPath;
        }
      }
      
      return null;
    } catch (e) {
      log('Single import error: $e');
      return null;
    }
  }

  /// Get supported file extensions
  List<String> get supportedExtensions => ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'];

  /// Check if file type is supported
  bool isSupportedFileType(String extension) {
    return supportedExtensions.contains(extension.toLowerCase().replaceAll('.', ''));
  }
}
import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:cultura/common/models/scan_result.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class DocumentScanningService {
  static final DocumentScanningService _instance =
      DocumentScanningService._internal();
  factory DocumentScanningService() => _instance;
  DocumentScanningService._internal();

  static const String _scannedDocumentsKey = 'scanned_documents';
  static const String _documentsDirectoryName = 'scanned_documents';

  // Update the DocumentScanningService scanDocument method
  Future<ScanResult> scanDocument({
    int maxPages = 10,
    bool allowGallery = true,
    bool allowCamera = true,
    Function()? onSuccess, // Add callback for successful scanning
  }) async {
    try {
      final scannedDoc = await FlutterDocScanner().getScanDocuments(
        page: maxPages,
      );

      log('Scanned doc result: $scannedDoc'); // Debug log
      log('Scanned doc type: ${scannedDoc.runtimeType}'); // Debug log

      if (scannedDoc != null) {
        List<String> filePaths = [];

        // Handle different return types from the scanner
        if (scannedDoc is List) {
          // If it's already a list, convert to strings
          filePaths = scannedDoc
              .map((item) => _convertUriToPath(item.toString()))
              .toList();
        } else if (scannedDoc is Map) {
          // The scanner returns a map with 'pdfUri' and 'pageCount'
          if (scannedDoc.containsKey('pdfUri')) {
            final pdfUri = scannedDoc['pdfUri'];
            if (pdfUri is String) {
              filePaths = [_convertUriToPath(pdfUri)];
            }
          } else if (scannedDoc.containsKey('documents')) {
            final docs = scannedDoc['documents'];
            if (docs is List) {
              filePaths = docs
                  .map((item) => _convertUriToPath(item.toString()))
                  .toList();
            }
          } else if (scannedDoc.containsKey('paths')) {
            final paths = scannedDoc['paths'];
            if (paths is List) {
              filePaths = paths
                  .map((item) => _convertUriToPath(item.toString()))
                  .toList();
            }
          } else if (scannedDoc.containsKey('files')) {
            final files = scannedDoc['files'];
            if (files is List) {
              filePaths = files
                  .map((item) => _convertUriToPath(item.toString()))
                  .toList();
            }
          } else {
            // Try to get all values that look like file paths or URIs
            filePaths = scannedDoc.values
                .where((value) =>
                    value is String &&
                    (_isFileUri(value.toString()) ||
                        value.toString().contains('/')))
                .map((value) => _convertUriToPath(value.toString()))
                .toList();
          }
        } else if (scannedDoc is String) {
          // Single file path or URI
          filePaths = [_convertUriToPath(scannedDoc)];
        }

        log('Extracted file paths: $filePaths'); // Debug log

        if (filePaths.isNotEmpty) {
          // Validate that files exist and save them locally
          final savedDocuments = <ScannedDocument>[];

          for (final path in filePaths) {
            if (path.isNotEmpty) {
              final file = File(path);
              if (await file.exists()) {
                log('Valid file found: $path');

                // Save the document locally
                final savedDoc = await _saveDocumentLocally(file);
                if (savedDoc != null) {
                  savedDocuments.add(savedDoc);
                }
              } else {
                log('File does not exist: $path');
                // Also try to check if the original URI works
                if (_isFileUri(path)) {
                  final uri = Uri.parse(path);
                  final uriFile = File.fromUri(uri);
                  if (await uriFile.exists()) {
                    log('Valid file found using URI: ${uriFile.path}');
                    final savedDoc = await _saveDocumentLocally(uriFile);
                    if (savedDoc != null) {
                      savedDocuments.add(savedDoc);
                    }
                  }
                }
              }
            }
          }

          if (savedDocuments.isNotEmpty) {
            // Save to SharedPreferences
            await saveDocumentsToPreferences(savedDocuments);

            // Call success callback if provided
            if (onSuccess != null) {
              log('Successss--------------------->');

              onSuccess();
              log('Successss--------------------->');
            }

            return ScanResult.success(
                savedDocuments.map((doc) => doc.localPath).toList());
          } else {
            return ScanResult.error('No valid scanned files found');
          }
        } else {
          return ScanResult.error('No file paths found in scan result');
        }
      } else {
        return ScanResult.cancelled();
      }
    } catch (e) {
      log('Scanning error: $e'); // Debug log
      return ScanResult.error('Failed to scan document: ${e.toString()}');
    }
  }

  /// Save document to local app directory
  Future<ScannedDocument?> _saveDocumentLocally(File sourceFile) async {
    try {
      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final documentsDir = Directory('${appDir.path}/$_documentsDirectoryName');

      // Create directory if it doesn't exist
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _getFileExtension(sourceFile.path);
      final fileName = 'scanned_doc_$timestamp$extension';
      final localPath = '${documentsDir.path}/$fileName';

      // Copy file to local directory
      final localFile = await sourceFile.copy(localPath);

      // Get file info
      final fileSize = await localFile.length();
      final scannedAt = DateTime.now();

      final scannedDoc = ScannedDocument(
        id: timestamp.toString(),
        fileName: fileName,
        localPath: localPath,
        fileSize: fileSize,
        scannedAt: scannedAt,
        fileType: _getFileType(extension),
      );

      log('Document saved locally: $localPath');
      return scannedDoc;
    } catch (e) {
      log('Error saving document locally: $e');
      return null;
    }
  }

  /// Save documents list to SharedPreferences
  Future<void> saveDocumentsToPreferences(
      List<ScannedDocument> newDocuments) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing documents
      final existingDocs = await getSavedDocuments();

      // Add new documents
      existingDocs.addAll(newDocuments);

      // Convert to JSON and save
      final documentsJson = existingDocs.map((doc) => doc.toJson()).toList();
      await prefs.setString(_scannedDocumentsKey, jsonEncode(documentsJson));

      log('Documents saved to preferences: ${newDocuments.length} new documents');
    } catch (e) {
      log('Error saving documents to preferences: $e');
    }
  }

  Future<ScannedDocument?> saveImportedDocument(File sourceFile) async {
    return await _saveDocumentLocally(sourceFile);
  }

  /// Import and save multiple documents
  Future<List<ScannedDocument>> importDocuments(List<File> files) async {
    final savedDocuments = <ScannedDocument>[];

    for (final file in files) {
      final savedDoc = await _saveDocumentLocally(file);
      if (savedDoc != null) {
        savedDocuments.add(savedDoc);
      }
    }

    if (savedDocuments.isNotEmpty) {
      await saveDocumentsToPreferences(savedDocuments);
    }

    return savedDocuments;
  }

  /// Get all saved documents from SharedPreferences
  Future<List<ScannedDocument>> getSavedDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final documentsJson = prefs.getString(_scannedDocumentsKey);

      if (documentsJson != null) {
        final List<dynamic> jsonList = jsonDecode(documentsJson);
        return jsonList.map((json) => ScannedDocument.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      log('Error getting saved documents: $e');
      return [];
    }
  }

  /// Delete a document
  Future<bool> deleteDocument(String documentId) async {
    try {
      final documents = await getSavedDocuments();
      final docIndex = documents.indexWhere((doc) => doc.id == documentId);

      if (docIndex != -1) {
        final document = documents[docIndex];

        // Delete physical file
        final file = File(document.localPath);
        if (await file.exists()) {
          await file.delete();
        }

        // Remove from list
        documents.removeAt(docIndex);

        // Save updated list
        final prefs = await SharedPreferences.getInstance();
        final documentsJson = documents.map((doc) => doc.toJson()).toList();
        await prefs.setString(_scannedDocumentsKey, jsonEncode(documentsJson));

        log('Document deleted: $documentId');
        return true;
      }

      return false;
    } catch (e) {
      log('Error deleting document: $e');
      return false;
    }
  }

  /// Clear all saved documents
  Future<void> clearAllDocuments() async {
    try {
      // Get all documents
      final documents = await getSavedDocuments();

      // Delete all physical files
      for (final doc in documents) {
        final file = File(doc.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_scannedDocumentsKey);

      // Delete documents directory if empty
      final appDir = await getApplicationDocumentsDirectory();
      final documentsDir = Directory('${appDir.path}/$_documentsDirectoryName');
      if (await documentsDir.exists()) {
        final contents = await documentsDir.list().toList();
        if (contents.isEmpty) {
          await documentsDir.delete();
        }
      }

      log('All documents cleared');
    } catch (e) {
      log('Error clearing documents: $e');
    }
  }

  /// Convert file URI to file system path
  String _convertUriToPath(String uriOrPath) {
    try {
      if (_isFileUri(uriOrPath)) {
        final uri = Uri.parse(uriOrPath);
        return uri.path;
      } else {
        return uriOrPath;
      }
    } catch (e) {
      log('Error converting URI to path: $e');
      return uriOrPath; // Return original if conversion fails
    }
  }

  /// Check if string is a file URI
  bool _isFileUri(String value) {
    return value.startsWith('file://');
  }

  /// Get file extension
  String _getFileExtension(String filePath) {
    final lastDot = filePath.lastIndexOf('.');
    if (lastDot != -1 && lastDot < filePath.length - 1) {
      return filePath.substring(lastDot);
    }
    return '.pdf'; // Default extension
  }

  /// Get file type from extension
  String _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return 'PDF';
      case '.jpg':
      case '.jpeg':
        return 'JPEG';
      case '.png':
        return 'PNG';
      default:
        return 'Unknown';
    }
  }

  /// Validates if the scanned file exists and is accessible
  Future<bool> validateScannedFile(String filePath) async {
    try {
      // Try as regular file path first
      File file = File(filePath);
      if (await file.exists()) {
        return true;
      }

      // If it's a URI, try using File.fromUri
      if (_isFileUri(filePath)) {
        final uri = Uri.parse(filePath);
        file = File.fromUri(uri);
        return await file.exists();
      }

      return false;
    } catch (e) {
      log('Error validating file: $e');
      return false;
    }
  }

  /// Gets file size in bytes
  Future<int?> getFileSize(String filePath) async {
    try {
      // Try as regular file path first
      File file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }

      // If it's a URI, try using File.fromUri
      if (_isFileUri(filePath)) {
        final uri = Uri.parse(filePath);
        file = File.fromUri(uri);
        if (await file.exists()) {
          return await file.length();
        }
      }

      return null;
    } catch (e) {
      log('Error getting file size: $e');
      return null;
    }
  }

  /// Formats file size to human readable format
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get total storage used by documents
  Future<int> getTotalStorageUsed() async {
    try {
      final documents = await getSavedDocuments();
      int totalBytes = 0;

      for (final doc in documents) {
        final file = File(doc.localPath);
        if (await file.exists()) {
          totalBytes += await file.length();
        }
      }

      return totalBytes;
    } catch (e) {
      log('Error calculating total storage: $e');
      return 0;
    }
  }
}

/// Model class for scanned documents
class ScannedDocument {
  final String id;
  final String fileName;
  final String localPath;
  final int fileSize;
  final DateTime scannedAt;
  final String fileType;

  ScannedDocument({
    required this.id,
    required this.fileName,
    required this.localPath,
    required this.fileSize,
    required this.scannedAt,
    required this.fileType,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'localPath': localPath,
      'fileSize': fileSize,
      'scannedAt': scannedAt.toIso8601String(),
      'fileType': fileType,
    };
  }

  factory ScannedDocument.fromJson(Map<String, dynamic> json) {
    return ScannedDocument(
      id: json['id'],
      fileName: json['fileName'],
      localPath: json['localPath'],
      fileSize: json['fileSize'],
      scannedAt: DateTime.parse(json['scannedAt']),
      fileType: json['fileType'],
    );
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024)
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(scannedAt);

    if (difference.inDays > 7) {
      return '${scannedAt.day}/${scannedAt.month}/${scannedAt.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

import 'package:cultura/common/services/translation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';

class TranslationResultPage extends StatefulWidget {
  const TranslationResultPage({
    super.key,
    required this.translationResult,
  });

  final TranslationResult translationResult;

  @override
  State<TranslationResultPage> createState() => _TranslationResultPageState();
}

class _TranslationResultPageState extends State<TranslationResultPage> {
  late PdfViewerController _pdfViewerController;
  Uint8List? _pdfBytes;
  bool _isGeneratingPdf = true;
  String? _pdfPath;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _generatePdfFromMarkdown();
  }

  Future<void> _generatePdfFromMarkdown() async {
    try {
      setState(() => _isGeneratingPdf = true);

      // Create a new PDF document
      final PdfDocument document = PdfDocument();
      final PdfPage page = document.pages.add();
      PdfGraphics graphics = page.graphics;

      // Set up fonts and styles
      final PdfFont titleFont = PdfStandardFont(PdfFontFamily.helvetica, 24,
          style: PdfFontStyle.bold);
      final PdfFont headerFont = PdfStandardFont(PdfFontFamily.helvetica, 18,
          style: PdfFontStyle.bold);
      final PdfFont bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 12);

      double yPosition = 50;
      const double leftMargin = 50;
      const double rightMargin = 50;
      final double pageWidth = page.size.width - leftMargin - rightMargin;

      // Parse and render the markdown content
      final lines = widget.translationResult.translatedContent!.split('\n');

      for (final line in lines) {
        if (line.trim().isEmpty) {
          yPosition += 10;
          continue;
        }

        // Check if we need a new page
        if (yPosition > page.size.height - 100) {
          final newPage = document.pages.add();
          graphics = newPage.graphics;
          yPosition = 50;
        }

        if (line.startsWith('# ')) {
          // Main title
          final text = line.substring(2);
          graphics.drawString(
            text,
            titleFont,
            bounds: Rect.fromLTWH(leftMargin, yPosition, pageWidth, 30),
            brush: PdfBrushes.black,
          );
          yPosition += 40;
        } else if (line.startsWith('## ')) {
          // Section header
          final text = line.substring(3);
          graphics.drawString(
            text,
            headerFont,
            bounds: Rect.fromLTWH(leftMargin, yPosition, pageWidth, 25),
            brush: PdfBrushes.darkBlue,
          );
          yPosition += 30;
        } else if (line.startsWith('### ')) {
          // Subsection header
          final text = line.substring(4);
          graphics.drawString(
            text,
            headerFont,
            bounds: Rect.fromLTWH(leftMargin, yPosition, pageWidth, 20),
            brush: PdfBrushes.darkGreen,
          );
          yPosition += 25;
        } else if (line.startsWith('**') && line.endsWith('**')) {
          // Bold text
          final text = line.substring(2, line.length - 2);
          graphics.drawString(
            text,
            PdfStandardFont(PdfFontFamily.helvetica, 12,
                style: PdfFontStyle.bold),
            bounds: Rect.fromLTWH(leftMargin, yPosition, pageWidth, 15),
            brush: PdfBrushes.black,
          );
          yPosition += 20;
        } else if (line.startsWith('- ')) {
          // Bullet point
          final text = line.substring(2);
          graphics.drawString(
            '• $text',
            bodyFont,
            bounds:
                Rect.fromLTWH(leftMargin + 20, yPosition, pageWidth - 20, 15),
            brush: PdfBrushes.black,
          );
          yPosition += 18;
        } else if (line.startsWith('```')) {
          // Code block (skip for now, just add spacing)
          yPosition += 10;
        } else if (line.startsWith('> ')) {
          // Quote
          final text = line.substring(2);
          graphics.drawRectangle(
            brush: PdfBrushes.lightGray,
            bounds: Rect.fromLTWH(leftMargin, yPosition - 2, 4, 16),
          );
          graphics.drawString(
            text,
            PdfStandardFont(PdfFontFamily.helvetica, 12,
                style: PdfFontStyle.italic),
            bounds:
                Rect.fromLTWH(leftMargin + 15, yPosition, pageWidth - 15, 15),
            brush: PdfBrushes.darkGray,
          );
          yPosition += 20;
        } else if (line.trim().startsWith('*') && line.trim() != '---') {
          // Italic text
          final text = line.trim().replaceAll('*', '');
          graphics.drawString(
            text,
            PdfStandardFont(PdfFontFamily.helvetica, 12,
                style: PdfFontStyle.italic),
            bounds: Rect.fromLTWH(leftMargin, yPosition, pageWidth, 15),
            brush: PdfBrushes.darkGray,
          );
          yPosition += 18;
        } else if (line.trim() == '---') {
          // Horizontal line
          graphics.drawLine(
            PdfPen(PdfColor(200, 200, 200), width: 1),
            Offset(leftMargin, yPosition + 5),
            Offset(page.size.width - rightMargin, yPosition + 5),
          );
          yPosition += 20;
        } else if (line.trim().isNotEmpty) {
          // Regular text
          graphics.drawString(
            line,
            bodyFont,
            bounds: Rect.fromLTWH(leftMargin, yPosition, pageWidth, 15),
            brush: PdfBrushes.black,
          );
          yPosition += 18;
        }
      }

      // Save the PDF
      final bytes = await document.save();
      document.dispose();

      // Create a meaningful filename
      final fileName = widget.translationResult.fileName ?? 'document';
      final cleanFileName =
          fileName.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Save to file for sharing
      final directory = await getApplicationDocumentsDirectory();
      final file =
          File('${directory.path}/translated_${cleanFileName}_$timestamp.pdf');
      await file.writeAsBytes(bytes);

      setState(() {
        _pdfBytes = Uint8List.fromList(bytes);
        _pdfPath = file.path;
        _isGeneratingPdf = false;
      });
    } catch (e) {
      setState(() => _isGeneratingPdf = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfPath == null || _isSharing) return;

    setState(() => _isSharing = true);

    try {
      final result = await Share.shareXFiles(
        [XFile(_pdfPath!)],
        text: 'Translated document: ${widget.translationResult.fileName}',
        subject: 'Translation Result - ${widget.translationResult.fileName}',
      );

      if (result.status == ShareResultStatus.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('PDF shared successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSharing = false);
    }
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            Text(
              'Share Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 20),

            // Share PDF option
            _buildShareOption(
              icon: HugeIcons.strokeRoundedShare08,
              title: 'Share PDF',
              subtitle: 'Share the translated document',
              onTap: () {
                Navigator.pop(context);
                _sharePdf();
              },
            ),

            SizedBox(height: 12),

            // Copy file path option
            _buildShareOption(
              icon: HugeIcons.strokeRoundedCopy01,
              title: 'Copy File Path',
              subtitle: 'Copy the PDF file location',
              onTap: () {
                Navigator.pop(context);
                _copyFilePath();
              },
            ),

            SizedBox(height: 12),

            // Save to gallery/downloads option
            _buildShareOption(
              icon: HugeIcons.strokeRoundedDownload01,
              title: 'Save to Downloads',
              subtitle: 'Save PDF to device downloads',
              onTap: () {
                Navigator.pop(context);
                _saveToDownloads();
              },
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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

  Future<void> _copyFilePath() async {
    if (_pdfPath != null) {
      await Clipboard.setData(ClipboardData(text: _pdfPath!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.copy, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('File path copied to clipboard'),
              ],
            ),
            backgroundColor: Color(0xFFFF6B35),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _saveToDownloads() async {
    if (_pdfPath == null) return;

    try {
      // Use share_plus to trigger save to downloads
      await Share.shareXFiles(
        [XFile(_pdfPath!)],
        text: 'Save to Downloads',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.download_done, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('PDF ready to save'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.grey[800]),
        title: Text(
          'Translation Result',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_pdfBytes != null)
            Stack(
              children: [
                IconButton(
                  icon: Icon(HugeIcons.strokeRoundedShare08,
                      color: Colors.grey[600]),
                  onPressed: _isSharing ? null : _showShareOptions,
                ),
                if (_isSharing)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: _isGeneratingPdf
          ? _buildLoadingView()
          : _pdfBytes != null
              ? _buildPdfView()
              : _buildErrorView(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
          ),
          SizedBox(height: 20),
          Text(
            'Generating PDF...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfView() {
    return Column(
      children: [
        // Info bar
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          color: Color(0xFFFF6B35).withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                HugeIcons.strokeRoundedCheckmarkCircle02,
                color: Color(0xFFFF6B35),
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Translation completed for "${widget.translationResult.fileName}"',
                  style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showShareOptions,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        HugeIcons.strokeRoundedShare08,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Share',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // PDF Viewer
        Expanded(
          child: SfPdfViewer.memory(
            _pdfBytes!,
            controller: _pdfViewerController,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            HugeIcons.strokeRoundedAlert02,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 20),
          Text(
            'Failed to generate PDF',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _generatePdfFromMarkdown,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6B35),
              foregroundColor: Colors.white,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }
}

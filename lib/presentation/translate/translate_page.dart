import 'dart:convert';
import 'dart:developer';
import 'package:cultura/common/services/translation_service.dart';
import 'package:cultura/presentation/translate/saved_translation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cultura/common/constants.dart';
import 'package:cultura/common/helpers/navigator/app_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslatePage extends StatefulWidget {
  const TranslatePage({super.key});

  @override
  State<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends State<TranslatePage>
    with TickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  String _translatedText = '';
  String _sourceLanguage = 'EN';
  String _targetLanguage = 'BBJ';
  bool _isTranslating = false;
  bool _showTranslation = false;
  bool _showDetails = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;

  // Mock translation details
  Map<String, dynamic> _translationDetails = {};

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _translateText() async {
    if (_inputController.text.trim().isEmpty) return;

    setState(() {
      _isTranslating = true;
      _showTranslation = false;
    });

    try {
      final translationService = TranslationService();
      log('Starting translation:----------> ');

      final result = await translationService.translateText(
        text: _inputController.text.trim(),
        sourceLanguage: _getLanguageCode(_sourceLanguage),
        targetLanguage: _getLanguageCode(_targetLanguage),
      );

      if (result.isSuccess) {
        _translatedText = result.translatedContent ?? 'Translation failed';
        _translationDetails = result.translationDetails ?? {};

        // Add confidence and source info to details
        _translationDetails['confidence'] = result.confidence ?? 0.0;
        _translationDetails['source'] = result.translationSource ?? 'unknown';
      } else {
        _translatedText = 'Translation failed: ${result.errorMessage}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Translation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      _translatedText = 'Error: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Translation error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isTranslating = false;
      _showTranslation = true;
    });

    _fadeController.forward();
    _slideController.forward();
  }

  String _getLanguageCode(String displayCode) {
    final codeMap = {
      'EN': 'eng',
      'FR': 'fra',
      'FUB': 'fub',
      'BBJ': 'bbj',
    };
    return codeMap[displayCode] ?? displayCode.toLowerCase();
  }

  Future<void> _saveTranslation() async {
    if (_inputController.text.trim().isEmpty || _translatedText.isEmpty) return;

    final translation = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'sourceText': _inputController.text.trim(),
      'translatedText': _translatedText,
      'sourceLanguage': _sourceLanguage,
      'targetLanguage': _targetLanguage,
      'timestamp': DateTime.now().toIso8601String(),
    };

    final prefs = await SharedPreferences.getInstance();
    final savedTranslations = prefs.getStringList('saved_translations') ?? [];
    savedTranslations.insert(0, jsonEncode(translation));

    // Keep only last 50 translations
    if (savedTranslations.length > 50) {
      savedTranslations.removeRange(50, savedTranslations.length);
    }

    await prefs.setStringList('saved_translations', savedTranslations);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(HugeIcons.strokeRoundedCheckmarkCircle02, color: Colors.white),
            SizedBox(width: 12),
            Text('Translation saved successfully'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;

      if (_showTranslation) {
        final tempText = _inputController.text;
        _inputController.text = _translatedText;
        _translatedText = tempText;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _inputController.clear();
      _translatedText = '';
      _showTranslation = false;
      _showDetails = false;
    });
    _fadeController.reset();
    _slideController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Column(
        children: [
          // Header
          TranslateHeader(),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Language selector
                  LanguageSelector(
                    sourceLanguage: _sourceLanguage,
                    targetLanguage: _targetLanguage,
                    onSwap: _swapLanguages,
                    onSourceLanguageChanged: (language) {
                      setState(() => _sourceLanguage = language);
                    },
                    onTargetLanguageChanged: (language) {
                      setState(() => _targetLanguage = language);
                    },
                  ),
                  SizedBox(height: 20),

                  // Input section
                  InputSection(
                    controller: _inputController,
                    focusNode: _inputFocusNode,
                    onTranslate: _translateText,
                    onClear: _clearAll,
                    isTranslating: _isTranslating,
                  ),
                  SizedBox(height: 20),

                  // Translation result
                  if (_showTranslation || _isTranslating)
                    TranslationResult(
                      translatedText: _translatedText,
                      isTranslating: _isTranslating,
                      showDetails: _showDetails,
                      translationDetails: _translationDetails,
                      fadeAnimation: _fadeController,
                      slideAnimation: _slideController,
                      onSave: _saveTranslation,
                      onToggleDetails: () {
                        setState(() => _showDetails = !_showDetails);
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AppNavigator.push(context, SavedTranslationsPage());
        },
        /*Color(0xFF5D340A), Color(0xFFFF8A50) */
        backgroundColor: Color(0xFF5D340A),
        foregroundColor: Colors.white,
        icon: Icon(HugeIcons.strokeRoundedBookmark01),
        label: Text('Saved'),
      ),
    );
  }
}

// Header Component
class TranslateHeader extends StatelessWidget {
  const TranslateHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      child: Stack(
        children: [
          // Background
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF627B3F),
                  Color.fromARGB(255, 151, 221, 52),
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          // Header content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => AppNavigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),

                  // Title
                  Expanded(
                    child: Text(
                      'Translate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // History button
                  GestureDetector(
                    onTap: () {
                      AppNavigator.push(context, SavedTranslationsPage());
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        HugeIcons.strokeRoundedWorkHistory,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Language Selector Component
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.onSwap,
    required this.onSourceLanguageChanged,
    required this.onTargetLanguageChanged,
  });

  final String sourceLanguage;
  final String targetLanguage;
  final VoidCallback onSwap;
  final Function(String) onSourceLanguageChanged;
  final Function(String) onTargetLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Source language
          Expanded(
            child: LanguageButton(
              language: sourceLanguage,
              onTap: () => _showLanguagePicker(context, true),
            ),
          ),

          // Swap button
          GestureDetector(
            onTap: onSwap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF5D340A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                HugeIcons.strokeRoundedArrowDataTransferHorizontal,
                color: Color(0xFF5D340A),
                size: 20,
              ),
            ),
          ),

          // Target language
          Expanded(
            child: LanguageButton(
              language: targetLanguage,
              onTap: () => _showLanguagePicker(context, false),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, bool isSource) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguagePickerBottomSheet(
        isSource: isSource,
        selectedLanguage: isSource ? sourceLanguage : targetLanguage,
        onLanguageSelected: (language) {
          if (isSource) {
            onSourceLanguageChanged(language);
          } else {
            onTargetLanguageChanged(language);
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}

// Language Button Component
class LanguageButton extends StatelessWidget {
  const LanguageButton({
    super.key,
    required this.language,
    required this.onTap,
  });

  final String language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final languageNames = {
      'FUB': 'Fulfulde',
      'BBJ': 'Ghomala',
      'EN': 'English',
      'FR': 'French',
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Text(
              language,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              languageNames[language] ?? language,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Input Section Component
class InputSection extends StatelessWidget {
  const InputSection({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onTranslate,
    required this.onClear,
    required this.isTranslating,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onTranslate;
  final VoidCallback onClear;
  final bool isTranslating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Input field
          TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Enter text to translate...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),

          SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              // Character count
              Text(
                '${controller.text.length}/500',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),

              Spacer(),

              // Clear button
              if (controller.text.isNotEmpty)
                GestureDetector(
                  onTap: onClear,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedDelete02,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

              SizedBox(width: 12),

              // Translate button
              GestureDetector(
                onTap: isTranslating ? null : onTranslate,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      /*LinearGradient(
                      colors: []*/
                      colors: [Color(0xFF5D340A), Color(0xFFFF8A50)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isTranslating
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          'Translate',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Translation Result Component
class TranslationResult extends StatelessWidget {
  const TranslationResult({
    super.key,
    required this.translatedText,
    required this.isTranslating,
    required this.showDetails,
    required this.translationDetails,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onSave,
    required this.onToggleDetails,
  });

  final String translatedText;
  final bool isTranslating;
  final bool showDetails;
  final Map<String, dynamic> translationDetails;
  final AnimationController fadeAnimation;
  final AnimationController slideAnimation;
  final VoidCallback onSave;
  final VoidCallback onToggleDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Translation text
          if (isTranslating)
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFF5D340A)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Translating...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation.drive(
                  Tween(begin: Offset(0, 0.3), end: Offset.zero),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      translatedText,
                      style: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Colors.grey[800],
                      ),
                    ),

                    SizedBox(height: 20),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Copy button
                        ActionButton(
                          icon: HugeIcons.strokeRoundedCopy01,
                          label: 'Copy',
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: translatedText));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Copied to clipboard'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(width: 12),

                        // Save button
                        ActionButton(
                          icon: HugeIcons.strokeRoundedBookmark01,
                          label: 'Save',
                          onTap: onSave,
                        ),

                        SizedBox(width: 12),

                        // Details button
                        ActionButton(
                          icon: HugeIcons.strokeRoundedInformationCircle,
                          label: 'Details',
                          onTap: onToggleDetails,
                        ),

                        // Spacer(),

                        // // Listen button
                        // ActionButton(
                        //   icon: HugeIcons.strokeRoundedVolumeHigh,
                        //   label: 'Listen',
                        //   onTap: () {
                        //     // Handle text-to-speech
                        //   },
                        // ),
                      ],
                    ),

                    // Translation details
                    if (showDetails) ...[
                      SizedBox(height: 20),
                      TranslationDetails(details: translationDetails),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Action Button Component
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[700]),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TranslationDetails extends StatelessWidget {
  const TranslationDetails({super.key, required this.details});

  final Map<String, dynamic> details;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Confidence score
          if (details['confidence'] != null) ...[
            Row(
              children: [
                Icon(Icons.trending_up,
                    size: 16,
                    color: _getConfidenceColor(details['confidence'])),
                SizedBox(width: 8),
                Text(
                  'Confidence: ${(details['confidence'] * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _getConfidenceColor(details['confidence']),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
          ],

          // Translation source
          if (details['source'] != null) ...[
            DetailRow(
              label: 'Source',
              value: _getSourceDescription(details['source']),
            ),
            SizedBox(height: 12),
          ],

          // Match type for local translations
          if (details['matchType'] != null) ...[
            DetailRow(
              label: 'Match Type',
              value: details['matchType'],
            ),
            SizedBox(height: 12),
          ],

          // Original match for fuzzy matches
          if (details['originalMatch'] != null) ...[
            DetailRow(
              label: 'Matched Word',
              value: details['originalMatch'],
            ),
            SizedBox(height: 12),
          ],

          // Alternative translations
          if (details['availableTranslations'] != null &&
              details['availableTranslations'].length > 1) ...[
            Text(
              'Alternative translations:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            ...List.generate(
              details['availableTranslations'].length,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '• ${details['availableTranslations'][index]}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getSourceDescription(String source) {
    switch (source) {
      case 'local_dictionary':
        return 'Local Dictionary';
      case 'api':
        return 'Online Translation';
      case 'api_document':
        return 'Document API';
      default:
        return source;
    }
  }
}

// Detail Row Component
class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// Language Picker Bottom Sheet
class LanguagePickerBottomSheet extends StatelessWidget {
  const LanguagePickerBottomSheet({
    super.key,
    required this.selectedLanguage,
    this.isSource = true,
    required this.onLanguageSelected,
  });

  final String selectedLanguage;
  final bool isSource;
  final Function(String) onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    final sourceLanguages = {
      'EN': 'English',
      'FR': 'French',
    };
    final targetLanguages = {
      'FUB': 'Fulfulde',
      'BBJ': 'Ghomala',
      // 'EN': 'English',
      // 'FR': 'French',
    };

    var languages = isSource ? sourceLanguages : targetLanguages;

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

          // Title
          Text(
            'Select Language',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),

          // Language list
          Flexible(
            // height: 400,
            child: ListView.builder(
              itemCount: languages.length,
              itemBuilder: (context, index) {
                final langCode = languages.keys.elementAt(index);
                final langName = languages[langCode]!;
                final isSelected = langCode == selectedLanguage;

                return GestureDetector(
                  onTap: () => onLanguageSelected(langCode),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(0xFF5D340A).withOpacity(0.1)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? Color(0xFF5D340A) : Colors.grey[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          langCode,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Color(0xFF5D340A)
                                : Colors.grey[800],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            langName,
                            style: TextStyle(
                              color: isSelected
                                  ? Color(0xFF5D340A)
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            HugeIcons.strokeRoundedCheckmarkCircle02,
                            color: Color(0xFF5D340A),
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

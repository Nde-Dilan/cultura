import 'dart:convert';
import 'package:cultura/common/helpers/navigator/app_navigator.dart';
import 'package:cultura/presentation/translate/saved_translation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ...existing imports...

// Recent Translations Section Component
class RecentTranslationsSection extends StatefulWidget {
  const RecentTranslationsSection({super.key});

  @override
  State<RecentTranslationsSection> createState() => _RecentTranslationsSectionState();
}

class _RecentTranslationsSectionState extends State<RecentTranslationsSection> {
  List<Map<String, dynamic>> _recentTranslations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentTranslations();
  }

  Future<void> _loadRecentTranslations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTranslations = prefs.getStringList('saved_translations') ?? [];
      
      // Get the 5 most recent translations
      final recentTranslations = savedTranslations
          .take(5)
          .map((translation) => jsonDecode(translation) as Map<String, dynamic>)
          .toList();
      
      setState(() {
        _recentTranslations = recentTranslations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Translations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Spacer(),
            if (_recentTranslations.isNotEmpty)
              GestureDetector(
                onTap: () {
                  AppNavigator.push(context, SavedTranslationsPage());
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5D340A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 15),
        
        if (_isLoading)
          Container(
            height: 120,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFF5D340A)),
              ),
            ),
          )
        else if (_recentTranslations.isEmpty)
          Container(
            height: 120,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    HugeIcons.strokeRoundedTranslate,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No recent translations',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Start translating to see your history',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recentTranslations.length,
              itemBuilder: (context, index) {
                final translation = _recentTranslations[index];
                return RecentTranslationCard(
                  translation: translation,
                  onTap: () {
                    _showTranslationDetails(context, translation);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  void _showTranslationDetails(BuildContext context, Map<String, dynamic> translation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => TranslationDetailsBottomSheet(translation: translation),
    );
  }
}

// Recent Translation Card Component
class RecentTranslationCard extends StatelessWidget {
  const RecentTranslationCard({
    super.key,
    required this.translation,
    required this.onTap,
  });

  final Map<String, dynamic> translation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sourceText = translation['sourceText'] ?? '';
    final translatedText = translation['translatedText'] ?? '';
    final sourceLanguage = translation['sourceLanguage'] ?? '';
    final targetLanguage = translation['targetLanguage'] ?? '';
    final timestamp = DateTime.parse(translation['timestamp']);
    final timeAgo = _getTimeAgo(timestamp);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: EdgeInsets.only(right: 15),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source text
            Text(
              _truncateText(sourceText, 30),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey[800],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6),
            
            // Translated text
            Text(
              _truncateText(translatedText, 35),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            Spacer(),
            
            // Language and time info
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(0xFF5D340A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$sourceLanguage → $targetLanguage',
                    style: TextStyle(
                      color: Color(0xFF5D340A),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

// Translation Details Bottom Sheet
class TranslationDetailsBottomSheet extends StatelessWidget {
  const TranslationDetailsBottomSheet({
    super.key,
    required this.translation,
  });

  final Map<String, dynamic> translation;

  @override
  Widget build(BuildContext context) {
    final sourceText = translation['sourceText'] ?? '';
    final translatedText = translation['translatedText'] ?? '';
    final sourceLanguage = translation['sourceLanguage'] ?? '';
    final targetLanguage = translation['targetLanguage'] ?? '';
    final timestamp = DateTime.parse(translation['timestamp']);
    final formattedDate = '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 20),
          
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF5D340A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$sourceLanguage → $targetLanguage',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5D340A),
                  ),
                ),
              ),
              Spacer(),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 20),
          
          // Source text section
          Text(
            'Original Text',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              sourceText,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
          
          SizedBox(height: 16),
          
          // Translated text section
          Text(
            'Translation',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF5D340A).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF5D340A).withOpacity(0.2)),
            ),
            child: Text(
              translatedText,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          
          SizedBox(height: 20),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: translatedText));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Translation copied to clipboard'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5D340A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(HugeIcons.strokeRoundedCopy01, size: 18),
                  label: Text('Copy Translation'),
                ),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  AppNavigator.push(context, SavedTranslationsPage());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  foregroundColor: Colors.grey[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('View All'),
              ),
            ],
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ...existing code...
// Saved Translations Page
import 'dart:convert';

import 'package:cultura/common/constants.dart';
import 'package:cultura/common/helpers/navigator/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedTranslationsPage extends StatefulWidget {
  const SavedTranslationsPage({super.key});

  @override
  State<SavedTranslationsPage> createState() => _SavedTranslationsPageState();
}

class _SavedTranslationsPageState extends State<SavedTranslationsPage> {
  List<Map<String, dynamic>> _savedTranslations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedTranslations();
  }

  Future<void> _loadSavedTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTranslations = prefs.getStringList('saved_translations') ?? [];

    setState(() {
      _savedTranslations = savedTranslations
          .map((translation) => jsonDecode(translation) as Map<String, dynamic>)
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteTranslation(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final savedTranslations = prefs.getStringList('saved_translations') ?? [];

    savedTranslations.removeAt(index);
    await prefs.setStringList('saved_translations', savedTranslations);

    setState(() {
      _savedTranslations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Column(
        children: [
          // Header
          Container(
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
                            'Saved Translations',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _savedTranslations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              HugeIcons.strokeRoundedBookmark01,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No saved translations',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Your saved translations will appear here',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(20),
                        itemCount: _savedTranslations.length,
                        itemBuilder: (context, index) {
                          final translation = _savedTranslations[index];
                          return SavedTranslationCard(
                            translation: translation,
                            onDelete: () => _deleteTranslation(index),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// Saved Translation Card Component
class SavedTranslationCard extends StatelessWidget {
  const SavedTranslationCard({
    super.key,
    required this.translation,
    required this.onDelete,
  });

  final Map<String, dynamic> translation;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final timestamp = DateTime.parse(translation['timestamp']);
    final formattedDate =
        '${timestamp.day}/${timestamp.month}/${timestamp.year}';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF5D340A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${translation['sourceLanguage']} → ${translation['targetLanguage']}',
                  style: TextStyle(
                    fontSize: 12,
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
              SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  HugeIcons.strokeRoundedDelete02,
                  size: 18,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Source text
          Text(
            translation['sourceText'],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),

          SizedBox(height: 8),

          // Translated text
          Text(
            translation['translatedText'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),

          SizedBox(height: 12),

          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                      ClipboardData(text: translation['translatedText']));
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
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(HugeIcons.strokeRoundedCopy01,
                          size: 14, color: Colors.grey[600]),
                      SizedBox(width: 6),
                      Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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

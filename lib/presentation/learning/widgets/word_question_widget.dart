import 'package:flutter/material.dart';
import 'package:cultura/data/learning/models/question.dart';
import 'package:cultura/common/constants.dart';

class WordBuildingQuestionWidget extends StatefulWidget {
  final WordBuildingQuestion question;
  final IconData? icon;
  final String? imagePath;
  final Function(String) onAnswer;

  const WordBuildingQuestionWidget({
    super.key,
    required this.question,
    required this.onAnswer,
    this.icon,
    this.imagePath,
  });

  @override
  State<WordBuildingQuestionWidget> createState() =>
      _WordBuildingQuestionWidgetState();
}

class _WordBuildingQuestionWidgetState
    extends State<WordBuildingQuestionWidget> {
  final List<String> selectedSyllables = [];

  void _handleSyllableSelect(String syllable) {
    setState(() {
      selectedSyllables.add(syllable);

      // Check if word is complete
      String currentWord = selectedSyllables.join();
      if (currentWord == widget.question.targetWord ||
          currentWord.length == widget.question.targetWord.length ||
          selectedSyllables.length ==
              widget.question.availableSyllables.length) {
        widget.onAnswer(currentWord);
        Future.delayed(const Duration(seconds: 4), () {
          _handleReset();
        });
      }
    });
  }

  void _handleReset() {
    setState(() {
      selectedSyllables.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(height: mediaHeight(context) / 30),

          // Image or icon
          widget.imagePath != null
              ? (Image.asset(
                widget.imagePath!,
                width: mediaWidth(context) * 0.65,
                height: mediaWidth(context) * 0.65,
              ))
              : (Icon(widget.icon, size: 100, color: Colors.grey)),

          SizedBox(height: mediaHeight(context) / 16),

          // Available syllables
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children:
                widget.question.availableSyllables.map((syllable) {
                  return SizedBox(
                    width: 80,
                    height: 80,
                    child: ElevatedButton(
                      onPressed:
                          selectedSyllables.contains(syllable)
                              ? null
                              : () => _handleSyllableSelect(syllable),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: const Color(
                          0xFF90EE90,
                        ), // Light green color
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        syllable,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),

          Spacer(),
          // Display area for the word being built
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedSyllables.join(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (selectedSyllables.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _handleReset,
                  ),
              ],
            ),
          ),
          SizedBox(height: mediaHeight(context) / 40),
        ],
      ),
    );
  }
}

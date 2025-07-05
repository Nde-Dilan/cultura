// UI Components
import 'package:flutter/material.dart';

class WordTile extends StatelessWidget {
  final String word;
  final bool isSelected;
  final bool isMatched;
  final VoidCallback onTap;

  const WordTile({
    super.key,
    required this.word,
    required this.isSelected,
    required this.isMatched,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isMatched ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: isMatched ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal.shade900 : Colors.teal.shade600,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                word,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

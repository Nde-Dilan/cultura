import 'package:flutter/material.dart';
import 'package:cultura/common/constants.dart';
import 'package:cultura/data/learning/models/choice.dart';

class ChoiceCard extends StatelessWidget {
  final Choice choice;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;
  final BorderRadius borderRadius;

  const ChoiceCard({
    super.key,
    required this.choice,
    required this.onTap,
    this.isSelected = false,
    this.size = 120.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        // width: mediaHeight(context) / 10,
        height: mediaHeight(context) / 3,
        decoration: BoxDecoration(
          color: choice.backgroundColor ?? Colors.white,
          borderRadius: borderRadius,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (choice.imageUrl != null)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Image.asset(choice.imageUrl!, fit: BoxFit.contain),
                    ),
                  ),
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.only(
                        bottomLeft: borderRadius.bottomLeft,
                        bottomRight: borderRadius.bottomRight,
                      ),
                    ),
                    child: Text(
                      textAlign: TextAlign.center,
                      choice.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

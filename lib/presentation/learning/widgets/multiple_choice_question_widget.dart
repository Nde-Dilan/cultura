// lib/widgets/multiple_choice_question_widget.dart
import 'package:flutter/material.dart';
import 'package:cultura/common/constants.dart';
import 'package:cultura/data/learning/models/question.dart';
import 'package:cultura/presentation/learning/widgets/choice_card.dart';
import 'package:cultura/presentation/learning/widgets/question_card.dart';

class MultipleChoiceQuestionWidget extends StatelessWidget {
  final MultipleChoiceQuestion question;
  final Function(String) onAnswer;

  const MultipleChoiceQuestionWidget({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return QuestionCard(
      question: question,
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            itemCount: question.choices.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: mediaHeight(context) / 22,
              crossAxisSpacing: mediaWidth(context) / 22,
              // childAspectRatio: 1.5,
            ),
            itemBuilder: (context, index) {
              return ChoiceCard(
                choice: question.choices[index],
                onTap: () => onAnswer(question.choices[index].value),
              );
            },
          ),
        ],
      ),
    );
  }
}

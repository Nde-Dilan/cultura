// lib/widgets/question_card.dart
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:cultura/common/constants.dart';
import 'package:cultura/data/learning/models/question.dart';
import 'package:cultura/presentation/learning/widgets/question_card.dart';

Logger _log = Logger("fill_blank_question_widget.dart");

// lib/widgets/
class FillBlankQuestionWidget extends StatelessWidget {
  final FillInBlankQuestion question;
  final String firstPartOfSentence;
  final String secondPartOfSentence;
  final ValueChanged<String> onTextChanged;
  final TextEditingController controller;

  const FillBlankQuestionWidget({
    super.key,
    required this.question,
    required this.onTextChanged,
    required this.firstPartOfSentence,
    required this.secondPartOfSentence,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return QuestionCard(
      question: question,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (question.imageUrl != null)
              ? Image(image: NetworkImage(question.imageUrl!))
              : Image.asset(
                question.assetImage!,
                width: mediaWidth(context) * 0.65,
                height: mediaWidth(context) * 0.65,
              ),
          SizedBox(height: mediaWidth(context) / 8),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: firstPartOfSentence,
                style: DefaultTextStyle.of(context).style,
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: SizedBox(
                      width: mediaWidth(context) / 6,
                      child: TextField(
                        controller: controller,
                        textAlign: TextAlign.center,
                        onChanged: onTextChanged,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: -5,
                          ),
                          hintMaxLines: 1,
                        ),
                      ),
                    ),
                  ),
                  TextSpan(text: secondPartOfSentence),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

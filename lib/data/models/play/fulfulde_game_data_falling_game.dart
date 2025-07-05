



class WordPair {
  final String sourceWord;
  final String correctTranslation;
  final List<String> allPossibleTranslations;
  final double position;
  final double topPosition;

  WordPair({
    required this.sourceWord,
    required this.correctTranslation,
    required this.allPossibleTranslations,
    this.position = 0.5, // Horizontal position (0.0 to 1.0)
    this.topPosition = 0.0, // Vertical position (0.0 starts at top)
  });

  WordPair copyWith({double? topPosition}) {
    return WordPair(
      sourceWord: sourceWord,
      correctTranslation: correctTranslation,
      allPossibleTranslations: allPossibleTranslations,
      position: position,
      topPosition: topPosition ?? this.topPosition,
    );
  }
}

class  FulfuldeFallingGameData  {
  //  
  
  static List<WordPair> getRandomWordPairs() {
    return [
      WordPair(
        sourceWord: 'street',
        correctTranslation: 'rue',
        allPossibleTranslations: ['rue', 'route', 'chemin', 'avenue'],
        position: 0.3,
        topPosition: 0.0,
      ),
      WordPair(
        sourceWord: 'dessert',
        correctTranslation: 'dessert',
        allPossibleTranslations: ['dessert', 'gâteau', 'sucrerie', 'pâtisserie'],
        position: 0.7,
        topPosition: 0.0,
      ),
      WordPair(
        sourceWord: 'slip',
        correctTranslation: 'glisser',
        allPossibleTranslations: ['glisser', 'tomber', 'culotte', 'sous-vêtement'],
        position: 0.4,
        topPosition: 0.0,
      ),
      WordPair(
        sourceWord: 'wig',
        correctTranslation: 'perruque',
        allPossibleTranslations: ['perruque', 'cheveux', 'coiffure', 'postiche'],
        position: 0.6,
        topPosition: 0.0,
      ),
      WordPair(
        sourceWord: 'fetch',
        correctTranslation: 'rapporter',
        allPossibleTranslations: ['rapporter', 'chercher', 'apporter', 'récupérer'],
        position: 0.2,
        topPosition: 0.0,
      ),
    ];
  }
}
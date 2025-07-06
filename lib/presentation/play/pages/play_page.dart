import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cultura/common/constants.dart';
import 'package:cultura/common/helpers/navigator/app_navigator.dart';
import 'package:cultura/presentation/play/pages/falling_game_page.dart';
import 'package:cultura/presentation/play/pages/dual_game_page.dart';
import 'package:cultura/presentation/pricing/pages/pricing_page.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  bool _soundEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Column(
        children: [
          // Header
          PlayHeader(
            soundEnabled: _soundEnabled,
            onSoundToggle: () {
              setState(() {
                _soundEnabled = !_soundEnabled;
              });
            },
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Motivational quote card
                    QuoteCard(),
                    SizedBox(height: 30),

                    // Games section title
                    Row(
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedGameController01,
                          size: 24,
                          color: Color(0xFF5D340A),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Choose Your Game',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Game cards
                    GameCard(
                      title: 'Word Drop Challenge',
                      description:
                          'Catch falling words and match them with their correct translations! Test your reflexes and vocabulary.',
                      icon: HugeIcons.strokeRoundedFallingStar,
                      color: Color(0xFF5D340A),
                      onTap: () {
                        AppNavigator.push(context, FallingGamePage());
                      },
                    ),
                    SizedBox(height: 20),

                    GameCard(
                      title: 'Word Match Pairs',
                      description:
                          'Match words from the left column with their translations on the right. Perfect for vocabulary building.',
                      icon: HugeIcons.strokeRoundedTranslate,
                      color: Colors.blue,
                      onTap: () {
                        AppNavigator.push(context, DualGamePage());
                      },
                    ),
                    SizedBox(height: 20),

                    // Coming soon section
                    ComingSoonCard(),
                    SizedBox(height: 30),

                    // Footer message
                    FooterMessage(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Play Header Component
class PlayHeader extends StatelessWidget {
  const PlayHeader({
    super.key,
    required this.soundEnabled,
    required this.onSoundToggle,
  });

  final bool soundEnabled;
  final VoidCallback onSoundToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      child: Stack(
        children: [
          // Background with gradient
          Container(
            height: 120,
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
                      'Language Games',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Sound toggle
                  GestureDetector(
                    onTap: onSoundToggle,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        soundEnabled
                            ? HugeIcons.strokeRoundedVolumeHigh
                            : HugeIcons.strokeRoundedVolumeMute01,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),

                  // Premium button
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        HugeIcons.strokeRoundedCrown,
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

// Quote Card Component
class QuoteCard extends StatelessWidget {
  const QuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF627B3F),
            Color.fromARGB(255, 151, 221, 52),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            HugeIcons.strokeRoundedQuoteDown,
            size: 30,
            color: Colors.white,
          ),
          SizedBox(height: 15),
          Text(
            "A language is not just words. It's a culture, a tradition, a unification of a community, a whole history that creates what a community is. It's all embodied in a language.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          SizedBox(height: 15),
          Text(
            "- Noam Chomsky",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// Game Card Component
class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 35,
                color: color,
              ),
            ),
            SizedBox(width: 20),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Play button
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          HugeIcons.strokeRoundedPlay,
                          size: 16,
                          color: color,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Play Now',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Coming Soon Card Component
class ComingSoonCard extends StatelessWidget {
  const ComingSoonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  HugeIcons.strokeRoundedRocket,
                  size: 25,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'More Games Coming Soon',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'We\'re working on exciting new games!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15),

          // Upcoming games preview
          Row(
            children: [
              UpcomingGamePreview(
                icon: HugeIcons.strokeRoundedPuzzle,
                name: 'Word Puzzle',
              ),
              SizedBox(width: 15),
              UpcomingGamePreview(
                icon: HugeIcons.strokeRoundedSpeedTrain02,
                name: 'Speed Quiz',
              ),
              SizedBox(width: 15),
              UpcomingGamePreview(
                icon: HugeIcons.strokeRoundedTarget01,
                name: 'Word Target',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Upcoming Game Preview Component
class UpcomingGamePreview extends StatelessWidget {
  const UpcomingGamePreview({
    super.key,
    required this.icon,
    required this.name,
  });

  final IconData icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Footer Message Component
class FooterMessage extends StatelessWidget {
  const FooterMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            HugeIcons.strokeRoundedBulb,
            size: 20,
            color: Colors.blue,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Practice daily to master your language skills and unlock new achievements!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

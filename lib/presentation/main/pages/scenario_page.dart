import 'package:cultura/presentation/main/pages/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cultura/common/helpers/navigator/app_navigator.dart';
// import 'package:cultura/presentation/chat\pages\chat_page.dart';

class ScenariosPage extends StatelessWidget {
  const ScenariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Choose a Scenario',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF5D340A), Color(0xFFFF8A50)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    HugeIcons.strokeRoundedChatting01,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Practice Real Conversations',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Choose a scenario and start practicing with our AI',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Scenarios List
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                ScenarioCard(
                  icon: HugeIcons.strokeRoundedAllBookmark,
                  title: 'All & Nothing',
                  description:
                      'Just have a quick conversation with our AI model about everything you want!',
                  difficulty: 'Beginner',
                  onTap: () => _navigateToChat(context, 'all'),
                ),
                SizedBox(height: 16),
                ScenarioCard(
                  icon: HugeIcons.strokeRoundedRestaurant01,
                  title: 'Restaurant',
                  description:
                      'Order food, ask for recommendations, and interact with waiters',
                  difficulty: 'Beginner',
                  onTap: () => _navigateToChat(context, 'restaurant'),
                ),
                SizedBox(height: 16),
                ScenarioCard(
                  icon: HugeIcons.strokeRoundedShoppingBag01,
                  title: 'Shopping',
                  description:
                      'Buy clothes, ask for sizes, and negotiate prices',
                  difficulty: 'Beginner',
                  onTap: () => _navigateToChat(context, 'shopping'),
                ),
                SizedBox(height: 16),
                ScenarioCard(
                  icon: HugeIcons.strokeRoundedHospital01,
                  title: 'Doctor Visit',
                  description:
                      'Describe symptoms, understand prescriptions, and medical advice',
                  difficulty: 'Intermediate',
                  onTap: () => _navigateToChat(context, 'doctor'),
                ),
                SizedBox(height: 16),
                ScenarioCard(
                  icon: HugeIcons.strokeRoundedBuilding01,
                  title: 'Job Interview',
                  description:
                      'Practice answering questions and presenting yourself professionally',
                  difficulty: 'Advanced',
                  onTap: () => _navigateToChat(context, 'job_interview'),
                ),
                // SizedBox(height: 16),
                // ScenarioCard(
                //   icon: HugeIcons.strokeRoundedAirplane01,
                //   title: 'Airport/Travel',
                //   description: 'Check-in, security, and asking for directions',
                //   difficulty: 'Intermediate',
                //   onTap: () => _navigateToChat(context, 'airport'),
                // ),
                SizedBox(height: 16),
                ScenarioCard(
                  icon: HugeIcons.strokeRoundedBank,
                  title: 'Bank Visit',
                  description:
                      'Open accounts, understand banking terms, and transactions',
                  difficulty: 'Advanced',
                  onTap: () => _navigateToChat(context, 'bank'),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(BuildContext context, String scenarioId) {
    AppNavigator.push(
      context,
      ChatPage(scenarioId: scenarioId),
    );
  }
}

class ScenarioCard extends StatelessWidget {
  const ScenarioCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String difficulty;
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
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xFF5D340A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 30,
                color: Color(0xFF5D340A),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              _getDifficultyColor(difficulty).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          difficulty,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getDifficultyColor(difficulty),
                          ),
                        ),
                      ),
                    ],
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
                ],
              ),
            ),
            SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showScenarioInfo(context, title, description),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  void _showScenarioInfo(
      BuildContext context, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Text(
          description,
          style: TextStyle(color: Colors.grey[600]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(color: Color(0xFF5D340A)),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cultura/common/constants.dart';
import 'package:cultura/common/helpers/navigator/app_navigator.dart';
import 'package:cultura/common/loading_builder.dart';
import 'package:cultura/common/services/document_scanning_service.dart';
import 'package:cultura/presentation/main/bloc/display_user_info_cubit.dart';
import 'package:cultura/presentation/main/bloc/display_user_info_state.dart';
import 'package:cultura/presentation/main/pages/home_page.dart';
import 'package:cultura/presentation/main/pages/media_library_page.dart';
import 'package:cultura/presentation/play/pages/play_page.dart';
import 'package:cultura/presentation/pricing/pages/pricing_page.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _totalDocuments = 0;
  int _totalTranslations = 156; // Mock data - replace with actual service
  int _scenariosPracticed = 8; // Mock data - replace with actual service

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    try {
      final documentService = DocumentScanningService();
      final documents = await documentService.getSavedDocuments();

      setState(() {
        _totalDocuments = documents.length;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserInfoDisplayCubit()..displayUserInfo(),
      child: Scaffold(
        backgroundColor: scaffoldBgColor,
        body: BlocBuilder<UserInfoDisplayCubit, UserInfoDisplayState>(
          builder: (context, state) {
            if (state is UserInfoLoading) {
              return Center(child: const DefaultLoadingBuilder());
            }

            if (state is UserInfoLoaded) {
              return Column(
                children: [
                  // Silver Header with curved shape
                  ProfileHeader(user: state.user),
                  // Scrollable content
                  Expanded(
                    child: ProfileContent(
                      totalDocuments: _totalDocuments,
                      totalTranslations: _totalTranslations,
                      scenariosPracticed: _scenariosPracticed,
                    ),
                  ),
                ],
              );
            }

            return Container();
          },
        ),
      ),
    );
  }
}

// Profile Header Component
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final dynamic user; // Replace with your UserEntity type

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      child: Stack(
        children: [
          // Silver background with curved bottom
          ClipPath(
            clipper: CurvedBottomClipper(),
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF627B3F),
                    Color.fromARGB(255, 151, 221, 52),
                  ],
                ),
              ),
            ),
          ),

          // Header controls
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

                  Spacer(),

                  // Title
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Spacer(),

                  // Settings button
                  GestureDetector(
                    onTap: () => _showSettingsBottomSheet(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        HugeIcons.strokeRoundedSettings02,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile card
          Positioned(
            bottom: 0,
            left: 20,
            right: 20,
            child: ProfileCard(user: user),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper for curved bottom (reused from home page)
class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Profile Card Component
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.user});

  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Profile image with edit button
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[200]!, width: 3),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      user?.image != null ? NetworkImage(user.image) : null,
                  child: user?.image == null
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[600],
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showEditImageOptions(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(0xFF5D340A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedEdit02,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // User name
          Text(
            user?.firstName ?? 'User Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),

          SizedBox(height: 8),

          // Join date
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                HugeIcons.strokeRoundedCalendar03,
                size: 16,
                color: Colors.grey[600],
              ),
              SizedBox(width: 6),
              Text(
                'Joined ${_formatJoinDate(DateTime.now())}', // Replace with actual join date
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// Profile Content Component
class ProfileContent extends StatelessWidget {
  const ProfileContent({
    super.key,
    required this.totalDocuments,
    required this.totalTranslations,
    required this.scenariosPracticed,
  });

  final int totalDocuments;
  final int totalTranslations;
  final int scenariosPracticed;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),

          // Stats section
          Text(
            'Your Progress',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),

          // Stats grid
          StatsGrid(
            totalDocuments: totalDocuments,
            totalTranslations: totalTranslations,
            scenariosPracticed: scenariosPracticed,
          ),

          SizedBox(height: 30),

          // Quick actions section
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),

          // Quick actions
          QuickActionsGrid(),

          SizedBox(height: 30),

          // Settings section
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),

          // Settings list
          SettingsList(),
        ],
      ),
    );
  }
}

// Stats Grid Component
class StatsGrid extends StatelessWidget {
  const StatsGrid({
    super.key,
    required this.totalDocuments,
    required this.totalTranslations,
    required this.scenariosPracticed,
  });

  final int totalDocuments;
  final int totalTranslations;
  final int scenariosPracticed;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 6,
      mainAxisSpacing: 6,
      childAspectRatio: .8,
      children: [
        StatCard(
          icon: HugeIcons.strokeRoundedTranslate,
          label: 'Translations',
          value: totalTranslations.toString(),
          color: Color(0xFF5D340A),
        ),
        StatCard(
          icon: HugeIcons.strokeRoundedFile02,
          label: 'Documents',
          value: totalDocuments.toString(),
          color: Colors.blue,
        ),
        StatCard(
          icon: HugeIcons.strokeRoundedChatting01,
          label: 'Scenarios',
          value: scenariosPracticed.toString(),
          color: Colors.green,
        ),
      ],
    );
  }
}

// Stat Card Component
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Quick Actions Grid Component
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        QuickActionCard(
          icon: HugeIcons.strokeRoundedFile02,
          title: 'My Documents',
          subtitle: 'View saved files',
          color: Colors.blue,
          onTap: () {
            AppNavigator.push(context, MediaLibraryPage());
          },
        ),
        QuickActionCard(
          icon: HugeIcons.strokeRoundedGameController01,
          title: 'Play Games',
          subtitle: 'Practice language',
          color: Color(0xFF5D340A),
          onTap: () {
            AppNavigator.push(context, PlayPage());
          },
        ),
        QuickActionCard(
          icon: HugeIcons.strokeRoundedCrown,
          title: 'Go Premium',
          subtitle: 'Unlock features',
          color: Colors.amber,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Coming soon...',
                  style: TextStyle(color: seedColorPalette.shade700),
                ),
                backgroundColor: seedColorPalette.shade100,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
        QuickActionCard(
          icon: HugeIcons.strokeRoundedShare08,
          title: 'Share App',
          subtitle: 'Tell your friends',
          color: Colors.green,
          onTap: () {
            Share.share(
              'Check out Cultura, the app that helps you learn languages and translate documents! Download it now.',
              subject: 'Cultura - Language Learning App',
            );
          },
        ),
      ],
    );
  }
}

// Quick Action Card Component
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
                color: color,
              ),
            ),
            Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Settings List Component
class SettingsList extends StatelessWidget {
  const SettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsTile(
          icon: HugeIcons.strokeRoundedEdit02,
          title: 'Edit Profile',
          subtitle: 'Update your information',
          onTap: () {
            // Handle edit profile
          },
        ),
        SizedBox(height: 12),
        SettingsTile(
          icon: HugeIcons.strokeRoundedNotification03,
          title: 'Notifications',
          subtitle: 'Manage your notifications',
          onTap: () {
            // Handle notifications
          },
        ),
        SizedBox(height: 12),
        SettingsTile(
          icon: HugeIcons.strokeRoundedHelpCircle,
          title: 'Help & Support',
          subtitle: 'Get help and contact us',
          onTap: () {
            // Handle help
          },
        ),
        SizedBox(height: 12),
        SettingsTile(
          icon: HugeIcons.strokeRoundedInformationCircle,
          title: 'About',
          subtitle: 'App version and info',
          onTap: () {
            // Handle about
          },
        ),
        SizedBox(height: 12),
        SettingsTile(
          icon: HugeIcons.strokeRoundedLogout01,
          title: 'Logout',
          subtitle: 'Sign out of your account',
          onTap: () {
            _showLogoutDialog(context);
          },
          isDestructive: true,
        ),
      ],
    );
  }
}

// Settings Tile Component
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : Color(0xFF5D340A);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Functions
void _showSettingsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
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
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          SettingsTile(
            icon: HugeIcons.strokeRoundedSettings02,
            title: 'App Settings',
            subtitle: 'Manage app preferences',
            onTap: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    ),
  );
}

void _showEditImageOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
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
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Change Profile Picture',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          SettingsTile(
            icon: HugeIcons.strokeRoundedCamera01,
            title: 'Take Photo',
            subtitle: 'Use camera to take a new photo',
            onTap: () {
              Navigator.pop(context);
              // Handle camera
            },
          ),
          SizedBox(height: 12),
          SettingsTile(
            icon: HugeIcons.strokeRoundedImage01,
            title: 'Choose from Gallery',
            subtitle: 'Select from your photos',
            onTap: () {
              Navigator.pop(context);
              // Handle gallery
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    ),
  );
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Logout',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'Are you sure you want to logout?',
        style: TextStyle(
          color: Colors.grey[600],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Handle logout
            AppNavigator.pushReplacement(context, HomePage());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text('Logout'),
        ),
      ],
    ),
  );
}

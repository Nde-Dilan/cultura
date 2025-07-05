import 'dart:developer';
import 'dart:ui';
import 'package:cultura/common/services/document_scanning_service.dart';
import 'package:cultura/common/services/file_import_service.dart';
import 'package:cultura/presentation/main/pages/media_library_page.dart';
import 'package:cultura/presentation/main/pages/scenario_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:logging/logging.dart';
import 'package:cultura/common/constants.dart';
import 'package:cultura/common/helpers/navigator/app_navigator.dart';
import 'package:cultura/common/loading_builder.dart';
import 'package:cultura/domain/auth/entities/user_entity.dart';
import 'package:cultura/presentation/main/bloc/display_user_info_cubit.dart';
import 'package:cultura/presentation/main/bloc/display_user_info_state.dart';
import 'package:cultura/presentation/main/methods/pages_method.dart';
import 'package:cultura/presentation/main/widgets/stats_card.dart';
import 'package:cultura/presentation/pricing/pages/pricing_page.dart';

Logger _log = Logger('home_page.dart');

// Main HomePage Widget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  int currentPage = 0;
  final double tabBarHeight = 50;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: kTabPages.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BlocProvider(
        create: (context) => UserInfoDisplayCubit()..displayUserInfo(),
        child: Scaffold(
          backgroundColor: scaffoldBgColor,
          body: RepaintBoundary(
            child: AnimatedSwitcher(
              duration: duration,
              child: IndexedStack(
                key: ValueKey<int>(currentPage),
                index: currentPage,
                children: [
                  BlocBuilder<UserInfoDisplayCubit, UserInfoDisplayState>(
                    builder: (context, state) {
                      if (state is UserInfoLoading) {
                        return Center(child: const DefaultLoadingBuilder());
                      }
                      if (state is UserInfoLoaded) {
                        return HomeWidget(state: state);
                      }
                      return Container();
                    },
                  ),
                  //other pages
                  ...kTabPages.skip(1),
                ],
              ),
            ),
          ),
          bottomNavigationBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: UnconstrainedBox(
              child: Container(
                height: tabBarHeight,
                constraints: BoxConstraints(
                  maxWidth: mediaWidth(context) - 50.0,
                ),
                margin: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  // color: const Color(0xFF5D340A),
                  borderRadius: BorderRadius.circular(25),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: seedColor,
                  //     blurRadius: 8.0,
                  //     offset: Offset(0, 4.0),
                  //   ),
                  // ],
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    physics: const BouncingScrollPhysics(),
                    indicatorSize: TabBarIndicatorSize.label,
                    padding: EdgeInsets.zero,
                    indicatorPadding: EdgeInsets.zero,
                   
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                    indicator: BoxDecoration(
                      color: seedColorPalette.shade100,
                      shape: BoxShape.circle,
                    ),
                    splashBorderRadius: BorderRadius.circular(99),
                    onTap: (index) {
                      setState(() {
                        currentPage = index;
                        _tabController.animateTo(
                          index,
                          duration: duration,
                          curve: Curves.bounceInOut,
                        );
                      });
                    },
                    tabs: List.generate(
                      kTabPages.length,
                      (index) => Tab(
                        icon: Icon(tabIcons[index]),
                        text: tabNames[index],
                      ),
                    ),
                    dividerHeight: 0.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Home Widget
class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key, required this.state});

  final UserInfoLoaded state;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Silver Header with curved shape
        SilverHeader(user: state.user),
        // Scrollable content
        Expanded(
          child: ScrollableContent(),
        ),
      ],
    );
  }
}

// Silver Header Component
class SilverHeader extends StatelessWidget {
  const SilverHeader({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: Stack(
        children: [
          // Silver background with curved bottom
          ClipPath(
            clipper: CurvedBottomClipper(),
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF627B3F)!,
                    Color.fromARGB(255, 151, 221, 52)!,
                  ],
                ),
              ),
            ),
          ),
          //TODO: Add drawer
          // Positioned(
          //   top: 30,
          //   left: 5,
          //   child: UserAvatar(user: user),
          // ),
          // Orange card
          Positioned(
            top: 40,
            left: 30,
            right: 80,
            child: OrangeGreetingCard(userName: user.firstName),
          ),
          // User avatar
          Positioned(
            top: 30,
            right: 10,
            child: UserAvatar(user: user),
          ),
        ],
      ),
    );
  }
}

// Custom Clipper for curved bottom
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

// Orange Greeting Card Component
class OrangeGreetingCard extends StatelessWidget {
  const OrangeGreetingCard({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 195, 119, 44),
            Color(0xFF5D340A),
            // Color(0xFFFF8A50),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hello, ${formatUsername(userName)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'What do you want\nto translate\ntoday?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// User Avatar Component
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey[300],
        backgroundImage: user?.image != null ? NetworkImage(user.image!) : null,
        // child:  Icon(
        //   Icons.person,
        //   size: 30,
        //   color: Colors.grey[600],
        // ),
      ),
    );
  }
}

// Scrollable Content Component
class ScrollableContent extends StatelessWidget {
  const ScrollableContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(height: 20),
          // Translation options grid
          TranslationOptionsGrid(),
          SizedBox(height: 30),
          // Recent translations or other content
          RecentTranslationsSection(),
        ],
      ),
    );
  }
}

// Translation Options Grid Component (Updated)
class TranslationOptionsGrid extends StatelessWidget {
  const TranslationOptionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: [
        TranslationOptionCard(
          icon: Icons.text_fields,
          label: 'Text',
          onTap: () {
            // Handle text translation
          },
        ),
        TranslationOptionCard(
          icon: HugeIcons.strokeRoundedMore02,
          label: 'More',
          onTap: () {
            _showMoreOptionsBottomSheet(context);
          },
        ),
        TranslationOptionCard(
          icon: Icons.image,
          label: 'Learn',
          onTap: () {
            // Handle image translation
          },
        ),
        TranslationOptionCard(
          icon: HugeIcons.strokeRoundedChatting01,
          label: 'Cult AI',
          onTap: () {
            AppNavigator.push(context, const ScenariosPage());
          },
        ),
      ],
    );
  }
}

// Translation Option Card Component
class TranslationOptionCard extends StatelessWidget {
  const TranslationOptionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF5D340A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 28,
                color: Color(0xFF5D340A),
              ),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Recent Translations Section Component
class RecentTranslationsSection extends StatelessWidget {
  const RecentTranslationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Translations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 15),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: 200,
                margin: EdgeInsets.only(right: 15),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello World',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Hola Mundo',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'EN → ES',
                      style: TextStyle(
                        color: Color(0xFF5D340A),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Function to show More Options Bottom Sheet
void _showMoreOptionsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MoreOptionsBottomSheet(),
  );
}

// More Options Bottom Sheet Widget
class MoreOptionsBottomSheet extends StatefulWidget {
  const MoreOptionsBottomSheet({super.key});

  @override
  State<MoreOptionsBottomSheet> createState() => _MoreOptionsBottomSheetState();
}

class _MoreOptionsBottomSheetState extends State<MoreOptionsBottomSheet> {
  Future<void> _handleScanDocument() async {
    // Navigator.pop(context); // Close bottom sheet first

    final scanService = DocumentScanningService();

    try {
      final result = await scanService.scanDocument(maxPages: 5);

      if (result.isSuccess) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MediaLibraryPage(),
            ),
          );
        }
      } else if (result.isCancelled) {
        log('Scanning was cancelled by user');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Scanning failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred while scanning'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 20),
          // Title
          Text(
            'More Options',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 30),
          // Options
          MoreOptionTile(
            icon: HugeIcons.strokeRoundedFile02,
            title: 'Import Document',
            subtitle: 'Upload and translate documents',
            onTap: () async {
              // Store the navigator before any async operations
              // final navigator = Navigator.of(context);

              // navigator.pop(); // Close bottom sheet

              final importService = FileImportService();

              try {
                final importedFiles = await importService.importDocuments();

                // Check if widget is still mounted before using context
                if (!context.mounted) return;

                if (importedFiles != null && importedFiles.isNotEmpty) {
                  // Navigate to media library
                  AppNavigator.push(context, const MediaLibraryPage());
                }
              } catch (e) {
                // Handle any import errors
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('An error occurred while importing files'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
          SizedBox(height: 15),
          MoreOptionTile(
            icon: HugeIcons.strokeRoundedMic01,
            title: 'Record',
            subtitle: 'Record audio for translation',
            onTap: () {
              Navigator.pop(context);
              // Handle record
            },
          ),
          SizedBox(height: 15),
          MoreOptionTile(
            icon: HugeIcons.strokeRoundedCamera01,
            title: 'Camera or Scan',
            subtitle: 'Scan text from images',
            onTap: () => _handleScanDocument(),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}

// More Option Tile Component
class MoreOptionTile extends StatelessWidget {
  const MoreOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF5D340A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Color(0xFF5D340A),
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

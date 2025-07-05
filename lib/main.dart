import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/constants.dart';
import 'package:cultura/common/constants.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cultura/data/music/source/audio_service.dart';

//firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:cultura/firebase_options.dart';
import 'package:cultura/presentation/pages/landing_page.dart';
import 'package:cultura/service_locator.dart';

//logging
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase initialization first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Dependencies next
    await initializeDependencies();

    // Configure logging
    if (kDebugMode) {
      Logger.root.level = Level.FINE;
    }

    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });

   
    // System UI configuration - keep status bar visible but auto-hide navigation bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

// Style the status bar to be transparent or with custom color
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        // Make status bar transparent (or use your desired color)
        statusBarColor: Colors.transparent,
        // Use dark icons if your app background is light
        statusBarIconBrightness: Brightness.dark,
        // Make navigation bar transparent when it appears
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        // Make navigation bar divider invisible
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    // Lock device orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).then((_) => runApp(const MyApp()));
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
}

Logger _log = Logger('main.dart');

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cultura',
      theme: ThemeData(
        fontFamily:   GoogleFonts.patrickHand(fontSize: 21.50).fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: LandingPage(),
    );
  }
}

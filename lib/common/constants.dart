import 'dart:ui';

import 'package:cultura/presentation/main/pages/media_library_page.dart';
import 'package:cultura/presentation/play/pages/play_page.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:cultura/common/loading_builder.dart';
import 'package:cultura/data/models/main/learning_stats.dart';
import 'package:cultura/presentation/auth/pages/login_page.dart';
import 'package:cultura/presentation/dictionary/pages/dictionary.dart';
import 'package:cultura/presentation/main/pages/home_page.dart';
import 'package:cultura/presentation/profile/profile_page.dart';

// App version
const String appVersionNumber = "1.0.0";

// language Code
///
/// languages: [mai-IN, hr-HR, ko-KR, mr-IN, as-IN, ru-RU, zh-TW, hu-HU, sw-KE, sd-IN, ks-IN, th-TH, doi-IN, ur-PK, nb-NO, da-DK, tr-TR, et-EE, pt-PT, vi-VN, en-US, ur-IN, sat-IN, sq-AL, sv-SE, ar, sr-RS, su-ID, bn-BD, bs-BA, mni-IN, gu-IN, kn-IN, el-GR, hi-IN, he-IL, fi-FI, bn-IN, km-KH, fr-FR, uk-UA, pa-IN, en-AU, nl-NL, fr-CA, lv-LV, pt-BR, de-DE, ml-IN, si-LK, cs-CZ, is-IS, pl-PL, ca-ES, sk-SK, it-IT, fil-PH, lt-LT, ne-NP, ms-MY, en-NG, nl-BE, zh-CN, es-ES, ja-JP, ta-IN, bg-BG, cy-GB, or-IN, brx-IN, sa-IN, yue-HK, en-IN, es-US, kok-IN, jv-ID, sl-SI, id-ID, te-IN, ro-RO, en-GB]

const String languageCode = "Zh-Cn";

//Free Practice Duration
const int freeTime = 120;

// Colors
const Color seedColor = Color(0xFF728549);

// Neutrals
const Color darkColor = Color(0xFF0C0C0C);
const Color backgroundColor = Color(0xFF030326);
const Color systemChrome = Color(0xFF0F9D58);
const Color scaffoldBgColor = Color(0xFFFFFBF0);
const Color teal = Colors.teal;

const Color white = Color.fromARGB(255, 255, 255, 255);
const Color disabledColor = Color(0xFF8D8D8D);
const Color listenButton = Color(0xFFD9FFE0);

// State Colors
const Color successColor = Color(0xFF0F9D58);
const Color dangerColor = Color(0xFFDB4437);
const Color warningColor = Color(0xFFF4B400);
const Color infoColor = Color(0xFF6424EC);

// Primary color
MaterialColor seedColorPalette = MaterialColor(0xFF5D340A, const <int, Color>{
  50: Color(0xFFFFECE6),
  100: Color(0xFFFFD9CD),
  200: Color(0xFFFFB39B),
  300: Color(0xFFFF8D69),
  400: Color(0xFF5D340A),
  500: Color(0xFFFF5A20),
  600: Color(0xFFE6481C),
  700: Color(0xFFCC3919),
  800: Color(0xFFB32B15),
  900: Color(0xFF991D12),
});

// Border Radius
BorderRadius borderRadius = BorderRadius.circular(8.0);
BorderRadius topRadius = BorderRadius.vertical(top: Radius.circular(16.0));

//Premium configs
const String yearlyPrice = '55000';
const String monthlyPrice = '5000';
const Color pricingCardback = Color(0xFF7ED957);
// Image paths
const String logoDarkSvg = "assets/images/logo_dark.svg";
const String logoLight = "assets/images/logo_light.png";
const String logoLightSvg = "assets/images/logo_light.svg";
const String onboardImg1 = "assets/images/onboard_img_1.png";
const String onboardImg2 = "assets/images/onboard_img_2.png";
const String onboardImg3 = "assets/images/onboard_img_3.png";
const String appleLogo = "assets/images/apple_logo.png";
const String googleLogo = "assets/images/google_logo.svg";
const String userAvatars = "assets/images/user_avatars.svg";
const String pfp = "assets/images/pfp.jpg";
const String mailbox = "assets/images/mailbox.svg";
const String cleziChat = "assets/images/clezi_chat.svg";
const String verifiedAvatars = "assets/images/verified_avatars.svg";
const String crescentMoon3d = "assets/images/crescent_moon_3d.png";
const String lightBulb3d = "assets/images/light_bulb_3d.png";
const String sun3d = "assets/images/sun_3d.png";
const String emptyQuery = "assets/images/empty_query.svg";
const String agentRequest = "assets/images/agent_request.svg";
const String procedureAddImage = "assets/images/procedure_add.svg";

// Reactions
const String angryFace = "assets/images/angry_face.svg";
const String frowningFace = "assets/images/frowning_face.svg";
const String neutralFace = "assets/images/neutral_face.svg";
const String slightlySmilingFace = "assets/images/slightly_smiling_face.svg";
const String agentCap = "assets/images/agent_cap.svg";
const String grinningFace = "assets/images/grinning_face.svg";

//Fake stats
final mockStats = LearningStats(
  learningRate: 0.75,
  totalWordsLearned: 250,
  totalDaysLearned: 30,
);

//Tab settings

final List<Widget> kTabPages = [
  const HomePage(),
  const MediaLibraryPage(),
  const PlayPage(),
  const ProfileScreen(),
];

final List<IconData> tabIcons = [
  HugeIcons.strokeRoundedHome02,
  HugeIcons.strokeRoundedMedal02,
  HugeIcons.strokeRoundedPlay,
  HugeIcons.strokeRoundedUser,
];

final List<String> tabNames = [
  'Home',
  'Media',
  'Play', //TODO: Explain to him that its the revision page
  'Profile', //TODO: Can implement settings into profile or vice versa
];

// Padding
const EdgeInsets allPadding = EdgeInsets.all(8.0);

// Shadow
BoxShadow shadow = BoxShadow(
  color: Colors.black.withAlpha(21),
  blurRadius: 8.0,
  offset: Offset(0, 2),
);

// Duration
const Duration duration = Duration(milliseconds: 300);

// Media sizes
double mediaWidth(BuildContext context) => MediaQuery.sizeOf(context).width;

double mediaHeight(BuildContext context) => MediaQuery.sizeOf(context).height;

// Filters
ImageFilter blurFilter = ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0);

// TextStyles
class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 34.0,
    height: 40.0 / 34.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 28.0,
    height: 36.0 / 28.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24.0,
    height: 32.0 / 24.0,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20.0,
    height: 28.0 / 20.0,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18.0,
    height: 24.0 / 18.0,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16.0,
    height: 24.0 / 16.0,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12.0,
    height: 16.0 / 12.0,
    fontWeight: FontWeight.normal,
  );
}

// Decoration
BoxDecoration formFieldDecoration = BoxDecoration(
  borderRadius: borderRadius * 2,
  color: Colors.white,
  boxShadow: [shadow],
);

// Validators
// email regex that allows abc@domain.com, abc+def@domain.com, abc.def@sub.domain.com
String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

// Input borders
class AppInputBorders {
  static OutlineInputBorder border = OutlineInputBorder(
    borderRadius: borderRadius * 2,
    borderSide: BorderSide(color: Colors.transparent, width: 1.5),
  );

  static OutlineInputBorder focusedBorder = OutlineInputBorder(
    borderRadius: borderRadius * 2,
    borderSide: BorderSide(color: seedColor, width: 1.5),
  );

  static OutlineInputBorder errorBorder = OutlineInputBorder(
    borderRadius: borderRadius * 2,
    borderSide: BorderSide(color: dangerColor, width: 1.5),
  );

  static OutlineInputBorder focusedErrorBorder = OutlineInputBorder(
    borderRadius: borderRadius * 2,
    borderSide: BorderSide(color: dangerColor, width: 1.5),
  );

  static OutlineInputBorder enabledBorder = OutlineInputBorder(
    borderRadius: borderRadius * 2,
    borderSide: BorderSide(color: Colors.transparent, width: 1.5),
  );

  static OutlineInputBorder disabledBorder = OutlineInputBorder(
    borderRadius: borderRadius * 2,
    borderSide: BorderSide(color: Colors.transparent, width: 1.5),
  );
}

// Show loading dialog
void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const DefaultLoadingBuilder();
    },
  );
}

const String clezyPromptTemplate = '''
__InitialiseClezyGov__
Please generate a response focused strictly on administrative procedures within Cameroon. The response should guide the user on how to achieve these procedures in a polite, clear, and user-friendly tone. The response should not reference or use examples from other countries, as the information is intended solely for users navigating Cameroonian administrative systems.

If the user’s question is in French, the response should also be in French; if the question is in English, the response should remain in English.

Please prioritize information based on the current question and use memory of past interactions only as a secondary context.

In the response, include:
1. Location Information: Specify the town, district, or street in Cameroon where the procedure can be completed.
2. Operating Hours: Mention the available times or days when the office or location is open.
3. Cost Estimate: Provide an estimated fee or cost associated with the procedure, if available.

All information should be accurate and solely related to administrative processes within Cameroon. Ensure a polite and professional tone to enhance the user experience.
''';

import 'package:flutter/material.dart';
import 'package:cultura/common/constants.dart';
import 'package:cultura/data/music/source/audio_service.dart';
import 'package:cultura/presentation/auth/pages/login_page.dart';
import 'package:cultura/presentation/auth/pages/register_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

//TODO: Reduce the duration and size of that song

class _LandingPageState extends State<LandingPage> {
 
  @override
  void initState() {
    super.initState(); 
  }

 

  @override
  void dispose() {
     super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            spacing: 14,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  color: scaffoldBgColor,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/icons/one-bar.png"),
                        const SizedBox(height: 19),
                        Image.asset("assets/icons/bubble.png"),
                        const SizedBox(height: 19),
                        Image.asset("assets/logo.png"),
                        const SizedBox(height: 29),
                        const Text(
                          "C U L T U R A",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 38.0),
                          child: const Text(
                            "Translate on the go and whenever you want.",
                            style: TextStyle(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.0),
              NextButton(
                onPressed: () {
                  // Navigate to "Get Started" screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                isEnabled: true,
                text: 'REGISTER',
              ),
              NextButton(
                onPressed: () {
                  // Navigate to "LOG IN" screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                isEnabled: true,
                text: 'LOG IN',
              ),
              SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  final bool? isEnabled;
  final String text;
  final VoidCallback? onPressed;

  const NextButton({
    super.key,
    this.isEnabled,
    this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(mediaWidth(context) / 0.9, mediaWidth(context) / 6),
        backgroundColor: Color(0xFF5D340A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        //disabledBackgroundColor: Colors.grey,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

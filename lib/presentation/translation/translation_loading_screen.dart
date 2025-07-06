import 'package:cultura/common/services/translation_service.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class TranslationLoadingScreen extends StatefulWidget {
  const TranslationLoadingScreen({
    super.key,
    required this.fileName,
    required this.filePath,
    required this.onTranslationComplete,
    required this.onError,
  });

  final String fileName;
  final String filePath;
  final Function(TranslationResult) onTranslationComplete;
  final Function(String) onError;

  @override
  State<TranslationLoadingScreen> createState() =>
      _TranslationLoadingScreenState();
}

class _TranslationLoadingScreenState extends State<TranslationLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation for the main icon
    _rotationController = AnimationController(
      duration: Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Pulse animation for the dots
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _startTranslation();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTranslation() async {
    final translationService = TranslationService();

    try {
      final result = await translationService.translateDocument(
        filePath: widget.filePath, // This would be the actual file path
        fileName: widget.fileName,
      );

      if (mounted) {
        widget.onTranslationComplete(result);
      }
    } catch (e) {
      if (mounted) {
        widget.onError('Translation failed: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 2),

              // Main loading animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Color(0xFF5D340A).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value * 2 * 3.14159,
                      child: Icon(
                        HugeIcons.strokeRoundedTranslate,
                        size: 50,
                        color: Color(0xFF5D340A),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 40),

              // Loading message
              Text(
                'Wait still, we are translating your doc!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16),

              Text(
                'Processing "${widget.fileName}"...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40),

              // Animated dots
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(0xFF5D340A).withOpacity(
                            _pulseAnimation.value *
                                (index == 0
                                    ? 1.0
                                    : index == 1
                                        ? 0.7
                                        : 0.4),
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),

              SizedBox(height: 60),

              // Processing steps
              _buildProcessingSteps(),

              Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingSteps() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildStep('📄', 'Reading document...', true),
          SizedBox(height: 12),
          _buildStep('🔍', 'Analyzing content...', true),
          SizedBox(height: 12),
          _buildStep('🌐', 'Translating text...', true),
          SizedBox(height: 12),
          _buildStep('📝', 'Formatting result...', false),
        ],
      ),
    );
  }

  Widget _buildStep(String emoji, String text, bool isActive) {
    return Row(
      children: [
        Text(
          emoji,
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? Colors.grey[800] : Colors.grey[500],
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
        if (isActive)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5D340A)),
            ),
          )
        else
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green,
          ),
      ],
    );
  }
}

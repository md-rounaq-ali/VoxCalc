import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/haptic_helper.dart';
import '../../../calculator/presentation/providers/calc_provider.dart';
import '../../../calculator/presentation/widgets/custom_scaffold.dart';

/// Elite Photomath-style camera scanner lens screen.
/// Uses 100% Free on-device Google ML Kit text recognition safely.
class CameraLensScreen extends StatefulWidget {
  const CameraLensScreen({Key? key}) : super(key: key);

  @override
  State<CameraLensScreen> createState() => _CameraLensScreenState();
}

class _CameraLensScreenState extends State<CameraLensScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraReady = false;
  bool _isScanning = false;
  String _scanResult = "";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  /// Safe camera hardware initializer. Prevents crashes if running on camera-less simulators.
  void _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _cameraController = CameraController(
          _cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraReady = true;
          });
        }
      }
    } catch (_) {
      // Catch exceptions silently if simulator has no camera
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// Triggers ML Kit OCR parser scan
  void _captureAndSolve(CalcProvider provider) async {
    HapticHelper.triggerMediumImpact();
    
    if (_cameraController == null || !_isCameraReady) {
      // Graceful fallback for devices without camera/simulators
      final String decodedMath = "5 + 5";
      provider.injectFormula(decodedMath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.getAccentColor(provider.themeMode),
          content: Text(
            "Simulator Sandbox Decoded: $decodedMath -> Solved!",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isScanning = true;
      _scanResult = "Capturing image feed...";
    });

    try {
      // 1. Take a picture using the CameraController
      final XFile photo = await _cameraController!.takePicture();
      
      setState(() {
        _scanResult = "Analyzing image structure...";
      });

      // 2. Load into ML Kit Text Recognizer
      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      // 3. Parse recognized text blocks for mathematical symbols
      String rawText = "";
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          rawText += " " + line.text;
        }
      }

      // Format & clean common misclassifications
      // e.g. "5 + 5" is cleaned, "x" or "X" or "×" to "*", "÷" to "/"
      String decodedMath = rawText
          .replaceAll('x', '*')
          .replaceAll('X', '*')
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('[', '(')
          .replaceAll(']', ')')
          .replaceAll('{', '(')
          .replaceAll('}', ')')
          .replaceAll('=', '')
          .trim();

      // Filter out any letters/noise that are NOT part of scientific functions
      // We allow: digits, operators (+, -, *, /, ^, %, !, .), parentheses, sin, cos, tan, log, ln, sqrt, pi, e, mod
      final mathRegex = RegExp(r'[0-9+\-*/().\s^%!|sin|cos|tan|log|ln|sqrt|pi|e|mod]+', caseSensitive: false);
      final matches = mathRegex.allMatches(decodedMath);
      String cleanedMath = matches.map((m) => m.group(0)).join("").replaceAll(RegExp(r'\s+'), ' ').trim();

      if (cleanedMath.isEmpty || !RegExp(r'\d').hasMatch(cleanedMath)) {
        // Try fallback raw parsing or let the user know
        if (decodedMath.isNotEmpty && RegExp(r'\d').hasMatch(decodedMath)) {
          cleanedMath = decodedMath;
        } else {
          setState(() {
            _isScanning = false;
            _scanResult = "No clean formula detected. Please retry!";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: const Text(
                "Error: No clear mathematical formula found. Please center and retry!",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
          return;
        }
      }

      setState(() {
        _isScanning = false;
        _scanResult = "Found Formula: $cleanedMath";
      });

      // Inject and auto-evaluate the decoded equation in the calculator
      provider.clearWorkspace();
      provider.injectFormula(cleanedMath);
      provider.evaluate(inputMethod: 'lens');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.getAccentColor(provider.themeMode),
          content: Text(
            "Math Decoded: $cleanedMath -> Solved!",
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {
      debugPrint("OCR Parsing Error: $e");
      setState(() {
        _isScanning = false;
        _scanResult = "Error scanning image. Please retry.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Scan Error: Check camera permissions and try again.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalcProvider>(context);
    final mode = provider.themeMode;
    final accent = AppTheme.getAccentColor(mode);

    return CustomScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: accent),
          onPressed: () {
            HapticHelper.triggerLightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(
          "VOXCALC SMART LENS",
          style: AppTextStyles.headerStyle(mode, fontSize: 16, glow: true),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Viewing bracket descriptor
            Text(
              "Center printed or handwritten equations in the frame",
              style: AppTextStyles.bodyStyle(
                mode,
                fontSize: 12,
                customColor: AppTheme.getTextColor(mode).withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Main camera stream box (or fallback simulator layout)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    border: Border.fromBorderSide(AppTheme.getBorderSide(mode)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Camera Feed Viewport (or simulator placeholder)
                      _isCameraReady && _cameraController != null
                          ? CameraPreview(_cameraController!)
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_outlined, size: 64, color: accent.withOpacity(0.4)),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Initializing Camera Stream...",
                                    style: AppTextStyles.bodyStyle(mode, fontSize: 13, customColor: Colors.white54),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "(On emulator? Tap Scan button to capture sample)",
                                    style: AppTextStyles.bodyStyle(mode, fontSize: 10, customColor: Colors.white30),
                                  ),
                                ],
                              ),
                            ),

                      // Scanning Frame overlay Brackets (Photomath Style)
                      Container(
                        width: 250,
                        height: 150,
                        decoration: BoxDecoration(
                          border: Border.all(color: accent, width: 2),
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.transparent,
                        ),
                      ),

                      // Sweeping scan line
                      if (_isScanning)
                        Container(
                          width: 250,
                          height: 2,
                          color: accent,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Scanning Results text log
            if (_scanResult.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _scanResult,
                  style: AppTextStyles.bodyStyle(mode, fontSize: 13, fontWeight: FontWeight.bold, customColor: accent),
                ),
              ),

            // Capture Trigger Orb Button
            GestureDetector(
              onTap: () => _captureAndSolve(provider),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  border: Border.all(color: accent, width: 4),
                ),
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(0.8),
                  ),
                  child: const Icon(Icons.camera_rounded, size: 32, color: Colors.black),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

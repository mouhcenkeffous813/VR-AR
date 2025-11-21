import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youth_center/utils/app_colors.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const WebViewPage({
    super.key,
    required this.url,
    this.title = 'AR Experience',
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;
  static const MethodChannel _channel = MethodChannel(
    'com.example.youth_center/webview_permissions',
  );

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initializeWebView();
  }

  Future<void> _requestPermissions() async {
    // Request camera permission automatically - CRITICAL for VR/AR
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      final result = await Permission.camera.request();
      if (result.isDenied || result.isPermanentlyDenied) {
        debugPrint('Camera permission denied! VR/AR will not work.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permission caméra requise pour la VR. Veuillez l\'activer dans les paramètres.',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        debugPrint('Camera permission granted!');
      }
    } else {
      debugPrint('Camera permission already granted!');
    }

    // Request microphone permission if needed
    final microphoneStatus = await Permission.microphone.status;
    if (!microphoneStatus.isGranted) {
      await Permission.microphone.request();
    }
  }

  void _initializeWebView() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.transparent)
          ..enableZoom(true)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                if (mounted) {
                  setState(() {
                    _loadingProgress = progress;
                  });
                }
              },
              onPageStarted: (String url) {
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                    _loadingProgress = 0;
                  });
                }
              },
              onPageFinished: (String url) async {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _loadingProgress = 100;
                  });

                  // Verify permissions are granted before allowing VR/AR
                  final cameraStatus = await Permission.camera.status;
                  if (!cameraStatus.isGranted) {
                    debugPrint(
                      'Warning: Camera permission not granted when page finished loading',
                    );
                  }

                  // Configure WebView permissions after page loads
                  // This ensures the WebChromeClient is set up correctly
                  Future.delayed(const Duration(milliseconds: 500), () async {
                    try {
                      await _channel.invokeMethod(
                        'configureWebViewPermissions',
                      );
                      debugPrint(
                        'WebView permissions configured after page load',
                      );
                    } catch (e) {
                      debugPrint('Error configuring WebView permissions: $e');
                    }
                  });

                  // Inject JavaScript to help with camera access for VR/AR
                  // Don't request camera immediately - let the VR page do it
                  // This avoids potential crashes from premature camera access
                  try {
                    await _controller.runJavaScript('''
                      (function() {
                        console.log('Camera access ready for VR/AR...');
                        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                          console.log('getUserMedia is available');
                        } else {
                          console.error('getUserMedia is NOT available');
                        }
                      })();
                    ''');
                  } catch (e) {
                    debugPrint('Error injecting JavaScript: $e');
                  }
                }
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('WebView error: ${error.description}');
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
          );

    // Configure Android-specific WebView settings for camera permissions
    if (_controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      final androidController =
          _controller.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    // Configure WebView permissions via platform channel
    // This will set up the custom WebChromeClient that auto-grants permissions
    Future.delayed(const Duration(milliseconds: 300), () async {
      try {
        await _channel.invokeMethod('configureWebViewPermissions');
        debugPrint('WebView permissions configured successfully');
      } catch (e) {
        debugPrint('Error configuring WebView permissions: $e');
      }
    });

    // Load URL after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          _controller.loadRequest(Uri.parse(widget.url));
        } catch (e) {
          debugPrint('Error loading URL: $e');
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF6093D), Color(0xFF2C2225)],
            ),
          ),
        ),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: AppColors.background,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFF6093D)),
                  const SizedBox(height: 20),
                  Text(
                    'Loading AR Experience...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  if (_loadingProgress > 0 && _loadingProgress < 100)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        '$_loadingProgress%',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

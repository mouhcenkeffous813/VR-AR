import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:youth_center/utils/app_colors.dart';
import 'package:youth_center/screens/projects/vr_room_experience_page.dart';

class ModelViewerPage extends StatefulWidget {
  final String modelPath;
  final String roomName;
  final int? participants;

  const ModelViewerPage({
    super.key,
    required this.modelPath,
    required this.roomName,
    this.participants,
  });

  @override
  State<ModelViewerPage> createState() => _ModelViewerPageState();
}

class _ModelViewerPageState extends State<ModelViewerPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isControllerInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize controller synchronously first
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(Colors.transparent)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                debugPrint('WebView page finished loading: $url');
                // Inject JavaScript to check if channel is available and force model loading
                Future.delayed(const Duration(milliseconds: 500), () {
                  _controller.runJavaScript('''
                    console.log('[INJECT] Checking ModelLoader channel...');
                    if (window.ModelLoader) {
                      console.log('[INJECT] ModelLoader channel is available!');
                      window.ModelLoader.postMessage('channelReady');
                    } else {
                      console.error('[INJECT] ModelLoader channel NOT available!');
                    }
                    // Force trigger model loading if not already started
                    if (typeof window.forceLoadModel === 'function') {
                      console.log('[INJECT] Forcing model load...');
                      window.forceLoadModel();
                    }
                  ''');
                });
                // Wait a bit more for the model to actually load
                // The JavaScript will notify us via ModelLoader channel when ready
                // But set a timeout in case JavaScript doesn't respond
                Future.delayed(const Duration(seconds: 15), () {
                  if (mounted && _isLoading) {
                    debugPrint(
                      'Timeout: Hiding loading indicator (model may still be loading)',
                    );
                    setState(() {
                      _isLoading = false;
                      // Don't set error, let the user see if model is there
                    });
                    // Try to force load via JavaScript injection
                    _controller.runJavaScript('''
                      if (typeof window.forceLoadModel === 'function') {
                        window.forceLoadModel();
                      }
                    ''');
                  }
                });
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('WebView error: ${error.description}');
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = 'Error loading model: ${error.description}';
                  });
                }
              },
            ),
          );

    // Enable hardware acceleration and WebGL for Android
    if (_controller.platform is AndroidWebViewController) {
      final androidController =
          _controller.platform as AndroidWebViewController;

      // Enable debugging to see console logs
      AndroidWebViewController.enableDebugging(true);

      // Configure WebView settings
      androidController.setMediaPlaybackRequiresUserGesture(false);

      // Hardware acceleration is enabled in AndroidManifest.xml
      // This is required for WebGL to work in WebView
      // DOM storage and other settings are enabled by default in modern WebView
    }

    // Add JavaScript channel for communication
    _controller.addJavaScriptChannel(
      'ModelLoader',
      onMessageReceived: (JavaScriptMessage message) {
        debugPrint('📱 JavaScript message: ${message.message}');
        if (message.message == 'modelLoaded' ||
            message.message == 'channelReady') {
          if (message.message == 'modelLoaded' && mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        } else if (message.message.startsWith('error:')) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _errorMessage = message.message.replaceFirst('error:', '');
            });
          }
        }
      },
    );

    setState(() {
      _isControllerInitialized = true;
    });

    // Load content asynchronously
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      debugPrint('=== Starting 3D Model Load ===');
      debugPrint('Model path: ${widget.modelPath}');
      debugPrint('Room name: ${widget.roomName}');

      // Load the GLB file as bytes
      final ByteData data = await rootBundle.load(widget.modelPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final double sizeInMB = bytes.length / 1024 / 1024;
      debugPrint(
        '✅ Model loaded successfully. Size: ${bytes.length} bytes (${sizeInMB.toStringAsFixed(2)} MB)',
      );

      // Check if file is too large
      if (bytes.length > 30 * 1024 * 1024) {
        debugPrint(
          '⚠️ WARNING: Model is very large (${sizeInMB.toStringAsFixed(2)} MB). This may cause performance issues on Android.',
        );
      }

      // Convert to base64 and split into chunks to avoid data URI limit
      final String base64Model = base64Encode(bytes);
      debugPrint(
        'Model encoded to base64. Length: ${base64Model.length} characters',
      );

      // Split base64 into chunks to avoid issues with large strings in JavaScript
      const int chunkSize = 1000000; // 1MB chunks
      final List<String> chunks = [];
      for (int i = 0; i < base64Model.length; i += chunkSize) {
        final int end =
            (i + chunkSize < base64Model.length)
                ? i + chunkSize
                : base64Model.length;
        chunks.add(base64Model.substring(i, end));
      }
      debugPrint('Base64 split into ${chunks.length} chunks');

      // Create HTML WITHOUT embedding the model data to avoid data URI size limit
      // We'll inject the data via JavaScript channel after page loads
      final String htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      width: 100vw;
      height: 100vh;
      overflow: hidden;
      background: linear-gradient(135deg, #1A237E 0%, #3949AB 50%, #5C6BC0 100%);
    }
    model-viewer {
      width: 100%;
      height: 100%;
      background-color: transparent;
      display: block;
      position: absolute;
      top: 0;
      left: 0;
      z-index: 1;
    }
    #error {
      display: none;
      color: white;
      text-align: center;
      padding: 20px;
      font-family: Arial;
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      z-index: 1000;
      background: rgba(0,0,0,0.7);
      border-radius: 10px;
    }
    #loading {
      position: absolute;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      color: white;
      font-family: Arial;
      text-align: center;
      z-index: 999;
    }
  </style>
</head>
<body>
  <div id="loading">
    <div style="font-size: 24px; margin-bottom: 10px;">Loading 3D Model...</div>
    <div style="font-size: 16px; opacity: 0.8;">${widget.roomName}</div>
  </div>
  <div id="error"></div>
  <model-viewer
    id="model-viewer"
    alt="${widget.roomName}"
    auto-rotate
    camera-controls
    interaction-policy="allow-when-focused"
    ar
    ar-modes="webxr scene-viewer quick-look"
    style="width: 100%; height: 100%;"
    exposure="1.0"
    shadow-intensity="1"
    environment-image="neutral"
    loading="eager"
    reveal="auto"
    poster=""
  ></model-viewer>
  
  <!-- Load model-viewer library with better error handling and CDN fallbacks -->
  <script>
    (function() {
      let modelViewerLoaded = false;
      let loadAttempts = 0;
      const maxAttempts = 3;
      const cdnUrls = [
        'https://ajax.googleapis.com/ajax/libs/model-viewer/3.3.0/model-viewer.min.js',
        'https://cdn.jsdelivr.net/npm/@google/model-viewer@3.3.0/dist/model-viewer.min.js',
        'https://unpkg.com/@google/model-viewer@3.3.0/dist/model-viewer.min.js'
      ];
      
      function showError(message) {
        const errorDiv = document.getElementById('error');
        const loadingDiv = document.getElementById('loading');
        if (errorDiv) {
          errorDiv.style.display = 'block';
          errorDiv.textContent = message;
        }
        if (loadingDiv) {
          loadingDiv.style.display = 'none';
        }
        if (window.ModelLoader) {
          window.ModelLoader.postMessage('error:' + message);
        }
      }
      
      function loadModelViewer(urlIndex) {
        if (urlIndex >= cdnUrls.length) {
          console.error('[JS] All CDN URLs failed');
          showError('Failed to load 3D viewer library. Please check your internet connection.');
          return;
        }
        
        const url = cdnUrls[urlIndex];
        console.log('[JS] Attempting to load model-viewer from: ' + url);
        
        // Try module first
        const moduleScript = document.createElement('script');
        moduleScript.type = 'module';
        moduleScript.textContent = \`import '\${url}'; window.modelViewerLoaded = true; console.log('[JS] Model-viewer module loaded'); if (window.onModelViewerReady) window.onModelViewerReady();\`;
        moduleScript.onerror = function() {
          console.error('[JS] Module script failed, trying non-module...');
          if (document.head.contains(moduleScript)) {
            document.head.removeChild(moduleScript);
          }
          loadNonModule(urlIndex);
        };
        document.head.appendChild(moduleScript);
        
        // Also try non-module as fallback
        setTimeout(function() {
          if (!window.modelViewerLoaded && !customElements.get('model-viewer')) {
            loadNonModule(urlIndex);
          }
        }, 2000);
      }
      
      function loadNonModule(urlIndex) {
        if (urlIndex >= cdnUrls.length) {
          console.error('[JS] All CDN URLs failed');
          showError('Failed to load 3D viewer library');
          return;
        }
        
        const url = cdnUrls[urlIndex];
        const script = document.createElement('script');
        script.src = url;
        script.type = 'text/javascript';
        script.onload = function() {
          window.modelViewerLoaded = true;
          console.log('[JS] Model-viewer loaded (non-module)');
          if (window.onModelViewerReady) {
            window.onModelViewerReady();
          }
        };
        script.onerror = function() {
          console.error('[JS] Failed to load from: ' + url);
          if (document.head.contains(script)) {
            document.head.removeChild(script);
          }
          loadModelViewer(urlIndex + 1);
        };
        document.head.appendChild(script);
      }
      
      // Start loading
      loadModelViewer(0);
    })();
  </script>
  <script>
    (function() {
      // Chunks will be injected via JavaScript channel
      let chunks = null;
      let blobUrl = null;
      let modelLoaded = false;
      let loadAttempted = false;
      let retryCount = 0;
      const maxRetries = 200;
      
      function notifyFlutter(message) {
        try {
          if (window.ModelLoader && window.ModelLoader.postMessage) {
            window.ModelLoader.postMessage(message);
            console.log('[FLUTTER] ' + message);
          } else {
            console.warn('[FLUTTER] Channel not available');
          }
        } catch (e) {
          console.error('[FLUTTER] Error:', e);
        }
      }
      
      function hideLoading() {
        const loading = document.getElementById('loading');
        if (loading) {
          loading.style.display = 'none';
          console.log('[JS] Loading hidden');
        }
      }
      
      function showError(message) {
        hideLoading();
        const errorDiv = document.getElementById('error');
        if (errorDiv) {
          errorDiv.style.display = 'block';
          errorDiv.textContent = message;
        }
        console.error('[JS] Error: ' + message);
        notifyFlutter('error:' + message);
      }
      
      // Function to receive chunks from Flutter
      window.receiveModelChunks = function(receivedChunks) {
        console.log('[JS] Received ' + receivedChunks.length + ' chunks from Flutter');
        chunks = receivedChunks;
        // Try to load model if library is ready
        if (window.modelViewerLibraryReady) {
          console.log('[JS] Library ready, starting model load...');
          setTimeout(function() {
            loadModel();
          }, 300);
        } else {
          console.log('[JS] Waiting for model-viewer library to load...');
        }
      };
      
      function createBlobUrl() {
        try {
          if (!chunks || chunks.length === 0) {
            console.error('[JS] No chunks available yet');
            return false;
          }
          console.log('[JS] Creating blob URL from ' + chunks.length + ' chunks...');
          const base64Data = chunks.join('');
          console.log('[JS] Base64 length: ' + base64Data.length);
          
          const binaryString = atob(base64Data);
          const bytes = new Uint8Array(binaryString.length);
          for (let i = 0; i < binaryString.length; i++) {
            bytes[i] = binaryString.charCodeAt(i);
          }
          
          const blob = new Blob([bytes], { type: 'model/gltf-binary' });
          blobUrl = URL.createObjectURL(blob);
          console.log('[JS] Blob URL created: ' + blobUrl.substring(0, 50) + '...');
          return true;
        } catch (error) {
          console.error('[JS] Blob creation error:', error);
          showError('Error processing 3D model: ' + error.message);
          return false;
        }
      }
      
      function loadModel() {
        try {
          retryCount++;
          console.log('[JS] Attempt ' + retryCount + ' to load model...');
          
          const modelViewer = document.getElementById('model-viewer');
          if (!modelViewer) {
            console.log('[JS] Model viewer element not found, retrying...');
            if (retryCount < maxRetries) {
              setTimeout(loadModel, 100);
            } else {
              showError('Model viewer element not found');
            }
            return;
          }
          
          // Check if model-viewer custom element is defined
          const isDefined = typeof customElements !== 'undefined' && customElements.get('model-viewer');
          if (!isDefined) {
            if (retryCount < maxRetries) {
              if (retryCount % 20 === 0) {
                console.log('[JS] Waiting for model-viewer library... (' + retryCount + ')');
              }
              setTimeout(loadModel, 100);
            } else {
              console.error('[JS] Model-viewer not defined after ' + maxRetries + ' retries');
              showError('3D viewer library not loaded. Check internet connection.');
            }
            return;
          }
          
          console.log('[JS] Model-viewer library is ready!');
          window.modelViewerLibraryReady = true;
          
          // Check if we have chunks, if not wait for them
          if (!chunks || chunks.length === 0) {
            console.log('[JS] Waiting for model chunks from Flutter...');
            return;
          }
          
          // Create blob URL if needed
          if (!blobUrl) {
            if (!createBlobUrl()) {
              return;
            }
          }
          
          // Load model (only once)
          if (!loadAttempted && blobUrl) {
            loadAttempted = true;
            console.log('[JS] Setting model source to blob URL...');
            modelViewer.src = blobUrl;
            
            // Multiple event listeners for reliability
            const onLoad = function(event) {
              console.log('[JS] Model loaded event: ' + (event.type || 'unknown'));
              if (!modelLoaded) {
                modelLoaded = true;
                hideLoading();
                // Make sure model-viewer is visible
                if (modelViewer) {
                  modelViewer.style.display = 'block';
                  modelViewer.style.visibility = 'visible';
                  console.log('[JS] Model-viewer made visible');
                }
                notifyFlutter('modelLoaded');
              }
            };
            
            // Try multiple events
            modelViewer.addEventListener('load', onLoad, { once: true });
            modelViewer.addEventListener('model-loaded', onLoad, { once: true });
            modelViewer.addEventListener('poster-dismissed', onLoad, { once: true });
            modelViewer.addEventListener('progress', function(e) {
              const progress = e.detail ? e.detail.totalProgress : 0;
              console.log('[JS] Model progress: ' + progress);
              if (progress >= 1.0 && !modelLoaded) {
                onLoad(e);
              }
            });
            
            modelViewer.addEventListener('error', function(event) {
              console.error('[JS] Model error event:', event);
              const errorMsg = event.detail ? event.detail.message : 'Error loading 3D model';
              showError('Error loading 3D model: ' + errorMsg);
            }, { once: true });
            
            // Fallback: hide loading after 15 seconds if no event fires
            setTimeout(function() {
              if (!modelLoaded) {
                console.log('[JS] Timeout - hiding loading anyway');
                hideLoading();
                notifyFlutter('modelLoaded');
              }
            }, 15000);
            
            // Also check periodically if model is actually loaded
            let checkCount = 0;
            const checkInterval = setInterval(function() {
              checkCount++;
              if (modelViewer.loaded || modelViewer.readyState === 4) {
                console.log('[JS] Model appears to be loaded (readyState check)');
                if (!modelLoaded) {
                  modelLoaded = true;
                  hideLoading();
                  notifyFlutter('modelLoaded');
                }
                clearInterval(checkInterval);
              } else if (checkCount > 150) {
                // Stop checking after 15 seconds
                clearInterval(checkInterval);
              }
            }, 100);
          }
          
        } catch (error) {
          console.error('[JS] Error in loadModel:', error);
          showError('Error: ' + error.message);
        }
      }
      
      // Wait for model-viewer to be ready
      window.onModelViewerReady = function() {
        console.log('[JS] Model-viewer ready callback called');
        window.modelViewerLibraryReady = true;
        // Check if we have chunks, if yes try to load
        if (chunks && chunks.length > 0) {
          setTimeout(function() {
            loadModel();
          }, 300);
        } else {
          console.log('[JS] Model-viewer ready, waiting for chunks from Flutter...');
        }
      };
      
      // Expose force load function for external calls
      window.forceLoadModel = function() {
        console.log('[JS] Force load model called');
        if (!loadAttempted) {
          loadModel();
        }
      };
      
      // Start loading when page is ready
      console.log('[JS] Initializing model loader...');
      console.log('[JS] Document ready state: ' + document.readyState);
      console.log('[JS] Custom elements available: ' + (typeof customElements !== 'undefined'));
      
      function startLoading() {
        // Check if model-viewer is already loaded
        if (window.modelViewerLoaded) {
          console.log('[JS] Model-viewer already loaded, starting immediately');
          setTimeout(function() {
            loadModel();
          }, 300);
        } else {
          // Wait for module to load (max 15 seconds)
          let waitCount = 0;
          const checkModule = setInterval(function() {
            waitCount++;
            if (window.modelViewerLoaded || customElements.get('model-viewer')) {
              console.log('[JS] Model-viewer detected, starting load');
              clearInterval(checkModule);
              setTimeout(function() {
                loadModel();
              }, 300);
            } else if (waitCount > 150) {
              console.error('[JS] Model-viewer module timeout');
              clearInterval(checkModule);
              loadModel(); // Try anyway
            }
          }, 100);
        }
      }
      
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', startLoading);
      } else {
        startLoading();
      }
    })();
  </script>
</body>
</html>
''';

      if (mounted) {
        debugPrint('Loading HTML content into WebView (without model data)...');
        // Load HTML first without model data to avoid data URI size limit
        await _controller.loadRequest(
          Uri.dataFromString(
            htmlContent,
            mimeType: 'text/html',
            encoding: Encoding.getByName('utf-8'),
          ),
        );
        debugPrint('HTML content loaded successfully');

        // Wait for page to finish loading, then inject model data
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            debugPrint('Injecting model data via JavaScript...');
            // Inject chunks via JavaScript
            final String chunksJson = jsonEncode(chunks);
            _controller.runJavaScript('''
              if (typeof window.receiveModelChunks === 'function') {
                window.receiveModelChunks($chunksJson);
              } else {
                console.error('[JS] receiveModelChunks function not found');
              }
            ''');
            debugPrint('Model data injected successfully');
          }
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error loading 3D model: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading 3D model: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // WebView with 3D model
          if (_isControllerInitialized)
            WebViewWidget(controller: _controller)
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A237E),
                    const Color(0xFF3949AB),
                    const Color(0xFF5C6BC0),
                  ],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          // Loading indicator or error message
          if (_isLoading || _errorMessage != null)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A237E),
                    const Color(0xFF3949AB),
                    const Color(0xFF5C6BC0),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_errorMessage == null)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 64,
                      ),
                    const SizedBox(height: 20),
                    Text(
                      _errorMessage ?? 'Loading 3D Model...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _errorMessage = null;
                            _isLoading = true;
                          });
                          _initializeWebView();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1A237E),
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // Top bar with close button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.roomName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom button to go to VR
          if (widget.participants != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF6093D), Color(0xFF2C2225)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF6093D).withOpacity(0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => VRRoomExperiencePage(
                                  roomName: widget.roomName,
                                  participants: widget.participants!,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.vrpano_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Continue in VR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

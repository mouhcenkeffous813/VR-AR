import 'dart:async';
import 'package:flutter/material.dart';
import 'package:youth_center/utils/app_colors.dart';
import 'package:youth_center/services/database_service.dart';
import 'package:youth_center/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

class LivePage extends StatefulWidget {
  final String projectTitle;

  const LivePage({super.key, required this.projectTitle});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isMuted = false;
  bool _isCameraOff = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadMessages();
    // Auto-refresh messages every 2 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _loadMessages();
    });
  }

  Future<void> _initializeCamera() async {
    try {
      // Longer delay to ensure Flutter engine and native plugins are fully initialized
      await Future.delayed(const Duration(milliseconds: 500));

      // Request camera permission first
      final cameraStatus = await Permission.camera.request();
      final microphoneStatus = await Permission.microphone.request();

      if (!cameraStatus.isGranted) {
        throw Exception(
          'Camera permission denied. Please enable it in settings.',
        );
      }

      if (!microphoneStatus.isGranted) {
        // Microphone is optional, we can continue without it
        print('Microphone permission denied, continuing without audio');
      }

      // Get available cameras with timeout and retry
      List<CameraDescription>? cameras;
      int retries = 5;
      Exception? lastError;
      while (retries > 0) {
        try {
          cameras = await availableCameras().timeout(
            const Duration(seconds: 10),
          );
          break;
        } catch (e) {
          lastError = e is Exception ? e : Exception(e.toString());
          retries--;
          if (retries == 0) {
            // If channel error, suggest rebuilding the app
            if (e.toString().contains('channel') ||
                e.toString().contains('ProcessCameraProvider')) {
              throw Exception(
                'Camera plugin connection failed. Please restart the app or rebuild.\n'
                'Original error: $e',
              );
            }
            rethrow;
          }
          // Increase delay between retries
          await Future.delayed(Duration(milliseconds: 500 * (6 - retries)));
        }
      }

      if (cameras == null || cameras.isEmpty) {
        throw Exception('No cameras available on this device');
      }

      // Try to use front camera first, fallback to any camera
      CameraDescription selectedCamera;
      try {
        selectedCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
      } catch (e) {
        selectedCamera = cameras.first;
      }

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: microphoneStatus.isGranted,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraInitialized = true; // Set to true to show error message
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing camera: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
      }
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _refreshTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _dbService.getWilayaMessages(widget.projectTitle);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        // Auto-scroll to bottom when new messages arrive
        if (_scrollController.hasClients && _messages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to send messages'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      _messageController.clear();
      await _dbService.sendWilayaMessage(
        wilayaName: widget.projectTitle,
        message: message,
        userId: userId,
      );
      await _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending message: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final userEmail = Supabase.instance.client.auth.currentUser?.email;
    final displayName = userEmail?.split('@')[0] ?? 'User';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              widget.projectTitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Camera Preview Section
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            color: Colors.black,
            child: Stack(
              children: [
                // Camera Preview
                _isCameraInitialized && _cameraController != null
                    ? SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: CameraPreview(_cameraController!),
                      ),
                    )
                    : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Initializing camera...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                // Control buttons overlay (bottom left)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      // Mute button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isMuted = !_isMuted;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isMuted ? Icons.mic_off : Icons.mic,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Camera button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCameraOff = !_isCameraOff;
                          });
                          if (_isCameraOff && _cameraController != null) {
                            // You can stop the preview or show a black screen
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isCameraOff ? Icons.videocam_off : Icons.videocam,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Overlay when camera is off
                if (_isCameraOff)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black,
                      child: const Center(
                        child: Icon(
                          Icons.videocam_off,
                          color: Colors.white70,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Chat Section
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Chat Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF194CBF),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.chat, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Live Chat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Messages List
                  Expanded(
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _messages.isEmpty
                            ? Center(
                              child: Text(
                                'No messages yet. Start the conversation!',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            )
                            : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
                                final isMyMessage =
                                    message.userId == currentUserId;
                                return _buildMessageBubble(
                                  message,
                                  isMyMessage,
                                  displayName,
                                );
                              },
                            ),
                  ),

                  // Message Input
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(
                                  color: AppColors.borderDefault,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide(
                                  color: AppColors.borderDefault,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                  color: Color(0xFF194CBF),
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                            ),
                            maxLines: null,
                            textCapitalization: TextCapitalization.sentences,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF194CBF),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _sendMessage,
                            icon: const Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    MessageModel message,
    bool isMyMessage,
    String currentUserName,
  ) {
    final userName = message.userName ?? currentUserName;

    return Align(
      alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMyMessage) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 4),
                child: Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isMyMessage ? const Color(0xFF194CBF) : AppColors.grey100,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight:
                      isMyMessage
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                  bottomLeft:
                      isMyMessage
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                ),
              ),
              child: Text(
                message.message,
                style: TextStyle(
                  fontSize: 15,
                  color: isMyMessage ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: EdgeInsets.only(
                left: isMyMessage ? 0 : 4,
                right: isMyMessage ? 4 : 0,
              ),
              child: Text(
                _formatTime(message.createdAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

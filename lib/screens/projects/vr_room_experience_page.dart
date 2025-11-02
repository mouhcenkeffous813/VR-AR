import 'dart:math';
import 'package:flutter/material.dart';

class VRRoomExperiencePage extends StatefulWidget {
  final String roomName;
  final int participants;

  const VRRoomExperiencePage({
    super.key,
    required this.roomName,
    required this.participants,
  });

  @override
  State<VRRoomExperiencePage> createState() => _VRRoomExperiencePageState();
}

class _VRRoomExperiencePageState extends State<VRRoomExperiencePage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildFloatingParticle(AnimationController controller, double delay) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final angle = controller.value * 2 * pi + delay;
        final radius = 100.0 + sin(controller.value * 2 * pi) * 30;
        final x = cos(angle) * radius;
        final y = sin(angle) * radius;
        
        return Positioned(
          left: MediaQuery.of(context).size.width / 2 + x,
          top: MediaQuery.of(context).size.height / 2 + y,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated 3D-like background
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: SweepGradient(
                    center: Alignment.center,
                    startAngle: _rotationController.value * 2 * pi,
                    endAngle: (_rotationController.value * 2 * pi) + (pi / 2),
                    colors: [
                      const Color(0xFF1A237E),
                      const Color(0xFF3949AB),
                      const Color(0xFF5C6BC0),
                      const Color(0xFF7986CB),
                      const Color(0xFF9FA8DA),
                      const Color(0xFF3949AB),
                      const Color(0xFF1A237E),
                    ],
                  ),
                ),
              );
            },
          ),

          // Floating particles
          ...List.generate(
            20,
            (index) => _buildFloatingParticle(
              _rotationController,
              (index * pi) / 10,
            ),
          ),

          // 3D Grid effect
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return CustomPaint(
                painter: Grid3DPainter(
                  rotation: _rotationController.value * 2 * pi,
                ),
                child: Container(),
              );
            },
          ),

          // Content overlay
          FadeTransition(
            opacity: _fadeController,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isLandscape = constraints.maxWidth > constraints.maxHeight;
                  final screenHeight = constraints.maxHeight;
                  
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: screenHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Top bar with exit button
                          Padding(
                            padding: EdgeInsets.all(isLandscape ? 12 : 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.people_rounded,
                                        color: Colors.white70,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${widget.participants} Online',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // VR Headset instruction card
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isLandscape ? 40 : 24,
                              vertical: isLandscape ? 20 : 0,
                            ),
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  padding: EdgeInsets.all(isLandscape ? 24 : 32),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(
                                        0.3 + (_pulseController.value * 0.3),
                                      ),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF9FA8DA).withOpacity(
                                          0.3 + (_pulseController.value * 0.2),
                                        ),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // VR Headset icon
                                      Container(
                                        padding: EdgeInsets.all(isLandscape ? 16 : 24),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              const Color(0xFF9FA8DA),
                                              const Color(0xFF7986CB),
                                            ],
                                          ),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF9FA8DA).withOpacity(0.5),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.vrpano_rounded,
                                          color: Colors.white,
                                          size: isLandscape ? 48 : 64,
                                        ),
                                      ),
                                      SizedBox(height: isLandscape ? 16 : 24),
                                      Text(
                                        'Put on your VR headset',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isLandscape ? 22 : 28,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.5),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: isLandscape ? 8 : 12),
                                      Text(
                                        'Welcome to ${widget.roomName}',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: isLandscape ? 15 : 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: isLandscape ? 20 : 32),
                                      // Continue button
                                      Container(
                                        width: double.infinity,
                                        height: isLandscape ? 48 : 56,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF9FA8DA),
                                              Color(0xFF7986CB),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF9FA8DA).withOpacity(0.5),
                                              blurRadius: 20,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Entering ${widget.roomName}...',
                                                ),
                                                backgroundColor: const Color(0xFF7986CB),
                                                duration: const Duration(seconds: 2),
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
                                          child: Text(
                                            'Continue in VR',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isLandscape ? 16 : 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: isLandscape ? 12 : 16),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: Text(
                                          'Exit VR Space',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: isLandscape ? 14 : 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: isLandscape ? 20 : 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Grid3DPainter extends CustomPainter {
  final double rotation;

  Grid3DPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw 3D grid lines
    for (int i = -5; i <= 5; i++) {
      final offset = i * 80.0;
      
      // Horizontal lines
      final startX = centerX - 300 + offset * cos(rotation);
      final startY = centerY + offset * sin(rotation);
      final endX = centerX + 300 + offset * cos(rotation);
      final endY = centerY + offset * sin(rotation);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
      
      // Vertical lines
      final vStartX = centerX + offset * cos(rotation);
      final vStartY = centerY - 300 + offset * sin(rotation);
      final vEndX = centerX + offset * cos(rotation);
      final vEndY = centerY + 300 + offset * sin(rotation);
      
      canvas.drawLine(
        Offset(vStartX, vStartY),
        Offset(vEndX, vEndY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(Grid3DPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}


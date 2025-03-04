// lib/widgets/player/vinyl_record.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class VinylRecord extends StatefulWidget {
  final String albumArt;
  final bool isPlaying;
  final double size;
  
  const VinylRecord({
    Key? key,
    required this.albumArt,
    required this.isPlaying,
    required this.size,
  }) : super(key: key);
  
  @override
  _VinylRecordState createState() => _VinylRecordState();
}

class _VinylRecordState extends State<VinylRecord> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  
  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    
    if (!widget.isPlaying) {
      _rotationController.stop();
    }
  }
  
  @override
  void didUpdateWidget(VinylRecord oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final vinylSize = widget.size;
    final albumSize = vinylSize * 0.62; // Album art takes 62% of vinyl size
    
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vinyl record
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: child,
              );
            },
            child: Container(
              width: vinylSize,
              height: vinylSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black87,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Vinyl grooves
                  _buildVinylGrooves(vinylSize),
                  
                  // Center hole
                  Container(
                    width: vinylSize * 0.08,
                    height: vinylSize * 0.08,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  
                  // Album art in center
                  ClipOval(
                    child: Container(
                      width: albumSize,
                      height: albumSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(widget.albumArt),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Center label that doesn't rotate
          Container(
            width: vinylSize * 0.08,
            height: vinylSize * 0.08,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVinylGrooves(double size) {
    // Create multiple circular grooves in the vinyl record
    return CustomPaint(
      size: Size(size, size),
      painter: VinylGroovesPainter(),
    );
  }
}

class VinylGroovesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Create grooves of different radiuses
    final Paint groovePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Outer label ring (thicker)
    canvas.drawCircle(
      center,
      radius * 0.35,
      Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
    
    // Draw multiple grooves from inner to outer
    for (double factor = 0.4; factor < 0.98; factor += 0.05) {
      canvas.drawCircle(
        center,
        radius * factor,
        groovePaint,
      );
    }
    
    // Add some random shorter grooves for texture
    final random = math.Random(42);
    for (int i = 0; i < 10; i++) {
      final startAngle = random.nextDouble() * 2 * math.pi;
      final sweepAngle = (random.nextDouble() * 0.5 + 0.5) * math.pi / 2;
      final radiusFactor = random.nextDouble() * 0.5 + 0.45;
      
      canvas.drawArc(
        Rect.fromCenter(
          center: center,
          width: radius * radiusFactor * 2,
          height: radius * radiusFactor * 2,
        ),
        startAngle,
        sweepAngle,
        false,
        groovePaint,
      );
    }
    
    // Add highlight reflection
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    final highlightPath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.8)
      ..quadraticBezierTo(
        center.dx + radius * 0.1,
        center.dy - radius * 0.2,
        center.dx + radius * 0.4,
        center.dy - radius * 0.4,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.3,
        center.dy - radius * 0.8,
        center.dx,
        center.dy - radius * 0.8,
      );
    
    canvas.drawPath(highlightPath, highlightPaint);
  }
  
  @override
  bool shouldRepaint(VinylGroovesPainter oldDelegate) => false;
}
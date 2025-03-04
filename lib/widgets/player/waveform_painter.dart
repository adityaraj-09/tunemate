// lib/widgets/player/waveform_painter.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveformPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final double spacing;
  final double barWidth;
  final List<double>? amplitudes;
  
  WaveformPainter({
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    this.spacing = 2.0,
    this.barWidth = 3.0,
    this.amplitudes,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Generate random amplitudes if not provided
    final List<double> bars = amplitudes ?? _generateRandomBars(size);
    
    final int barCount = bars.length;
    final double progressX = size.width * progress;
    
    // Draw each bar
    for (int i = 0; i < barCount; i++) {
      final double height = bars[i] * size.height;
      final double left = i * (barWidth + spacing);
      final double top = (size.height - height) / 2;
      
      final Paint paint = Paint()
        ..color = left <= progressX ? activeColor : inactiveColor
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.fill;
      
      final Rect rect = Rect.fromLTWH(left, top, barWidth, height);
      final RRect rRect = RRect.fromRectAndRadius(rect, const Radius.circular(2.0));
      
      canvas.drawRRect(rRect, paint);
    }
  }
  
  List<double> _generateRandomBars(Size size) {
    final math.Random random = math.Random(42); // Fixed seed for consistent visualization
    int barCount = (size.width / (barWidth + spacing)).floor();
    
    List<double> bars = [];
    for (int i = 0; i < barCount; i++) {
      // Create a more natural looking waveform
      double value = 0.1 + 0.8 * _smoothedRandom(i / barCount * 10, random);
      bars.add(value);
    }
    
    return bars;
  }
  
  // Creates smoother random values for more natural waveform
  double _smoothedRandom(double position, math.Random random) {
    // Use a sine wave to create a more musical-looking pattern
    double base = math.sin(position) * 0.5 + 0.5;
    
    // Add some randomness
    double randomComponent = random.nextDouble() * 0.3;
    
    return math.min(1.0, math.max(0.1, base + randomComponent));
  }
  
  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.activeColor != activeColor ||
           oldDelegate.inactiveColor != inactiveColor;
  }
}
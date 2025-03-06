// lib/widgets/onboarding/animated_onboarding_content.dart
// This widget adds a more sophisticated animation to the onboarding content

import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedOnboardingContent extends StatefulWidget {
  final String title;
  final String description;
  final Widget image;
  final Color primaryColor;

  const AnimatedOnboardingContent({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    required this.primaryColor,
  }) : super(key: key);

  @override
  _AnimatedOnboardingContentState createState() => _AnimatedOnboardingContentState();
}

class _AnimatedOnboardingContentState extends State<AnimatedOnboardingContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.25), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    // Slight delay to make animation more noticeable
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated image
            FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildAnimatedImage(),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Animated title
            FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.3),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
                  ),
                ),
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Animated description
            FadeTransition(
              opacity: _fadeInAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.4),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    widget.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildAnimatedImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer animated circle
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Container(
              height: 280,
              width: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  center: Alignment.center,
                  startAngle: 0.0,
                  endAngle: math.pi * 2 * value,
                  colors: [
                    widget.primaryColor.withOpacity(0.1),
                    widget.primaryColor.withOpacity(0.2),
                  ],
                ),
              ),
            );
          },
        ),
        
        // Middle pulsing circle
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.95, end: 1.05),
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                height: 240,
                width: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.primaryColor.withOpacity(0.1),
                ),
              ),
            );
          },
          child: null,
        ),
        
        // Inner animated circle
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 3),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.rotate(
              angle: 2 * math.pi * value,
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.primaryColor.withOpacity(0.1),
                      widget.primaryColor.withOpacity(0.15),
                    ],
                    stops: const [0.7, 1.0],
                  ),
                ),
                child: child,
              ),
            );
          },
          child: Center(
            child: widget.image,
          ),
        ),
        
        // Floating particles
        ..._buildFloatingParticles(),
      ],
    );
  }
  
  List<Widget> _buildFloatingParticles() {
    final List<Widget> particles = [];
    final random = math.Random(42); // Fixed seed for consistent results
    
    for (int i = 0; i < 8; i++) {
      final size = random.nextDouble() * 10 + 5;
      final initialAngle = random.nextDouble() * math.pi * 2;
      final radius = 110 + random.nextDouble() * 30;
      final duration = Duration(seconds: 4 + random.nextInt(4));
      
      particles.add(
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: duration,
          curve: Curves.linear,
          builder: (context, value, child) {
            final angle = initialAngle + (math.pi * 2 * value);
            return Positioned(
              left: 140 + radius * math.cos(angle) - (size / 2),
              top: 140 + radius * math.sin(angle) - (size / 2),
              child: Opacity(
                opacity: 0.7,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    return particles;
  }
}

// Enhanced version of OnboardingPage that uses the animated content
class EnhancedOnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final double imageSize;
  final Color imageColor;
  final IconData iconData;

  const EnhancedOnboardingPage({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
    this.imageSize = 160,
    required this.imageColor,
    required this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: AnimatedOnboardingContent(
        title: title,
        description: description,
        primaryColor: imageColor,
        image: Image.asset(
          image,
          height: imageSize,
          width: imageSize,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              iconData,
              size: imageSize * 0.6,
              color: imageColor,
            );
          },
        ),
      ),
    );
  }
}
// lib/widgets/common/error_view.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final bool showImage;
  final double imageSize;

  const ErrorView({
    Key? key,
    required this.error,
    required this.onRetry,
    this.showImage = true,
    this.imageSize = 120.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showImage) ...[
              // Error illustration
              Image.asset(
                'assets/images/error.png',
                height: imageSize,
                width: imageSize,
                // If asset not available, show icon instead
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.error_outline,
                    size: imageSize,
                    color: Colors.red.shade300,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
            
            // Error title
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Error message
            Text(
              error,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.mutedGrey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Retry button
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Help text
            const Text(
              'If the problem persists, please try again later',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.mutedGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// A simpler, more compact version of the error view for inline usage
class CompactErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const CompactErrorView({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red.shade700,
              elevation: 0,
              side: BorderSide(
                color: Colors.red.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
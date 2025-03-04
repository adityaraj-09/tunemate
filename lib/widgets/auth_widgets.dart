// lib/widgets/auth_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../config/theme.dart';

/// Custom text field with consistent styling for auth screens
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final TextInputAction? textInputAction;
  
  const AppTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
    this.focusNode,
    this.onEditingComplete,
    this.textInputAction,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        autofocus: autofocus,
        focusNode: focusNode,
        onEditingComplete: onEditingComplete,
        textInputAction: textInputAction,
        style: const TextStyle(
          color: AppTheme.onSurfaceColor,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

/// Password field with visibility toggle
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final TextInputAction? textInputAction;
  
  const PasswordField({
    Key? key,
    required this.controller,
    this.label = 'Password',
    this.hint,
    this.validator,
    this.focusNode,
    this.onEditingComplete,
    this.textInputAction,
  }) : super(key: key);
  
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;
  
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      obscureText: _obscureText,
      validator: widget.validator,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.grey,
        ),
        onPressed: _togglePasswordVisibility,
      ),
      focusNode: widget.focusNode,
      onEditingComplete: widget.onEditingComplete,
      textInputAction: widget.textInputAction,
    );
  }
}

/// Button with gradient background
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final LinearGradient? gradient;
  final double width;
  final double height;
  final bool isLoading;
  
  const GradientButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.width = double.infinity,
    this.height = 50,
    this.isLoading = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}

/// Button for social media login
class SocialLoginButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  
  const SocialLoginButton({
    Key? key,
    required this.text,
    required this.iconPath,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Image.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Wave clipper for curved background
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.85);
    
    var firstControlPoint = Offset(size.width * 0.25, size.height);
    var firstEndPoint = Offset(size.width * 0.5, size.height * 0.85);
    path.quadraticBezierTo(
      firstControlPoint.dx, 
      firstControlPoint.dy, 
      firstEndPoint.dx, 
      firstEndPoint.dy
    );
    
    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.7);
    var secondEndPoint = Offset(size.width, size.height * 0.85);
    path.quadraticBezierTo(
      secondControlPoint.dx, 
      secondControlPoint.dy, 
      secondEndPoint.dx, 
      secondEndPoint.dy
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Divider with text in the middle
class AuthDivider extends StatelessWidget {
  final String text;
  
  const AuthDivider({
    Key? key,
    required this.text,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppTheme.lightGrey,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.mutedGrey,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppTheme.lightGrey,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

/// Rounded button with outline style
class OutlinedRoundButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;
  final Color color;
  
  const OutlinedRoundButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.color = AppTheme.primaryColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// Terms and Conditions text with clickable links
class TermsText extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;
  
  const TermsText({
    Key? key,
    required this.accepted,
    required this.onChanged,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: accepted,
          activeColor: AppTheme.primaryColor,
          onChanged: onChanged,
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppTheme.mutedGrey,
                fontSize: 12,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onTermsPressed,
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onPrivacyPressed,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Logo header with app name and tagline
class LogoHeader extends StatelessWidget {
  final double height;
  
  const LogoHeader({
    Key? key,
    this.height = 0.35,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    
    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: mediaQuery.size.height * height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 16),
              const Text(
                'Music Match',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Text(
                'Connect through music',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Step indicator for multi-step forms
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;
  
  const StepIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps * 2 - 1, (index) {
        // Even indices are step indicators, odd indices are connectors
        if (index.isEven) {
          final step = index ~/ 2;
          return _buildStepIndicator(step, stepLabels[step]);
        } else {
          final step = index ~/ 2;
          return _buildStepConnector(step);
        }
      }),
    );
  }
  
  Widget _buildStepIndicator(int step, String label) {
    final isActive = currentStep >= step;
    final isCompleted = currentStep > step;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.primaryColor : Colors.grey,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStepConnector(int step) {
    final isActive = currentStep > step;
    
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
      ),
    );
  }
}

/// Date picker field with custom styling
class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final String label;
  final Function(DateTime) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? helperText;
  
  const DatePickerField({
    Key? key,
    required this.selectedDate,
    required this.label,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.helperText,
  }) : super(key: key);
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime minDate = firstDate ?? DateTime(now.year - 100, now.month, now.day);
    final DateTime maxDate = lastDate ?? now;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? maxDate,
      firstDate: minDate,
      lastDate: maxDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.onSurfaceColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }
  
  String get _formattedDate {
    if (selectedDate == null) return label;
    
    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: AppTheme.mutedGrey),
        title: Text(
          _formattedDate,
          style: TextStyle(
            color: selectedDate == null ? AppTheme.mutedGrey : AppTheme.onSurfaceColor,
          ),
        ),
        subtitle: helperText != null 
            ? Text(helperText!, style: const TextStyle(fontSize: 12))
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }
}
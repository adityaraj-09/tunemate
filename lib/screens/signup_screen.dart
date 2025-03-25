// lib/screens/auth/sign_up_screen.dart
import 'package:app/routes/router.dart';
import 'package:app/screens/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_widgets.dart';
import 'package:go_router/go_router.dart';
class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';
  
  const SignUpScreen({Key? key}) : super(key: key);
  
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Focus nodes
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  
  // Text controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  
  // Animation
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  
  int _currentStep = 0;
  bool _termsAccepted = false;
  DateTime? _birthDate;
  String? _selectedGender;
  
  final List<String> _genderOptions = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];
  final List<String> _stepLabels = ['Account', 'Personal'];
  
  @override
  void initState() {
    super.initState();
    
    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuint,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    super.dispose();
  }
  
  // Validate first step of the form
  bool _validateStep1() {
    final formState = _formKey.currentState;
    if (formState == null) return false;
    
    if (!formState.validate()) return false;
    
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms and Privacy Policy'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return false;
    }
    
    return true;
  }
  
  // Navigate to next step
  void _nextStep() {
    if (_currentStep == 0 && !_validateStep1()) {
      return;
    }
    
    if (_currentStep < _stepLabels.length - 1) {
      setState(() {
        _currentStep += 1;
      });
      
      // Play animation when switching steps
      _animationController.reset();
      _animationController.forward();
    } else {
      _submitForm();
    }
  }
  
  // Navigate to previous step
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
      
      // Play animation when switching steps
      _animationController.reset();
      _animationController.forward();
    } else {
      Navigator.of(context).pop();
    }
  }
  
  // Calculate age from birthdate
  int? get _age {
    if (_birthDate == null) return null;
    
    final now = DateTime.now();
    int age = now.year - _birthDate!.year;
    
    if (now.month < _birthDate!.month || 
        (now.month == _birthDate!.month && now.day < _birthDate!.day)) {
      age--;
    }
    
    return age;
  }
  
  // Submit form to create account
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    
    final success = await authProvider.signUp(
      username: username,
      email: email,
      password: password,
      firstName: firstName.isNotEmpty ? firstName : null,
      lastName: lastName.isNotEmpty ? lastName : null,
      birthDate: _birthDate,
      gender: _selectedGender == 'Prefer not to say' ? null : _selectedGender,
    );
    if(success && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully'),
          backgroundColor: AppTheme.accentPurple,
        ),
      );

      context.go("/");
      
    }
    
    if (!success && mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
  
  // Show terms of service
  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam euismod, '
            'nisi vel tincidunt consectetur, nisl nunc euismod nisi, vitae '
            'tincidunt nisl nunc euismod nisi. Nullam euismod, nisi vel tincidunt consectetur, '
            'nisl nunc euismod nisi.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  // Show privacy policy
  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam euismod, '
            'nisi vel tincidunt consectetur, nisl nunc euismod nisi, vitae '
            'tincidunt nisl nunc euismod nisi. Nullam euismod, nisi vel tincidunt consectetur, '
            'nisl nunc euismod nisi.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isRegistering = authProvider.isRegistering;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button and header
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios),
                            onPressed: _previousStep,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentStep == 0 ? 'Create Account' : 'Personal Info',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.onSurfaceColor,
                                ),
                              ),
                              Text(
                                _currentStep == 0 
                                    ? 'Sign up to get started' 
                                    : 'Tell us more about yourself',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.mutedGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Steps indicators
                      StepIndicator(
                        currentStep: _currentStep,
                        totalSteps: _stepLabels.length,
                        stepLabels: _stepLabels,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Form fields based on current step
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.1, 0),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: _currentStep == 0
                            ? _buildStep1Fields()
                            : _buildStep2Fields(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Next/Sign Up button
                      GradientButton(
                        text: _currentStep == 0 ? 'NEXT' : 'CREATE ACCOUNT',
                        onPressed: _nextStep,
                        isLoading: isRegistering,
                      ),
                      
                      if (_currentStep == 0) ...[
                        const SizedBox(height: 24),
                        
                        // OR divider
                        const AuthDivider(text: 'OR'),
                        
                        const SizedBox(height: 24),
                        
                        // Social login buttons
                        SocialLoginButton(
                          text: 'Continue with Google',
                          iconPath: 'assets/icons/google.png',
                          onPressed: () {},
                        ),
                        
                      
                        const SizedBox(height: 32),
                        
                        // Sign in option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(
                                color: AppTheme.mutedGrey,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  // Step 1 fields - Account information
  Widget _buildStep1Fields() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username field
        AppTextField(
          controller: _usernameController,
          label: 'Username',
          hint: 'Choose a unique username',
          prefixIcon: const Icon(Icons.person_outline),
          textInputAction: TextInputAction.next,
          focusNode: _usernameFocus,
          onEditingComplete: () {
            FocusScope.of(context).requestFocus(_emailFocus);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a username';
            }
            if (value.length < 3) {
              return 'Username must be at least 3 characters';
            }
            return null;
          },
        ),
        
        // Email field
        AppTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'Enter your email address',
          prefixIcon: const Icon(Icons.email_outlined),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          focusNode: _emailFocus,
          onEditingComplete: () {
            FocusScope.of(context).requestFocus(_passwordFocus);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                
            if (!emailRegex.hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            
            return null;
          },
        ),
        
        
        // Password field
        PasswordField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          textInputAction: TextInputAction.next,
          hint: 'At least 8 characters with 1 number',
          onEditingComplete: () {
            FocusScope.of(context).requestFocus(_confirmPasswordFocus);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            
            if (!value.contains(RegExp(r'[0-9]'))) {
              return 'Password must contain at least one number';
            }
            
            return null;
          },
        ),
        
        // Confirm password field
        PasswordField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hint: 'Confirm your password',
          focusNode: _confirmPasswordFocus,
          textInputAction: TextInputAction.done,
          onEditingComplete: _nextStep,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Terms and conditions checkbox
        TermsText(
          accepted: _termsAccepted,
          onChanged: (value) {
            setState(() {
              _termsAccepted = value ?? false;
            });
          },
          onTermsPressed: _showTerms,
          onPrivacyPressed: _showPrivacyPolicy,
        ),
        
        // Password strength indicator (optional)
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildPasswordStrengthIndicator(),
        ],
      ],
    );
  }
  
  // Step 2 fields - Personal information
  Widget _buildStep2Fields() {
    return Column(
      key: const ValueKey('step2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First name field
        AppTextField(
          controller: _firstNameController,
          label: 'First Name',
          hint: 'Enter your first name',
          prefixIcon: const Icon(Icons.person_outline),
          textInputAction: TextInputAction.next,
          focusNode: _firstNameFocus,
          onEditingComplete: () {
            FocusScope.of(context).requestFocus(_lastNameFocus);
          },
        ),
        
        // Last name field
        AppTextField(
          controller: _lastNameController,
          label: 'Last Name',
          hint: 'Enter your last name',
          prefixIcon: const Icon(Icons.person_outline),
          textInputAction: TextInputAction.next,
          focusNode: _lastNameFocus,
        ),
        
        // Birth date field
        DatePickerField(
          selectedDate: _birthDate,
          label: 'Select your birth date',
          onDateSelected: (date) {
            setState(() {
              _birthDate = date;
            });
          },
          firstDate: DateTime(DateTime.now().year - 100),
          lastDate: DateTime(DateTime.now().year - 18),
          helperText: _age != null ? 'Age: $_age years' : null,
        ),
        
        // Gender dropdown
        Container(
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
          child: DropdownButtonFormField<String>(
            value: _selectedGender,
            hint: const Text('Select your gender'),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            items: _genderOptions.map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Music interests teaser
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.lightGrey),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.music_note_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Music Preferences',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'After signing up, you\'ll be able to select your favorite genres and artists to help us match you with like-minded music lovers!',
                style: TextStyle(
                  color: AppTheme.mutedGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        const Text(
          'Note: You can always update your profile information later.',
          style: TextStyle(
            color: AppTheme.mutedGrey,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
  
  // Password strength indicator
  Widget _buildPasswordStrengthIndicator() {
    // Calculate password strength
    final password = _passwordController.text;
    double strength = 0;
    
    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[a-z]')) && password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;
    
    // Determine strength level and color
    String strengthText;
    Color strengthColor;
    
    if (strength <= 0.25) {
      strengthText = 'Weak';
      strengthColor = Colors.red;
    } else if (strength <= 0.5) {
      strengthText = 'Medium';
      strengthColor = Colors.orange;
    } else if (strength <= 0.75) {
      strengthText = 'Strong';
      strengthColor = Colors.yellow.shade700;
    } else {
      strengthText = 'Very Strong';
      strengthColor = Colors.green;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Password Strength:',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.mutedGrey,
              ),
            ),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: strengthColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strength,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}
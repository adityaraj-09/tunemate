// lib/screens/auth/sign_in_screen.dart
import 'package:app/routes/router.dart';
import 'package:app/screens/signup_screen.dart';
import 'package:app/services/api/auth_api.dart';
import 'package:app/services/di/service_locator.dart';
import 'package:app/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/signin';

  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();

    // Set up animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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
    _passwordFocus.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // First validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final success = await authProvider.signIn(username, password);
    if (success && mounted) {
      context.go("/");
    }
    if (!success && mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _navigateToSignUp() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SignUpScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isAuthenticating = authProvider.isAuthenticating;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top wave with logo
            ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: mediaQuery.size.height * 0.3,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              image: AssetImage('assets/images/logo.jpg'),
                              fit: BoxFit.cover),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Insien',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Form container
            Padding(
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
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.onSurfaceColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in to continue',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.mutedGrey,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Username field
                        AppTextField(
                          controller: _usernameController,
                          label: 'Username or Email',
                          hint: 'Enter your username or email',
                          prefixIcon: const Icon(Icons.person_outline),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          focusNode: _usernameFocus,
                          onEditingComplete: () {
                            FocusScope.of(context).requestFocus(_passwordFocus);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username or email';
                            }
                            return null;
                          },
                        ),

                        // Password field
                        PasswordField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          textInputAction: TextInputAction.done,
                          onEditingComplete: _submitForm,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 4),

                        // Remember me and forgot password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  activeColor: AppTheme.primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                ),
                                const Text(
                                  'Remember me',
                                  style: TextStyle(
                                    color: AppTheme.mutedGrey,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () async {
                                // final authapi = getIt<AuthApiService>();
                                // await authapi.updatePassword(
                                //     "adi.ee.iitd@gmail.com", "Aditya@2004");
                              },
                              child: const Text('Forgot Password?'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Sign in button
                        GradientButton(
                          text: 'SIGN IN',
                          onPressed: _submitForm,
                          isLoading: isAuthenticating,
                        ),

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

                        // SocialLoginButton(
                        //   text: 'Continue with Facebook',
                        //   iconPath: 'assets/icons/facebook.png',
                        //   backgroundColor: const Color(0xFF1877F2),
                        //   textColor: Colors.white,
                        //   onPressed: () {},
                        // ),

                        const SizedBox(height: 32),

                        // Sign up option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: AppTheme.mutedGrey,
                              ),
                            ),
                            TextButton(
                              onPressed: _navigateToSignUp,
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

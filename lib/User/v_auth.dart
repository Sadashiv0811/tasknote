import 'package:flutter/material.dart';
import 'package:sign_button/constants.dart';
import 'package:sign_button/create_button.dart';
import 'package:tasknote/Other/constants.dart';
import 'package:tasknote/Other/stateless_widgets.dart';
import 'package:tasknote/Other/theme.dart';
import 'package:tasknote/Service/s_authentication.dart';

class VAuth extends StatefulWidget {
  const VAuth({super.key});

  @override
  State<VAuth> createState() => _VAuthState();
}

class _VAuthState extends State<VAuth> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // State variables
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Toggle between Login and Signup mode
  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _formKey.currentState?.reset();
    });
  }

  // Login/Signup with email and password
  Future<void> _emailPassword() async {
    // Check Internet First
    bool isConnected = await checkInternet();
    if (!isConnected) {
      if (!mounted) return;
      scaffoldMessenger("No internet connection");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (!mounted) return;
      final auth = AuthenticationService(context: context);

      await auth.signInWithEmailPassword(
        context,
        _isLogin,
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _fullNameController.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  //  Login/Signup with google
  Future<void> _signInWithGoogle() async {
    bool isConnected = await checkInternet();

    if (!isConnected) {
      if (!mounted) return;
      scaffoldMessenger("No internet connection");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!mounted) return;
      final auth = AuthenticationService(context: context);

      await auth.signInWithGoogle(_isLogin);
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double logoSize = getWidth(context, 0.45);
    const colors = [
      Color(0xFF54acbf),
      Color(0xFF26658c),
      Color(0xFF023859), 
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 70),

              // Logo or Header
              Container(
                height: logoSize,
                width: logoSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      blurRadius: 35,
                      spreadRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/icon/splashLogo.png', 
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isLogin ? "Welcome Back" : "Create Account",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Join us and start organizing your life",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 32),

              // Auth Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Fullname Field
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _fullNameController,
                        keyboardType: TextInputType.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 16, color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your full name";
                          }

                          if (!RegExp(
                            r"^[A-Za-z]+(?:['-][A-Za-z]+)*(?:\s+[A-Za-z]+(?:['-][A-Za-z]+)*)+$",
                          ).hasMatch(value.trim())) {
                            return "Please enter a valid full name";
                          } 
                          // Examples - Anne-Marie Smith, John O'Connor, Mary Jane Watson, Vladimir Ivanov

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 16, color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: Colors.white70),

                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.white,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your email";
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 16, color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.lock_open_rounded,
                          color: Colors.white,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            color: Colors.white,
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your password";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null;
                      },
                    ),

                    // Confirm Password (Signup only)
                    if (!_isLogin) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 16,color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          labelStyle: TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(
                            Icons.verified_user_outlined,
                            color: Colors.white,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              color: Colors.white,
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please confirm your password";
                          }
                          if (value != _passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Login/Sigup Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _emailPassword,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isLogin ? "Login" : "Sign Up",
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),

                    if (!_isLoading) ...[
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.white54)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "OR",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const Expanded(child: Divider(color: Colors.white54)),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],

                    // Google button
                    _isLoading
                        ? const SizedBox.shrink()
                        : SignInButton(
                            btnText: _isLogin
                                ? "Log in with Google"
                                : "Sign up with Google",
                            buttonType: ButtonType.google,
                            onPressed: _isLoading ? null : _signInWithGoogle,
                          ),

                    // Toggle Button
                    if (!_isLoading)
                      SizedBox(
                        child: _isLogin
                            ? Row(
                                mainAxisSize: .min,
                                mainAxisAlignment: .center,
                                children: [
                                  Text(
                                    "Don't have an account?",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextButton(
                                    onPressed: _isLoading ? null : _toggleMode,
                                    child: Text(
                                      "Sign Up",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisSize: .min,
                                mainAxisAlignment: .center,
                                children: [
                                  Text(
                                    "Already have an account?",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextButton(
                                    onPressed: _isLoading ? null : _toggleMode,
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

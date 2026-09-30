import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService =
        context.read<AuthProvider>().service;

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        bottom: false,

        child: SingleChildScrollView(
          child: Column(
            children: [
              // =====================================================
              // IMAGE HEADER
              // =====================================================
              SizedBox(
                height: 350,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/splash_city.png',
                      fit: BoxFit.cover,
                    ),

                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primaryDark
                                .withOpacity(0.10),
                            AppColors.primaryDark
                                .withOpacity(0.80),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        16,
                        24,
                        45,
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // Back
                          IconButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            alignment:
                            Alignment.centerLeft,
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),

                          const Spacer(),

                          Row(
                            children: [
                              _AuthLogo(),

                              const SizedBox(width: 10),

                              const Text(
                                'City Guide',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight:
                                  FontWeight.w800,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Welcome back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'Log in to continue exploring your city.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // =====================================================
              // WHITE FORM PANEL
              // =====================================================
              Transform.translate(
                offset: const Offset(0, -28),

                child: Container(
                  width: double.infinity,

                  padding: const EdgeInsets.fromLTRB(
                    24,
                    30,
                    24,
                    30,
                  ),

                  decoration: const BoxDecoration(
                    color: AppColors.background,

                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),

                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        if (_errorText != null) ...[
                          _ErrorBox(
                            message: _errorText!,
                          ),

                          const SizedBox(height: 16),
                        ],

                        const _FieldLabel(
                          text: 'Email address',
                        ),

                        const SizedBox(height: 7),

                        TextFormField(
                          controller: _emailController,
                          keyboardType:
                          TextInputType.emailAddress,

                          decoration:
                          const InputDecoration(
                            hintText:
                            'Enter your email',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                            ),
                          ),

                          validator: (value) {
                            if (value == null ||
                                !value.contains('@')) {
                              return 'Enter a valid email';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        const _FieldLabel(
                          text: 'Password',
                        ),

                        const SizedBox(height: 7),

                        TextFormField(
                          controller:
                          _passwordController,
                          obscureText:
                          _obscurePassword,

                          decoration: InputDecoration(
                            hintText:
                            'Enter your password',

                            prefixIcon:
                            const Icon(
                              Icons.lock_outline_rounded,
                            ),

                            suffixIcon:
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                  !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons
                                    .visibility_outlined
                                    : Icons
                                    .visibility_off_outlined,
                              ),
                            ),
                          ),

                          validator: (value) {
                            if (value == null ||
                                value.length < 6) {
                              return 'Min 6 characters';
                            }

                            return null;
                          },
                        ),

                        Align(
                          alignment:
                          Alignment.centerRight,
                          child: TextButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Forgot password?',
                            ),
                          ),
                        ),

                        const SizedBox(height: 3),

                        // Login
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                              if (!_formKey
                                  .currentState!
                                  .validate()) {
                                return;
                              }

                              final navigator =
                              Navigator.of(
                                  context);

                              setState(() {
                                _isLoading = true;
                                _errorText = null;
                              });

                              try {
                                await authService
                                    .login(
                                  email:
                                  _emailController
                                      .text
                                      .trim(),
                                  password:
                                  _passwordController
                                      .text,
                                );

                                if (!mounted) {
                                  return;
                                }

                                navigator.pop();
                              } catch (e) {
                                if (!mounted) {
                                  return;
                                }

                                setState(() {
                                  _errorText =
                                      authService
                                          .friendlyError(
                                          e);
                                });
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoading =
                                    false;
                                  });
                                }
                              }
                            },
                            style: ElevatedButton
                                .styleFrom(
                              backgroundColor:
                              AppColors.primary,
                              foregroundColor:
                              Colors.white,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    28),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'Log in',
                              style: TextStyle(
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const _OrDivider(),

                        const SizedBox(height: 16),

                        _GoogleButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                            // Connect your existing
                            // Google auth here later.
                          },
                        ),

                        const SizedBox(height: 22),

                        Center(
                          child: Wrap(
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: AppColors
                                      .textSecondary,
                                  fontSize: 13,
                                ),
                              ),

                              GestureDetector(
                                onTap: _isLoading
                                    ? null
                                    : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Sign up',
                                  style: TextStyle(
                                    color:
                                    AppColors.primary,
                                    fontWeight:
                                    FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// REUSABLE AUTH WIDGETS
// =============================================================

class _AuthLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.location_city_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;

  const _ErrorBox({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.black.withOpacity(0.10),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.black.withOpacity(0.10),
          ),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _GoogleButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          side: BorderSide(
            color: Colors.black.withOpacity(0.08),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Continue with Google',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
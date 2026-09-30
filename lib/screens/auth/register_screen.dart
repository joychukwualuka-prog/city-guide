import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
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
              // ===================================================
              // HEADER
              // ===================================================
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
                                .withOpacity(0.82),
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
                              _RegisterLogo(),

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
                            'Create your account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'Join City Guide and start exploring.',
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

              // ===================================================
              // FORM
              // ===================================================
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
                          _RegisterError(
                            message: _errorText!,
                          ),
                          const SizedBox(height: 16),
                        ],

                        const _RegisterLabel(
                          text: 'Full name',
                        ),

                        const SizedBox(height: 7),

                        TextFormField(
                          controller:
                          _nameController,
                          textCapitalization:
                          TextCapitalization.words,

                          decoration:
                          const InputDecoration(
                            hintText:
                            'Enter your full name',
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                            ),
                          ),

                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Enter your name';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        const _RegisterLabel(
                          text: 'Email address',
                        ),

                        const SizedBox(height: 7),

                        TextFormField(
                          controller:
                          _emailController,
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

                        const _RegisterLabel(
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
                            'Create a password',

                            prefixIcon: const Icon(
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

                        const SizedBox(height: 22),

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

                              setState(() {
                                _isLoading = true;
                                _errorText = null;
                              });

                              try {
                                await authService
                                    .register(
                                  name:
                                  _nameController
                                      .text
                                      .trim(),
                                  email:
                                  _emailController
                                      .text
                                      .trim(),
                                  password:
                                  _passwordController
                                      .text,
                                );
                              } catch (e) {
                                if (mounted) {
                                  setState(() {
                                    _errorText =
                                        authService
                                            .friendlyError(
                                            e);
                                  });
                                }
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
                              'Sign up',
                              style: TextStyle(
                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        const _RegisterDivider(),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _isLoading
                                ? null
                                : () {},
                            style:
                            OutlinedButton.styleFrom(
                              backgroundColor:
                              Colors.white,
                              foregroundColor:
                              AppColors.textPrimary,
                              side: BorderSide(
                                color: Colors.black
                                    .withOpacity(0.08),
                              ),
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    26),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'G',
                                  style: TextStyle(
                                    color: Color(
                                        0xFF4285F4),
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Center(
                          child: Wrap(
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: AppColors
                                      .textSecondary,
                                  fontSize: 13,
                                ),
                              ),

                              GestureDetector(
                                onTap: _isLoading
                                    ? null
                                    : () =>
                                    Navigator.pop(
                                        context),
                                child: const Text(
                                  'Log in',
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

class _RegisterLogo extends StatelessWidget {
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

class _RegisterLabel extends StatelessWidget {
  final String text;

  const _RegisterLabel({
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

class _RegisterError extends StatelessWidget {
  final String message;

  const _RegisterError({
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
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.error,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _RegisterDivider extends StatelessWidget {
  const _RegisterDivider();

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
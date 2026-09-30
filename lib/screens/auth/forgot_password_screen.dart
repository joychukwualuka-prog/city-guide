import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _emailController.dispose();
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
                              Container(
                                width: 42,
                                height: 42,
                                decoration:
                                BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.lock_reset_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),

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
                            'Reset your password',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight:
                              FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'We’ll help you get back to exploring.',
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
                    35,
                  ),

                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      if (_message != null) ...[
                        Container(
                          width: double.infinity,
                          padding:
                          const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: (_isError
                                ? AppColors.error
                                : AppColors.primary)
                                .withOpacity(0.08),
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isError
                                    ? Icons
                                    .error_outline_rounded
                                    : Icons
                                    .mark_email_read_outlined,
                                color: _isError
                                    ? AppColors.error
                                    : AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _message!,
                                  style: TextStyle(
                                    color: _isError
                                        ? AppColors.error
                                        : AppColors.primary,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),
                      ],

                      const Text(
                        'Email address',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 7),

                      TextField(
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
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                            final email =
                            _emailController
                                .text
                                .trim();

                            if (email.isEmpty ||
                                !email
                                    .contains('@')) {
                              setState(() {
                                _isError = true;
                                _message =
                                'Please enter a valid email address.';
                              });
                              return;
                            }

                            setState(() {
                              _isLoading = true;
                              _message = null;
                            });

                            try {
                              await authService
                                  .sendPasswordResetEmail(
                                email,
                              );

                              if (!mounted) {
                                return;
                              }

                              setState(() {
                                _isError = false;
                                _message =
                                'Check your inbox for a password reset link.';
                              });
                            } catch (e) {
                              if (!mounted) {
                                return;
                              }

                              setState(() {
                                _isError = true;
                                _message =
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

                          style: ElevatedButton.styleFrom(
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
                            'Send reset link',
                            style: TextStyle(
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: TextButton(
                          onPressed: _isLoading
                              ? null
                              : () =>
                              Navigator.pop(
                                  context),
                          child: const Text(
                            'Back to login',
                          ),
                        ),
                      ),
                    ],
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
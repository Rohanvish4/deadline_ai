import 'package:deadline_ai/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:deadline_ai/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Flow:
///   Tab "Login"  → email + password → Login button
///   Tab "Sign up" → name + email + password → "Create account"
///       → AuthAwaitingVerification fires → OTP screen replaces form
///       → "Verify OTP" → AuthMessage("verified") → back to Login tab
///                                                   with email pre-filled
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Three distinct UI phases on this screen.
enum _Phase { login, signup, verify }

class _LoginPageState extends State<LoginPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;

  // Single source of truth for what is shown.
  _Phase _phase = _Phase.login;

  // Keeps the verified email so we can pre-fill Login after verification.
  String _verifiedEmail = '';

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DeadlineAI')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          // ── Signup succeeded → move to OTP entry phase ──────────────────
          if (state is AuthAwaitingVerification) {
            _verifiedEmail = state.email;
            setState(() {
              _phase = _Phase.verify;
              _otpController.clear();
            });
            _showSnack(context, state.message);
          }

          // ── OTP verified → move back to Login, pre-fill email ─────────
          if (state is AuthMessage) {
            if (state.message.toLowerCase().contains('verified') ||
                state.message.toLowerCase().contains('confirmed')) {
              setState(() {
                _phase = _Phase.login;
                _loginEmailController.text = _verifiedEmail.trim();
                _loginPasswordController.clear();
                // Clear signup fields now that we're done with them.
                _signupNameController.clear();
                _signupEmailController.clear();
                _signupPasswordController.clear();
                _otpController.clear();
              });
            }
            _showSnack(context, state.message);
          }

          // ── Any error ────────────────────────────────────────────────────
          if (state is AuthError) {
            _showSnack(context, state.message);
          }
        },
        builder: (context, state) {
            final isLoading = state is AuthLoading || state is AuthSubmitting;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DeadlineAI',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _phase == _Phase.verify
                              ? 'Enter the OTP sent to $_verifiedEmail'
                              : 'Cognito User Pool: ap-south-1_mjXWkUbJy',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 20),

                        // ── Tab bar — hidden during OTP phase ──────────────
                        if (_phase != _Phase.verify) ...[
                          SegmentedButton<_Phase>(
                            // Disabled while loading to prevent mid-flow tab switch.
                            onSelectionChanged: isLoading
                                ? null
                                : (selection) => setState(
                                      () => _phase = selection.first,
                                    ),
                            segments: const [
                              ButtonSegment(
                                value: _Phase.login,
                                label: Text('Login'),
                                icon: Icon(Icons.login),
                              ),
                              ButtonSegment(
                                value: _Phase.signup,
                                label: Text('Sign up'),
                                icon: Icon(Icons.person_add_alt_1),
                              ),
                            ],
                            selected: {_phase},
                          ),
                          const SizedBox(height: 20),
                        ],

                        // ── Phase router ────────────────────────────────────
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: switch (_phase) {
                            _Phase.login => _LoginForm(
                                key: const ValueKey('login'),
                                formKey: _loginFormKey,
                                emailController: _loginEmailController,
                                passwordController: _loginPasswordController,
                                obscurePassword: _obscureLoginPassword,
                                isLoading: isLoading,
                                onToggleObscure: () => setState(() =>
                                    _obscureLoginPassword =
                                        !_obscureLoginPassword),
                                onSubmit: () {
                                  if (_loginFormKey.currentState?.validate() !=
                                      true) return;
                                  context.read<AuthCubit>().loginWithEmail(
                                        email: _loginEmailController.text
                                            .trim(),
                                        password:
                                            _loginPasswordController.text,
                                      );
                                },
                              ),
                            _Phase.signup => _SignupForm(
                                key: const ValueKey('signup'),
                                formKey: _signupFormKey,
                                nameController: _signupNameController,
                                emailController: _signupEmailController,
                                passwordController: _signupPasswordController,
                                obscurePassword: _obscureSignupPassword,
                                isLoading: isLoading,
                                onToggleObscure: () => setState(() =>
                                    _obscureSignupPassword =
                                        !_obscureSignupPassword),
                                onSubmit: () {
                                  if (_signupFormKey.currentState?.validate() !=
                                      true) return;
                                  context.read<AuthCubit>().signUp(
                                        email: _signupEmailController.text
                                            .trim(),
                                        password:
                                            _signupPasswordController.text,
                                        fullName:
                                            _signupNameController.text.trim(),
                                      );
                                },
                              ),
                            _Phase.verify => _VerifyForm(
                                key: const ValueKey('verify'),
                                email: _verifiedEmail,
                                otpController: _otpController,
                                isLoading: isLoading,
                                onVerify: () {
                                  final code = _otpController.text.trim();
                                  if (code.isEmpty) {
                                    _showSnack(
                                        context, 'Please enter the OTP');
                                    return;
                                  }
                                  context.read<AuthCubit>().confirmSignUp(
                                        email: _verifiedEmail,
                                        code: code,
                                      );
                                },
                                onResend: () =>
                                    context.read<AuthCubit>()
                                        .resendConfirmationCode(
                                          email: _verifiedEmail,
                                        ),
                                onBack: () => setState(() {
                                  _phase = _Phase.signup;
                                  _otpController.clear();
                                }),
                              ),
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets — each phase is its own widget so AnimatedSwitcher works cleanly
// and each form has a clear, isolated responsibility.
// ─────────────────────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Email is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                onPressed: onToggleObscure,
                icon: Icon(obscurePassword
                    ? Icons.visibility
                    : Icons.visibility_off),
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Password is required' : null,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isLoading ? null : onSubmit,
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SignupForm extends StatelessWidget {
  const _SignupForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(labelText: 'Full name'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              labelText: 'Password (min 8 chars)',
              suffixIcon: IconButton(
                onPressed: onToggleObscure,
                icon: Icon(obscurePassword
                    ? Icons.visibility
                    : Icons.visibility_off),
              ),
            ),
            validator: (v) => (v == null || v.length < 8)
                ? 'Password must be at least 8 characters'
                : null,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'An OTP will be sent to your email after account creation.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isLoading ? null : onSubmit,
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create account'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _VerifyForm extends StatelessWidget {
  const _VerifyForm({
    super.key,
    required this.email,
    required this.otpController,
    required this.isLoading,
    required this.onVerify,
    required this.onResend,
    required this.onBack,
  });

  final String email;
  final TextEditingController otpController;
  final bool isLoading;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back arrow to return to signup tab without losing typed data.
        TextButton.icon(
          onPressed: isLoading ? null : onBack,
          icon: const Icon(Icons.arrow_back, size: 16),
          label: const Text('Back to sign up'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => onVerify(),
          decoration: const InputDecoration(
            labelText: 'Verification code (6 digits)',
            counterText: '',
          ),
        ),
        const SizedBox(height: 20),
        // Primary action.
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: isLoading ? null : onVerify,
            child: isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Verify OTP'),
          ),
        ),
        const SizedBox(height: 8),
        // Secondary action — full width, outlined.
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : onResend,
            child: const Text('Resend OTP'),
          ),
        ),
      ],
    );
  }
}
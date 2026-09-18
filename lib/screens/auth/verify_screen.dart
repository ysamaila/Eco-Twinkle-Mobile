import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  final String token;
  const VerifyScreen({super.key, required this.token});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  bool _done = false;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.token.isNotEmpty) {
      _verify();
    }
  }

  Future<void> _verify() async {
    final error = await ref
        .read(authProvider.notifier)
        .verifyEmail(widget.token);
    if (mounted) {
      setState(() {
        _done = true;
        _success = error == null;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (!_done) {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text('Verifying your email…',
              style: TextStyle(color: AppColors.textMuted)),
        ],
      );
    } else if (_success) {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_outlined,
                size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            'Account Verified!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your email has been verified successfully.\nYou can now sign in.',
            style: TextStyle(color: AppColors.textMuted, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(AppConstants.login),
              child: const Text('Sign In'),
            ),
          ),
        ],
      );
    } else {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded,
                size: 40, color: AppColors.error),
          ),
          const SizedBox(height: 24),
          Text(
            'Verification Failed',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            _error ?? 'The verification link may be invalid or expired.',
            style: TextStyle(color: AppColors.textMuted, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go(AppConstants.login),
              child: const Text('Back to Sign In'),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [body],
          ),
        ),
      ),
    );
  }
}

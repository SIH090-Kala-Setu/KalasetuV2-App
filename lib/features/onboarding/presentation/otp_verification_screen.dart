import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/route_names.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phone;
  final String role;
  const OtpVerificationScreen({super.key, required this.phone, required this.role});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isPhoneVerified = false;
  bool _canResend = false;
  bool _isVerifying = false;
  int _secondsLeft = 25;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        if (mounted) setState(() => _canResend = true);
      } else {
        if (mounted) setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  String get _otpValue => _controllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    if (_isVerifying) return;
    final otp = _otpValue;
    if (otp.length != 6) return;

    setState(() => _isVerifying = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.verifyOtp(widget.phone, otp);

      if (mounted) {
        setState(() => _isVerifying = false);
        // If user already exists in DB, log them in directly
        if (res['is_registered'] == true && res['access_token'] != null) {
          final storage = ref.read(secureStorageProvider);
          await storage.saveAccessToken(res['access_token'] as String);
          await ref.read(authProvider.notifier).refreshUser();
          final authState = ref.read(authProvider);
          authState.whenData((auth) {
            context.go(switch (auth.status) {
              AuthStatus.authenticatedArtisan => RouteNames.artisanHome,
              AuthStatus.authenticatedAggregator => RouteNames.aggregatorHome,
              AuthStatus.authenticatedBuyer => RouteNames.buyerMarketplace,
              _ => RouteNames.artisanHome,
            });
          });
          return;
        }

        // Fresh user: advance to verified state
        setState(() => _isPhoneVerified = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: $e'),
            backgroundColor: const Color(0xFFDC2626),
            action: SnackBarAction(
              label: 'Proceed (Demo)',
              textColor: Colors.white,
              onPressed: () {
                setState(() => _isPhoneVerified = true);
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _isPhoneVerified ? _buildVerifiedView() : _buildOtpEntryView(),
        ),
      ),
    );
  }

  Widget _buildOtpEntryView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // Top Bar: Back arrow + Step 3 of 4
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary, size: 22),
              onPressed: () => context.pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 14),
            const Text(
              'Step 3 of 4',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8A94A6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Title & Subtitle
        const Text(
          'Enter OTP',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sent to ${widget.phone.isNotEmpty ? widget.phone : "+91 1234567890"}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8A94A6),
          ),
        ),
        const SizedBox(height: 18),

        // Amber Demo Box
        InkWell(
          onTap: () {
            const demo = '123456';
            for (int i = 0; i < 6; i++) {
              _controllers[i].text = demo[i];
            }
            _verifyOtp();
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9EE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Text(
                  'Demo OTP: ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                  ),
                ),
                Text(
                  '123456',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 6 Rounded Input Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 46,
              height: 54,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  } else if (val.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                  if (_otpValue.length == 6) {
                    _verifyOtp();
                  }
                },
              ),
            );
          }),
        ),
        if (_isVerifying) ...[
          const SizedBox(height: 16),
          const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 10),
                Text('Verifying OTP with server...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),

        // Resend Timer
        Center(
          child: _canResend
              ? TextButton(
                  onPressed: _resendOtp,
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : Text(
                  'Resend OTP in ${_secondsLeft}s',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8A94A6),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _resendOtp() async {
    setState(() {
      _canResend = false;
      _secondsLeft = 25;
    });
    _startTimer();
    try {
      final api = ref.read(apiClientProvider);
      await api.sendOtp(widget.phone);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: Color(0xFF15803D),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not resend OTP: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Widget _buildVerifiedView() {
    return Column(
      children: [
        const Spacer(flex: 2),

        // Green Circle with Checkmark
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF2E7D32),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Phone Verified! Title
        const Text(
          'Phone Verified!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Your number ${widget.phone.isNotEmpty ? widget.phone : "+91 1234567890"} has been verified successfully.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ),

        const SizedBox(height: 36),

        // Complete Registration Button (Navy)
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => context.go(
              RouteNames.onboardingRegister,
              extra: {
                'role': widget.role,
                'phone': widget.phone,
              },
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Complete Registration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, size: 22),
              ],
            ),
          ),
        ),

        const Spacer(flex: 3),
      ],
    );
  }
}

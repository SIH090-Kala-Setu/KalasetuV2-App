import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';

class PhoneEntryScreen extends ConsumerStatefulWidget {
  final String role;
  const PhoneEntryScreen({super.key, required this.role});

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  bool get _isValidPhone => _phoneController.text.trim().replaceAll(' ', '').length >= 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
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
                'Phone Verification',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "We'll send you a one-time password",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8A94A6),
                ),
              ),
              const SizedBox(height: 24),

              // Phone Number Label
              const Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),

              // Phone Input Row: [IN +91] [98765 43210]
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'IN +91',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '98765 43210',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Security / Encryption Badge
              const Row(
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: Color(0xFF10B981)),
                  SizedBox(width: 6),
                  Text(
                    'Your number is encrypted and never shared',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Send OTP Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isValidPhone && !_isLoading ? _sendOtp : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isValidPhone ? AppColors.primary : const Color(0xFF94A3B8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF94A3B8),
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Send OTP',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtp() async {
    final rawDigits = _phoneController.text.trim().replaceAll(RegExp(r'[\s-]'), '');
    final formattedPhone = rawDigits.startsWith('+') ? rawDigits : '+91$rawDigits';

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.sendOtp(formattedPhone);

      if (mounted) {
        setState(() => _isLoading = false);
        context.go(
          RouteNames.onboardingOtp,
          extra: {
            'phone': formattedPhone,
            'role': widget.role,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not send OTP: $e'),
            backgroundColor: const Color(0xFFDC2626),
            action: SnackBarAction(
              label: 'Proceed (Demo)',
              textColor: Colors.white,
              onPressed: () {
                context.go(
                  RouteNames.onboardingOtp,
                  extra: {
                    'phone': formattedPhone,
                    'role': widget.role,
                  },
                );
              },
            ),
          ),
        );
      }
    }
  }
}

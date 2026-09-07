import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_mode_notifier.dart';

class PhoneEntryScreen extends ConsumerStatefulWidget {
  final String role;
  const PhoneEntryScreen({super.key, required this.role});

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.onboardingRole);
    }
  }

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Top Bar: Back arrow + Step 3 of 4 + Dark/Light Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                            size: 22,
                          ),
                          onPressed: _handleBack,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Step 3 of 4',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
                        color: isDark ? AppColors.accent : AppColors.primary,
                        size: 22,
                      ),
                      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                      onPressed: () => ref.read(themeModeProvider.notifier).toggleLightDark(),
                    ),
                  ],
                ),
              const SizedBox(height: 20),

              // Title & Subtitle
              Text(
                'Phone Verification',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "We'll send you a one-time password",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6),
                ),
              ),
              const SizedBox(height: 24),

              // Phone Number Label
              Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
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
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'IN +91',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.accent : AppColors.primary,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurface : Colors.white,
                          hintText: '98765 43210',
                          hintStyle: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.6) : const Color(0xFF94A3B8),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.accent : AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Security / Encryption Badge
              Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Text(
                    'Your number is encrypted and never shared',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
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
                      backgroundColor: _isValidPhone
                          ? (isDark ? AppColors.accent : AppColors.primary)
                          : (isDark ? AppColors.darkSurfaceVariant : const Color(0xFF94A3B8)),
                      foregroundColor: _isValidPhone && isDark ? Colors.black : Colors.white,
                      disabledBackgroundColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFF94A3B8),
                      disabledForegroundColor: isDark ? AppColors.darkTextSecondary : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: isDark && _isValidPhone ? Colors.black : Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Send OTP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark && _isValidPhone ? Colors.black : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 22,
                                color: isDark && _isValidPhone ? Colors.black : Colors.white,
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

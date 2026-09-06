import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_mode_notifier.dart';
import '../../../shared/providers/auth_provider.dart';

class RegistrationWizardScreen extends ConsumerStatefulWidget {
  final String role;
  final String? phone;
  const RegistrationWizardScreen({super.key, required this.role, this.phone});

  @override
  ConsumerState<RegistrationWizardScreen> createState() => _RegistrationWizardScreenState();
}

class _RegistrationWizardScreenState extends ConsumerState<RegistrationWizardScreen> {
  int _part = 0; // 0: Personal, 1: Craft, 2: Identity & Bank KYC, 3: Success
  bool _isSubmitting = false;

  final _fullNameCtrl = TextEditingController(text: 'Ramesh Sharma');
  final _usernameCtrl = TextEditingController(text: 'ramesh_weaver');
  final _craftTypeCtrl = TextEditingController(text: 'Banarasi Silk Weaving');
  final _regionCtrl = TextEditingController(text: 'Uttar Pradesh');
  final _districtCtrl = TextEditingController(text: 'Varanasi');
  final _villageCtrl = TextEditingController(text: 'Madanpura');
  final _aadhaarCtrl = TextEditingController(text: '•••• •••• 1234');
  final _bankAccountCtrl = TextEditingController(text: '•••• •••• 5678');
  final _ifscCtrl = TextEditingController(text: 'SBIN0001234');
  final _upiCtrl = TextEditingController(text: 'ramesh@upi');

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _craftTypeCtrl.dispose();
    _regionCtrl.dispose();
    _districtCtrl.dispose();
    _villageCtrl.dispose();
    _aadhaarCtrl.dispose();
    _bankAccountCtrl.dispose();
    _ifscCtrl.dispose();
    _upiCtrl.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_part > 0) {
      setState(() => _part--);
    } else if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.onboardingRole);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_part == 3) {
      return _buildSuccessScreen();
    }

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
                // Top Bar: Back arrow + Step 4 of 4 · Part X/4 + Dark/Light Toggle
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
                          'Step 4 of 4 · Part ${_part + 1}/4',
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
              const SizedBox(height: 16),

              // 4 Segment Progress Bars
              Row(
                children: List.generate(4, (index) {
                  final isFilled = index <= _part;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 3 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: isFilled
                            ? (isDark ? AppColors.accent : AppColors.primary)
                            : (isDark ? AppColors.darkSurfaceVariant : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Dynamic Step Form
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    if (_part == 0) ..._buildPersonalStep(isDark),
                    if (_part == 1) ..._buildCraftStep(isDark),
                    if (_part == 2) ..._buildKycStep(isDark),
                  ],
                ),
              ),

              // Submit / Continue Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleNextPart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.accent : AppColors.primary,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                      disabledBackgroundColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFF94A3B8),
                      disabledForegroundColor: isDark ? AppColors.darkTextSecondary : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: isDark ? Colors.black : Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _part == 2 ? 'Submit for Verification' : 'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 22,
                                color: isDark ? Colors.black : Colors.white,
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

  List<Widget> _buildPersonalStep(bool isDark) {
    return [
      Text(
        'Personal Details',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Tell us a bit about yourself',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6),
        ),
      ),
      const SizedBox(height: 24),
      _buildFormField('Full Name', _fullNameCtrl, 'e.g. Ramesh Sharma', isDark),
      const SizedBox(height: 16),
      _buildFormField('Username', _usernameCtrl, 'e.g. ramesh_weaver', isDark),
    ];
  }

  List<Widget> _buildCraftStep(bool isDark) {
    return [
      Text(
        'Craft & Location',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Where do you practice your craft?',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6),
        ),
      ),
      const SizedBox(height: 24),
      _buildFormField('Craft Specialization', _craftTypeCtrl, 'e.g. Banarasi Silk Weaving', isDark),
      const SizedBox(height: 16),
      _buildFormField('State / Region', _regionCtrl, 'e.g. Uttar Pradesh', isDark),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(child: _buildFormField('District', _districtCtrl, 'Varanasi', isDark)),
          const SizedBox(width: 12),
          Expanded(child: _buildFormField('Village / Town', _villageCtrl, 'Madanpura', isDark)),
        ],
      ),
    ];
  }

  List<Widget> _buildKycStep(bool isDark) {
    return [
      Text(
        'Identity & Bank KYC',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
          letterSpacing: -0.5,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Secure banking details for payouts',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF8A94A6),
        ),
      ),
      const SizedBox(height: 24),
      _buildFormField('Aadhaar Number', _aadhaarCtrl, '•••• •••• 1234', isDark),
      const SizedBox(height: 6),
      Row(
        children: [
          const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF10B981)),
          const SizedBox(width: 4),
          Text(
            'Masked for your privacy',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      _buildFormField('Bank Account Number', _bankAccountCtrl, '•••• •••• 5678', isDark),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(child: _buildFormField('IFSC Code', _ifscCtrl, 'SBIN0001234', isDark)),
          const SizedBox(width: 12),
          Expanded(child: _buildFormField('UPI ID', _upiCtrl, 'ramesh@upi', isDark)),
        ],
      ),
    ];
  }

  Widget _buildFormField(String label, TextEditingController controller, String hint, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 50,
          child: TextField(
            controller: controller,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.6) : const Color(0xFF94A3B8),
                fontSize: 14,
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : Colors.white,
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
      ],
    );
  }

  Future<void> _handleNextPart() async {
    if (_part < 2) {
      setState(() => _part++);
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final auth = ref.read(authProvider.notifier);
      await auth.register(
        username: _usernameCtrl.text.trim(),
        password: 'password123',
        role: widget.role.isNotEmpty ? widget.role : 'Artisan',
        phone: widget.phone,
        fullName: _fullNameCtrl.text.trim(),
        craftType: _craftTypeCtrl.text.trim(),
        region: _regionCtrl.text.trim(),
        district: _districtCtrl.text.trim(),
        aadhaarNumber: _aadhaarCtrl.text.trim(),
      );
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _part = 3;
      });
    }
  }

  Widget _buildSuccessScreen() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Green check circle
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check_rounded, color: Colors.white, size: 48),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Registration Submitted!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              Text(
                'Your application is under review by MoSJE. You can now access your dashboard and explore features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.go(
                    widget.role == 'Artisan'
                        ? RouteNames.artisanHome
                        : widget.role == 'Aggregator'
                            ? RouteNames.aggregatorHome
                            : RouteNames.buyerMarketplace,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
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
                        'Continue to App',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

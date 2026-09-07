import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum AuthLoadingPhase {
  loading,
  success,
  error,
}

/// A smooth animated loading banner and overlay used during authentication
/// (login, registration, OTP validation) to prevent abrupt screen jumps.
class AuthLoadingOverlay extends StatefulWidget {
  final AuthLoadingPhase phase;
  final String title;
  final String message;
  final String? errorMessage;
  final VoidCallback? onDismissError;

  const AuthLoadingOverlay({
    super.key,
    required this.phase,
    required this.title,
    required this.message,
    this.errorMessage,
    this.onDismissError,
  });

  @override
  State<AuthLoadingOverlay> createState() => _AuthLoadingOverlayState();
}

class _AuthLoadingOverlayState extends State<AuthLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned.fill(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          color: Colors.black.withValues(alpha: 0.45),
          padding: const EdgeInsets.symmetric(horizontal: 28),
          alignment: Alignment.center,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Icon
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildPhaseIcon(isDark),
                  ),
                  const SizedBox(height: 18),

                  // Title
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      widget.title,
                      key: ValueKey<String>('title_${widget.phase}_${widget.title}'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle / message
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      widget.phase == AuthLoadingPhase.error
                          ? (widget.errorMessage ?? 'An error occurred. Please try again.')
                          : widget.message,
                      key: ValueKey<String>('msg_${widget.phase}_${widget.message}'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: widget.phase == AuthLoadingPhase.error
                            ? const Color(0xFFDC2626)
                            : (isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B)),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress Bar or Error Action
                  if (widget.phase == AuthLoadingPhase.loading) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: const LinearProgressIndicator(
                        minHeight: 4,
                        backgroundColor: Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    ),
                  ] else if (widget.phase == AuthLoadingPhase.success) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: const LinearProgressIndicator(
                        minHeight: 4,
                        value: 1.0,
                        backgroundColor: Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      ),
                    ),
                  ] else if (widget.phase == AuthLoadingPhase.error && widget.onDismissError != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: OutlinedButton(
                        onPressed: widget.onDismissError,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhaseIcon(bool isDark) {
    switch (widget.phase) {
      case AuthLoadingPhase.loading:
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.12),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.accent,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(
              width: 58,
              height: 58,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
          ],
        );
      case AuthLoadingPhase.success:
        return Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF10B981),
          ),
          child: const Center(
            child: Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        );
      case AuthLoadingPhase.error:
        return Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFDC2626).withValues(alpha: 0.12),
          ),
          child: const Center(
            child: Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFDC2626),
              size: 32,
            ),
          ),
        );
    }
  }
}

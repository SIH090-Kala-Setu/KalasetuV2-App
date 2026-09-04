import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/debouncer.dart';

/// Debounced search bar with clear icon and optional filter trigger
class AppSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onSearch;
  final VoidCallback? onFilterTap;
  final bool showFilter;
  final Duration debounceDelay;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    required this.onSearch,
    this.hint = 'Search...',
    this.onFilterTap,
    this.showFilter = false,
    this.debounceDelay = const Duration(milliseconds: 350),
    this.controller,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  late final Debouncer _debouncer;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _debouncer = Debouncer(delay: widget.debounceDelay);
    _controller.addListener(_onTextChange);
  }

  void _onTextChange() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
    _debouncer.call(() => widget.onSearch(_controller.text.trim()));
  }

  @override
  void dispose() {
    _debouncer.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            size: 20,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _controller,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (_hasText)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () {
                _controller.clear();
                widget.onSearch('');
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          if (widget.showFilter) ...[
            const SizedBox(width: 4),
            Container(
              width: 1,
              height: 24,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            IconButton(
              icon: const Icon(Icons.tune_rounded, size: 20),
              onPressed: widget.onFilterTap,
              color: AppColors.primary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            ),
          ],
          if (!widget.showFilter) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

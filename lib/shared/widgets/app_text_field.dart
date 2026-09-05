import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

/// Reusable text field — floating label, clear button, validation, theme-adaptive
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool showClearButton;
  final FocusNode? focusNode;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.validator,
    this.showClearButton = true,
    this.focusNode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _showPassword = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = (widget.controller?.text ?? '').isNotEmpty;
    widget.controller?.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = (widget.controller?.text ?? '').isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPasswordField = widget.obscureText;

    Widget? suffixWidget;
    if (isPasswordField) {
      suffixWidget = IconButton(
        icon: Icon(
          _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
        ),
        onPressed: () => setState(() => _showPassword = !_showPassword),
      );
    } else if (widget.suffix != null) {
      suffixWidget = widget.suffix;
    } else if (widget.showClearButton && _hasText && !widget.readOnly) {
      suffixWidget = IconButton(
        icon: const Icon(Icons.close, size: 18),
        onPressed: () {
          widget.controller?.clear();
          widget.onChanged?.call('');
        },
      );
    }

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: isPasswordField && !_showPassword,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLines: isPasswordField ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 20)
            : null,
        suffixIcon: suffixWidget,
        counterText: '', // Hide default counter
      ),
    );
  }
}

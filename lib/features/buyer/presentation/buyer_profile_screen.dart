import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_mode_notifier.dart';
import '../../../shared/models/models.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/server_config_dialog.dart';
import '../../../shared/widgets/app_button.dart';

class BuyerProfileScreen extends ConsumerWidget {
  const BuyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).valueOrNull;
    final user = auth?.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.buyerColor, Color(0xFF880E4F)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppAvatar(
                        photoUrl: user?.avatarUrl,
                        name: user?.fullName,
                        radius: 40,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        textColor: Colors.white,
                        fontSize: 30,
                      ),
                      const SizedBox(height: 10),
                      Text(user?.fullName ?? 'Buyer', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
                      Text('B2B Buyer', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Overview Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: user?.email?.isNotEmpty == true ? user!.email! : 'Not set',
                          ),
                          const Divider(height: 16),
                          _buildInfoRow(
                            icon: Icons.phone_outlined,
                            label: 'Phone',
                            value: user?.phone?.isNotEmpty == true ? user!.phone! : 'Not set',
                          ),
                          const Divider(height: 16),
                          _buildInfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Location',
                            value: [user?.district, user?.region]
                                .where((e) => e != null && e.isNotEmpty)
                                .join(', ')
                                .isNotEmpty
                                ? [user?.district, user?.region]
                                    .where((e) => e != null && e.isNotEmpty)
                                    .join(', ')
                                : 'Not set',
                          ),
                          const Divider(height: 16),
                          _buildInfoRow(
                            icon: Icons.language_rounded,
                            label: 'Preferred Language',
                            value: user?.preferredLang.toUpperCase() ?? 'EN',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text('Settings', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const Icon(Icons.person_outline_rounded, color: AppColors.buyerColor),
                      title: const Text('Edit Profile'),
                      subtitle: const Text('Name, contact, location & language'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      contentPadding: EdgeInsets.zero,
                      onTap: () => _showEditBuyerProfileModal(context, ref, user),
                    ),
                    ListTile(
                      leading: const Icon(Icons.dark_mode_outlined, color: AppColors.buyerColor),
                      title: const Text('Dark Mode'),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (_) => ref.read(themeModeProvider.notifier).toggleLightDark(),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    ListTile(
                      leading: const Icon(Icons.dns_outlined, color: AppColors.buyerColor),
                      title: const Text('Server Configuration'),
                      subtitle: const Text('Switch between Localhost / Android / Production'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      contentPadding: EdgeInsets.zero,
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => const ServerConfigDialog(),
                      ),
                    ),
                    const ListTile(
                      leading: Icon(Icons.notifications_outlined, color: AppColors.buyerColor),
                      title: Text('Notifications'),
                      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),
                    AppButton.danger(
                      label: 'Logout',
                      leadingIcon: Icons.logout_rounded,
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) context.go(RouteNames.splash);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.buyerColor),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  void _showEditBuyerProfileModal(BuildContext context, WidgetRef ref, UserModel? user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _EditBuyerProfileSheet(user: user),
    );
  }
}

class _EditBuyerProfileSheet extends ConsumerStatefulWidget {
  final UserModel? user;
  const _EditBuyerProfileSheet({this.user});

  @override
  ConsumerState<_EditBuyerProfileSheet> createState() => _EditBuyerProfileSheetState();
}

class _EditBuyerProfileSheetState extends ConsumerState<_EditBuyerProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _stateController;
  late final TextEditingController _districtController;
  late String _selectedLanguage;
  bool _isLoading = false;

  static const _languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'Hindi (हिन्दी)'},
    {'code': 'bn', 'label': 'Bengali (বাংলা)'},
    {'code': 'te', 'label': 'Telugu (తెలుగు)'},
    {'code': 'ta', 'label': 'Tamil (தமிழ்)'},
    {'code': 'mr', 'label': 'Marathi (मराठी)'},
    {'code': 'gu', 'label': 'Gujarati (ગુજરાતી)'},
  ];

  late final TextEditingController _photoUrlController;
  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.fullName ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _phoneController = TextEditingController(text: widget.user?.phone ?? '');
    _stateController = TextEditingController(text: widget.user?.region ?? '');
    _districtController = TextEditingController(text: widget.user?.district ?? '');
    _photoUrlController = TextEditingController(text: widget.user?.avatarUrl ?? '');
    _selectedLanguage = widget.user?.preferredLang ?? 'en';
    if (!_languages.any((l) => l['code'] == _selectedLanguage)) {
      _selectedLanguage = 'en';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64String = base64Encode(bytes);
        final mimeType = picked.mimeType ?? 'image/jpeg';
        final dataUri = 'data:$mimeType;base64,$base64String';
        setState(() {
          _photoUrlController.text = dataUri;
          _pickedImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access image: $e')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Buyer Profile Photo',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.buyerColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: AppColors.buyerColor),
                  ),
                  title: const Text('Choose from Gallery / Files', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.buyerColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: AppColors.buyerColor),
                  ),
                  title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_photoUrlController.text.trim().isNotEmpty || _pickedImageBytes != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline, color: AppColors.error),
                    ),
                    title: const Text('Remove Photo', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _photoUrlController.text = '';
                        _pickedImageBytes = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      final updatedUser = await api.updateBuyerProfile({
        'full_name': name,
        'email': _emailController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'state': _stateController.text.trim(),
        'district': _districtController.text.trim(),
        'preferred_language': _selectedLanguage,
        'photo_url': _photoUrlController.text.trim(),
        'avatar_url': _photoUrlController.text.trim(),
      });

      ref.read(authProvider.notifier).updateUser(updatedUser);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Color(0xFF047857),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.edit_rounded, color: AppColors.buyerColor, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Edit Buyer Profile',
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.buyerColor,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : const Color(0xFF64748B),
                    size: 24,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Avatar Selector Header
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Stack(
                      children: [
                        AppAvatar(
                          imageBytes: _pickedImageBytes,
                          photoUrl: _photoUrlController.text.trim(),
                          name: _nameController.text.isNotEmpty ? _nameController.text : (widget.user?.fullName ?? ''),
                          radius: 44,
                          backgroundColor: AppColors.buyerColor.withValues(alpha: 0.15),
                          textColor: AppColors.buyerColor,
                          fontSize: 32,
                          border: Border.all(color: AppColors.buyerColor, width: 2.5),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.buyerColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined, size: 16),
                        label: const Text('Upload Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, size: 16),
                        label: const Text('Take Photo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                  if (_photoUrlController.text.trim().isNotEmpty || _pickedImageBytes != null) ...[
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _photoUrlController.text = '';
                          _pickedImageBytes = null;
                        });
                      },
                      icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                      label: const Text('Remove Photo', style: TextStyle(color: AppColors.error, fontSize: 12)),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name *',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _stateController,
                    label: 'State',
                    icon: Icons.map_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _districtController,
                    label: 'District',
                    icon: Icons.location_city_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _selectedLanguage,
              decoration: InputDecoration(
                labelText: 'Preferred Language',
                prefixIcon: const Icon(Icons.language_rounded, color: AppColors.buyerColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: _languages.map((l) {
                return DropdownMenuItem<String>(
                  value: l['code'],
                  child: Text(l['label']!),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedLanguage = val);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buyerColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.buyerColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

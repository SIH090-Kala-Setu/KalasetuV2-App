import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/network/api_client.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/theme_mode_notifier.dart';
import '../../../shared/models/models.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/server_config_dialog.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../../../shared/widgets/status_badge.dart';

const _profileLanguages = [
  ('hi', 'हिन्दी', 'Hindi', 'नमस्ते'),
  ('en', 'English', 'English', 'Hello'),
  ('bn', 'বাংলা', 'Bengali', 'নমস্কার'),
  ('te', 'తెలుగు', 'Telugu', 'నమస్కారం'),
  ('ta', 'தமிழ்', 'Tamil', 'வணக்கம்'),
  ('mr', 'मराठी', 'Marathi', 'नमस्कार'),
  ('gu', 'ગુજરાતી', 'Gujarati', 'નમસ્તે'),
  ('kn', 'ಕನ್ನಡ', 'Kannada', 'ನಮಸ್ಕಾರ'),
];

const Map<String, Map<String, String>> _profileTranslations = {
  'en': {
    'performance': 'My Performance',
    'totalProducts': 'Total Products',
    'totalOrders': 'Total Orders',
    'revenue': 'Revenue',
    'settings': 'Settings',
    'editProfile': 'Edit Profile',
    'editProfileSub': 'Name, craft, location, experience & story',
    'darkMode': 'Dark Mode',
    'language': 'Language',
    'bankUpi': 'Bank & UPI Details',
    'bankUpiSub': 'Edit payout account & UPI ID',
    'portfolioUrl': 'My Portfolio URL',
    'portfolioUrlSub': 'Share your artisan profile',
    'salesReport': 'Download Sales Report',
    'salesReportSub': 'Export product CSV to device',
    'serverConfig': 'Server Configuration',
    'logout': 'Logout',
    'certified': 'MoSJE Certified',
    'kycPending': 'KYC Pending',
  },
  'hi': {
    'performance': 'मेरा प्रदर्शन',
    'totalProducts': 'कुल उत्पाद',
    'totalOrders': 'कुल ऑर्डर',
    'revenue': 'अनुमानित आय',
    'settings': 'सेटिंग्स',
    'editProfile': 'प्रोफ़ाइल संपादित करें',
    'editProfileSub': 'नाम, शिल्प, स्थान, अनुभव और कहानी',
    'darkMode': 'डार्क मोड',
    'language': 'भाषा',
    'bankUpi': 'बैंक और यूपीआई विवरण',
    'bankUpiSub': 'भुगतान खाता और यूपीआई संपादित करें',
    'portfolioUrl': 'मेरा पोर्टफोलियो लिंक',
    'portfolioUrlSub': 'अपनी कारीगर प्रोफ़ाइल साझा करें',
    'salesReport': 'बिक्री रिपोर्ट डाउनलोड करें',
    'salesReportSub': 'डिवाइस पर उत्पाद CSV निर्यात करें',
    'serverConfig': 'सर्वर कॉन्फ़िगरेशन',
    'logout': 'लॉगआउट',
    'certified': 'MoSJE प्रमाणित',
    'kycPending': 'केवाईसी लंबित',
  },
  'bn': {
    'performance': 'আমার কর্মক্ষমতা',
    'totalProducts': 'মোট পণ্য',
    'totalOrders': 'মোট অর্ডার',
    'revenue': 'আনুমানিক আয়',
    'settings': 'সেটিংস',
    'editProfile': 'প্রোফাইল সম্পাদনা করুন',
    'editProfileSub': 'নাম, কারুশিল্প, অবস্থান, অভিজ্ঞতা ও গল্প',
    'darkMode': 'ডার্ক মোড',
    'language': 'ভাষা',
    'bankUpi': 'ব্যাংক ও ইউপিআই বিবরণ',
    'bankUpiSub': 'পেআউট অ্যাকাউন্ট ও ইউপিআই সম্পাদনা করুন',
    'portfolioUrl': 'আমার পোর্টফোলিও লিঙ্ক',
    'portfolioUrlSub': 'আপনার কারিগর প্রোফাইল শেয়ার করুন',
    'salesReport': 'বিক্রয় প্রতিবেদন ডাউনলোড করুন',
    'salesReportSub': 'ডিভাইসে পণ্য CSV ডাউনলোড করুন',
    'serverConfig': 'সার্ভার কনফিগারেশন',
    'logout': 'লগআউট',
    'certified': 'MoSJE প্রত্যয়িত',
    'kycPending': 'কেওয়াইসি মুলতুবি',
  },
  'te': {
    'performance': 'నా పనితీరు',
    'totalProducts': 'మొత్తం ఉత్పత్తులు',
    'totalOrders': 'మొత్తం ఆర్డర్లు',
    'revenue': 'అంచనా ఆదాయం',
    'settings': 'సెట్టింగ్‌లు',
    'editProfile': 'ప్రొఫైల్ సవరించండి',
    'editProfileSub': 'పేరు, కళ, ప్రాంతం, అనుభవం & కథ',
    'darkMode': 'డార్క్ మోడ్',
    'language': 'భాష',
    'bankUpi': 'బ్యాంక్ మరియు UPI వివరాలు',
    'bankUpiSub': 'చెల్లింపు ఖాతా & UPI ID సవరించండి',
    'portfolioUrl': 'నా పోర్ట్‌ఫోలియో URL',
    'portfolioUrlSub': 'మీ కళాకారుడి ప్రొఫైల్‌ను పంచుకోండి',
    'salesReport': 'విక్రయాల నివేదిక డౌన్‌లోడ్',
    'salesReportSub': 'డివైజ్‌కు ప్రొడక్ట్ CSV ఎగుమతి చేయండి',
    'serverConfig': 'సర్వర్ కాన్ఫిగరేషన్',
    'logout': 'లాగ్ అవుట్',
    'certified': 'MoSJE ధృవీకరించబడింది',
    'kycPending': 'KYC పెండింగ్‌లో ఉంది',
  },
  'ta': {
    'performance': 'எனது செயல்திறன்',
    'totalProducts': 'மொத்த தயாரிப்புகள்',
    'totalOrders': 'மொத்த ஆர்டர்கள்',
    'revenue': 'மதிப்பிடப்பட்ட வருவாய்',
    'settings': 'அமைப்புகள்',
    'editProfile': 'சுயவிவரத்தைத் திருத்து',
    'editProfileSub': 'பெயர், கைவினை, இருப்பிடம், அனுபவம் & கதை',
    'darkMode': 'இருண்ட பயன்முறை',
    'language': 'மொழி',
    'bankUpi': 'வங்கி & UPI விவரங்கள்',
    'bankUpiSub': 'பணம் பெறும் கணக்கு & UPI ஐ மாற்றவும்',
    'portfolioUrl': 'எனது போர்ட்ஃபோலியோ இணைப்பு',
    'portfolioUrlSub': 'உங்கள் கைவினைஞர் சுயவிவரத்தைப் பகிரவும்',
    'salesReport': 'விற்பனை அறிக்கையைப் பதிவிறக்குக',
    'salesReportSub': 'சாதனத்திற்கு தயாரிப்பு CSV ஐ ஏற்றுமதி செய்',
    'serverConfig': 'சர்வர் கட்டமைப்பு',
    'logout': 'வெளியேறு',
    'certified': 'MoSJE சான்றளிக்கப்பட்டது',
    'kycPending': 'KYC நிலுவையில் உள்ளது',
  },
  'mr': {
    'performance': 'माझी कामगिरी',
    'totalProducts': 'एकूण उत्पादने',
    'totalOrders': 'एकूण मागण्या',
    'revenue': 'अंदाजे उत्पन्न',
    'settings': 'सेटिंग्ज',
    'editProfile': 'प्रोफाइल संपादित करा',
    'editProfileSub': 'नाव, हस्तकला, ठिकाण, अनुभव आणि कथा',
    'darkMode': 'डार्क मोड',
    'language': 'भाषा',
    'bankUpi': 'बँक आणि युपीआय तपशील',
    'bankUpiSub': 'पेआउट खाते आणि युपीआय आयडी बदला',
    'portfolioUrl': 'माझा पोर्टफोलिओ दुवा',
    'portfolioUrlSub': 'आपले कारागीर प्रोफाइल शेअर करा',
    'salesReport': 'विक्री अहवाल डाउनलोड करा',
    'salesReportSub': 'डिव्हाइसवर उत्पादन CSV सेव्ह करा',
    'serverConfig': 'सर्व्हर कॉन्फिगरेशन',
    'logout': 'लॉगआउट',
    'certified': 'MoSJE प्रमाणित',
    'kycPending': 'केवायसी प्रलंबित',
  },
  'gu': {
    'performance': 'મારું પ્રદર્શન',
    'totalProducts': 'કુલ ઉત્પાદનો',
    'totalOrders': 'કુલ ઓર્ડર',
    'revenue': 'અંદાજિત આવક',
    'settings': 'સેટિંગ્સ',
    'editProfile': 'પ્રોફાઇલ સંપાદિત કરો',
    'editProfileSub': 'નામ, હસ્તકલા, સ્થળ, અનુભવ અને વાર્તા',
    'darkMode': 'ડાર્ક મોડ',
    'language': 'ભાષા',
    'bankUpi': 'બેંક અને UPI વિગતો',
    'bankUpiSub': 'પેઆઉટ ખાતું અને UPI ID સંપાદિત કરો',
    'portfolioUrl': 'મારો પોર્ટફોલિયો લિંક',
    'portfolioUrlSub': 'તમારી કારીગર પ્રોફાઇલ શેર કરો',
    'salesReport': 'વેચાણ અહેવાલ ડાઉનલોડ કરો',
    'salesReportSub': 'ઉપકરણ પર ઉત્પાદન CSV નિકાસ કરો',
    'serverConfig': 'સર્વર રૂપરેખાંકન',
    'logout': 'લૉગ આઉટ',
    'certified': 'MoSJE પ્રમાણિત',
    'kycPending': 'KYC બાકી છે',
  },
  'kn': {
    'performance': 'ನನ್ನ ಕಾರ್ಯಕ್ಷಮತೆ',
    'totalProducts': 'ಒಟ್ಟು ಉತ್ಪನ್ನಗಳು',
    'totalOrders': 'ಒಟ್ಟು ಆದೇಶಗಳು',
    'revenue': 'ಅಂದಾಜು ಆದಾಯ',
    'settings': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
    'editProfile': 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ',
    'editProfileSub': 'ಹೆಸರು, ಕರಕುಶಲ, ಸ್ಥಳ, ಅನುಭವ ಮತ್ತು ಕಥೆ',
    'darkMode': 'ಡಾರ್ಕ್ ಮೋಡ್',
    'language': 'ಭಾಷೆ',
    'bankUpi': 'ಬ್ಯಾಂಕ್ ಮತ್ತು ಯುಪಿಐ ವಿವರಗಳು',
    'bankUpiSub': 'ಪಾವತಿ ಖಾತೆ & UPI ID ಸಂಪಾದಿಸಿ',
    'portfolioUrl': 'ನನ್ನ ಪೋರ್ಟ್‌ಫೋಲಿಯೊ URL',
    'portfolioUrlSub': 'ನಿಮ್ಮ ಕುಶಲಕರ್ಮಿ ಪ್ರೊಫೈಲ್ ಹಂಚಿಕೊಳ್ಳಿ',
    'salesReport': 'ಮಾರಾಟ ವರದಿಯನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ',
    'salesReportSub': 'ಸಾಧನಕ್ಕೆ ಉತ್ಪನ್ನ CSV ರಫ್ತು ಮಾಡಿ',
    'serverConfig': 'ಸರ್ವರ್ ಸಂರಚನೆ',
    'logout': 'ಲಾಗ್‌ಔಟ್',
    'certified': 'MoSJE ಪ್ರಮಾಣೀಕರಿಸಲಾಗಿದೆ',
    'kycPending': 'KYC ಬಾಕಿ ಇದೆ',
  },
};

String _profileTr(String lang, String key) {
  return _profileTranslations[lang]?[key] ?? _profileTranslations['en']?[key] ?? key;
}

final _artisanAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.getArtisanAnalytics();
});

class ArtisanProfileScreen extends ConsumerWidget {
  const ArtisanProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider).valueOrNull;
    final user = auth?.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final currentLocale = ref.watch(localeProvider);
    final currentLang = _profileLanguages.firstWhere(
      (l) => l.$1 == currentLocale.languageCode,
      orElse: () => _profileLanguages[0],
    );

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar
                        AppAvatar(
                          photoUrl: user?.avatarUrl,
                          name: user?.fullName,
                          radius: 44,
                          backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                          textColor: Colors.white,
                          fontSize: 36,
                        ),
                        const SizedBox(height: 12),
                        Text(user?.fullName ?? 'Artisan',
                            style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
                        Text(user?.craftType ?? 'Master Artisan',
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (user?.isVerified == true) ...[
                              const Icon(Icons.verified_rounded, color: AppColors.accent, size: 16),
                              const SizedBox(width: 4),
                              Text(_profileTr(currentLocale.languageCode, 'certified'), style: AppTextStyles.labelSmall.copyWith(color: AppColors.accent)),
                            ] else
                              StatusBadge(status: BadgeStatus.pending, customLabel: _profileTr(currentLocale.languageCode, 'kycPending')),
                            const SizedBox(width: 12),
                            const Icon(Icons.location_on_outlined, color: Colors.white54, size: 14),
                            const SizedBox(width: 4),
                            Text(user?.district ?? 'India',
                                style: AppTextStyles.labelSmall.copyWith(color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                tooltip: _profileTr(currentLocale.languageCode, 'editProfile'),
                onPressed: () => _showEditArtisanProfileModal(context, ref, user),
              ),
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                tooltip: _profileTr(currentLocale.languageCode, 'portfolioUrl'),
                onPressed: () => context.push(
                  RouteNames.artisanPortfolio(user?.id ?? ''),
                ),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Analytics summary
                    _AnalyticsSection(),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Settings
                    Text(_profileTr(currentLocale.languageCode, 'settings'), style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 12),
                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: _profileTr(currentLocale.languageCode, 'editProfile'),
                      subtitle: _profileTr(currentLocale.languageCode, 'editProfileSub'),
                      onTap: () => _showEditArtisanProfileModal(context, ref, user),
                    ),
                    _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: _profileTr(currentLocale.languageCode, 'darkMode'),
                      trailing: Switch(
                        value: isDark,
                        onChanged: (_) => ref.read(themeModeProvider.notifier).toggleLightDark(),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.language_rounded,
                      title: _profileTr(currentLocale.languageCode, 'language'),
                      subtitle: '${currentLang.$2} (${currentLang.$3})',
                      onTap: () => _showLanguagePicker(context, ref),
                    ),
                    _SettingsTile(
                      icon: Icons.account_balance_outlined,
                      title: _profileTr(currentLocale.languageCode, 'bankUpi'),
                      subtitle: _profileTr(currentLocale.languageCode, 'bankUpiSub'),
                      onTap: () => _showBankDetailsModal(context, ref),
                    ),
                    _SettingsTile(
                      icon: Icons.link_rounded,
                      title: _profileTr(currentLocale.languageCode, 'portfolioUrl'),
                      subtitle: _profileTr(currentLocale.languageCode, 'portfolioUrlSub'),
                      onTap: () => context.push(RouteNames.artisanPortfolio(user?.id ?? '')),
                    ),
                    _SettingsTile(
                      icon: Icons.download_rounded,
                      title: _profileTr(currentLocale.languageCode, 'salesReport'),
                      subtitle: _profileTr(currentLocale.languageCode, 'salesReportSub'),
                      onTap: () => _downloadSalesReport(context, ref),
                    ),
                    _SettingsTile(
                      icon: Icons.settings_rounded,
                      title: _profileTr(currentLocale.languageCode, 'serverConfig'),
                      onTap: () => ServerConfigDialog.show(context),
                    ),
                    const SizedBox(height: 24),
                    AppButton.danger(
                      label: _profileTr(currentLocale.languageCode, 'logout'),
                      leadingIcon: Icons.logout_rounded,
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) context.go(RouteNames.splash);
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'कलाSetu v2.0 | SIH 2025',
                        style: AppTextStyles.caption.copyWith(color: textSecondary),
                      ),
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
}

void _showLanguagePicker(BuildContext context, WidgetRef ref) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final currentCode = ref.read(localeProvider).languageCode;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.language_rounded, color: isDark ? AppColors.accent : AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Language / भाषा चुनें',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Choose your preferred language for the app',
                          style: AppTextStyles.caption.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
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
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _profileLanguages.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                  itemBuilder: (context, i) {
                    final item = _profileLanguages[i];
                    final isSelected = item.$1 == currentCode;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: isSelected
                            ? (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.15)
                            : (isDark ? Colors.white10 : Colors.grey.shade100),
                        child: Text(
                          item.$4.isNotEmpty ? item.$4.characters.first : '?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? (isDark ? AppColors.accent : AppColors.primary)
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                      title: Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? AppColors.accent : AppColors.primary)
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                      subtitle: Text(
                        '${item.$3} • "${item.$4}"',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: isDark ? AppColors.accent : AppColors.primary, size: 22)
                          : null,
                      onTap: () async {
                        Navigator.pop(ctx);
                        await ref.read(localeProvider.notifier).setLocale(item.$1);
                        try {
                          await ref.read(apiClientProvider).updateArtisanProfile({
                            'preferred_language': item.$1,
                          });
                        } catch (_) {}
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Language updated to ${item.$2} (${item.$3})'),
                              backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}

void _showEditArtisanProfileModal(BuildContext context, WidgetRef ref, UserModel? user) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _EditArtisanProfileSheet(user: user),
  );
}

class _EditArtisanProfileSheet extends ConsumerStatefulWidget {
  final UserModel? user;
  const _EditArtisanProfileSheet({this.user});

  @override
  ConsumerState<_EditArtisanProfileSheet> createState() => _EditArtisanProfileSheetState();
}

class _EditArtisanProfileSheetState extends ConsumerState<_EditArtisanProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _craftController;
  late final TextEditingController _stateController;
  late final TextEditingController _districtController;
  late final TextEditingController _villageController;
  late final TextEditingController _experienceController;
  late final TextEditingController _bioController;
  late final TextEditingController _photoUrlController;
  late String _selectedLanguage;

  bool _isSaving = false;
  String? _errorMessage;

  Uint8List? _pickedImageBytes;

  static const _craftSuggestions = [
    'Banarasi Silk Handloom',
    'Jaipur Blue Pottery',
    'Bastar Dhokra Bronze',
    'Kashmir Pashmina Shawls',
    'Madhubani Folk Art',
    'Channapatna Woodcraft',
    'Tanjore Painting',
    'Phulkari Embroidery',
    'Terracotta & Clay Pottery',
    'Leather & Jutti Craft',
    'Zardozi & Aari Work',
    'Kutch Bandhani & Ajrakh',
  ];

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    _nameController = TextEditingController(text: u?.fullName ?? '');
    _craftController = TextEditingController(text: u?.craftType ?? '');
    _stateController = TextEditingController(text: u?.region ?? '');
    _districtController = TextEditingController(text: u?.district ?? '');
    _villageController = TextEditingController(text: u?.village ?? '');
    _experienceController = TextEditingController(
      text: (u?.experienceYears != null && u!.experienceYears! > 0) ? u.experienceYears.toString() : '5',
    );
    _bioController = TextEditingController(text: u?.bio ?? '');
    _photoUrlController = TextEditingController(text: u?.avatarUrl ?? '');
    _selectedLanguage = u?.preferredLang ?? 'hi';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _craftController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _villageController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
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
                  'Profile Photo',
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
                      color: (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.photo_library_outlined, color: isDark ? AppColors.accent : AppColors.primary),
                  ),
                  title: Text(
                    'Choose from Gallery / Files',
                    style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: AppColors.accent),
                  ),
                  title: Text(
                    'Take Photo with Camera',
                    style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      final updatedUser = await api.updateArtisanProfile({
        'full_name': _nameController.text.trim(),
        'craft_type': _craftController.text.trim(),
        'state': _stateController.text.trim(),
        'district': _districtController.text.trim(),
        'village': _villageController.text.trim(),
        'experience_years': int.tryParse(_experienceController.text.trim()) ?? 0,
        'bio': _bioController.text.trim(),
        'preferred_language': _selectedLanguage,
        'photo_url': _photoUrlController.text.trim(),
        'avatar_url': _photoUrlController.text.trim(),
      });

      ref.read(authProvider.notifier).updateUser(updatedUser);
      ref.read(authProvider.notifier).refreshUser();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Artisan profile updated successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Could not save profile: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
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
                      Icon(Icons.palette_rounded, color: isDark ? AppColors.accent : AppColors.primary, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Edit Artisan Profile',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Update your craft story and details visible to B2B buyers nationwide.',
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),

              // Avatar Selection & Preview Header
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
                            radius: 46,
                            backgroundColor: (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.15),
                            textColor: isDark ? AppColors.accent : AppColors.primary,
                            fontSize: 34,
                            border: Border.all(color: AppColors.accent, width: 2.5),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
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
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.25) : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? const Color(0xFF991B1B) : Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 18, color: isDark ? const Color(0xFFFCA5A5) : Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFFCA5A5) : Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Artisan Full Name *',
                  prefixIcon: Icon(Icons.person_outline, color: isDark ? AppColors.accent : AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _craftController,
                decoration: InputDecoration(
                  labelText: 'Craft Specialization *',
                  prefixIcon: Icon(Icons.brush_outlined, color: isDark ? AppColors.accent : AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  hintText: 'e.g. Banarasi Handloom Weaving',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please specify your craft' : null,
              ),
              const SizedBox(height: 8),
              // Craft quick-select chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _craftSuggestions.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(c, style: const TextStyle(fontSize: 11)),
                        backgroundColor: _craftController.text == c ? AppColors.accent.withValues(alpha: 0.2) : null,
                        onPressed: () => setState(() => _craftController.text = c),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: InputDecoration(
                        labelText: 'State *',
                        prefixIcon: Icon(Icons.map_outlined, color: isDark ? AppColors.accent : AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _districtController,
                      decoration: InputDecoration(
                        labelText: 'District *',
                        prefixIcon: Icon(Icons.location_city_outlined, color: isDark ? AppColors.accent : AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _villageController,
                      decoration: InputDecoration(
                        labelText: 'Village / Cluster',
                        prefixIcon: Icon(Icons.home_work_outlined, color: isDark ? AppColors.accent : AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Experience (Years)',
                        prefixIcon: Icon(Icons.history_edu_outlined, color: isDark ? AppColors.accent : AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Artisan Story / Heritage Bio',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.menu_book_rounded, color: isDark ? AppColors.accent : AppColors.primary),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  hintText: 'Describe your heritage craft, legacy techniques, and traditional values...',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.accent : AppColors.primary,
                    foregroundColor: isDark ? AppColors.primary : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: isDark ? AppColors.primary : Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Save Profile Changes',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

void _showBankDetailsModal(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _BankDetailsSheet(),
  );
}

class _BankDetailsSheet extends ConsumerStatefulWidget {
  const _BankDetailsSheet();

  @override
  ConsumerState<_BankDetailsSheet> createState() => _BankDetailsSheetState();
}

class _BankDetailsSheetState extends ConsumerState<_BankDetailsSheet> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _ifscController = TextEditingController();
  final _upiController = TextEditingController();
  final _aadhaarController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ref.read(apiClientProvider).getArtisanProfile();
      if (mounted) {
        setState(() {
          _accountController.text = profile['bank_account']?.toString() ?? '';
          _ifscController.text = profile['ifsc_code']?.toString() ?? '';
          _upiController.text = profile['upi_id']?.toString() ?? '';
          _aadhaarController.text = profile['aadhaar_number']?.toString() ?? '';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      await api.updateArtisanProfile({
        'bank_account': _accountController.text.trim(),
        'ifsc_code': _ifscController.text.trim().toUpperCase(),
        'upi_id': _upiController.text.trim(),
        if (_aadhaarController.text.trim().isNotEmpty)
          'aadhaar_number': _aadhaarController.text.trim(),
      });

      ref.read(authProvider.notifier).refreshUser();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Bank & UPI details updated successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Could not save details: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: SafeArea(
          child: _isLoading
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: CircularProgressIndicator(color: isDark ? AppColors.accent : AppColors.primary),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.account_balance_outlined,
                                  color: isDark ? AppColors.accent : AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bank & Payout Details',
                                    style: AppTextStyles.headlineSmall.copyWith(
                                      color: textPrimary,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'Manage bank account and UPI for direct payments',
                                    style: AppTextStyles.caption.copyWith(color: textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                                size: 24,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              tooltip: 'Close',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_errorMessage!,
                                      style: const TextStyle(color: AppColors.error, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Bank Account Number
                        TextFormField(
                          controller: _accountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Bank Account Number',
                            hintText: 'e.g. 123456789012',
                            prefixIcon: const Icon(Icons.credit_card_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              if (val.trim().length < 9 || val.trim().length > 18) {
                                return 'Account number should be 9 to 18 digits';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // IFSC Code
                        TextFormField(
                          controller: _ifscController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'IFSC Code',
                            hintText: 'e.g. SBIN0001234',
                            prefixIcon: const Icon(Icons.business_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              if (val.trim().length != 11) {
                                return 'IFSC code must be exactly 11 characters';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // UPI ID
                        TextFormField(
                          controller: _upiController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'UPI ID / VPA',
                            hintText: 'e.g. artisan@upi or 9876543210@paytm',
                            prefixIcon: const Icon(Icons.qr_code_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              if (!val.contains('@')) {
                                return 'Enter a valid UPI ID (e.g. name@bank)';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Aadhaar Number
                        TextFormField(
                          controller: _aadhaarController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Aadhaar Number (Optional)',
                            hintText: '12-digit Aadhaar for KYC verification',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (val) {
                            if (val != null && val.trim().isNotEmpty) {
                              if (val.trim().length != 12) {
                                return 'Aadhaar number must be 12 digits';
                              }
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        AppButton(
                          label: 'Save Payout Details',
                          isLoading: _isSaving,
                          leadingIcon: Icons.save_rounded,
                          onPressed: _save,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

Future<void> _downloadSalesReport(BuildContext context, WidgetRef ref) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          SizedBox(width: 12),
          Text('Generating sales report CSV...'),
        ],
      ),
      duration: Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ),
  );

  try {
    final api = ref.read(apiClientProvider);
    final reportData = await api.getArtisanReport();

    if (reportData.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No report data returned from server.'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (Platform.isAndroid) {
      try {
        await Permission.storage.request();
      } catch (_) {}
    }

    Directory? dir;
    if (Platform.isAndroid) {
      final publicDownload = Directory('/storage/emulated/0/Download');
      if (publicDownload.existsSync()) {
        dir = publicDownload;
      } else {
        try {
          final ext = await getExternalStorageDirectory();
          if (ext != null) dir = ext;
        } catch (_) {}
      }
    }
    dir ??= await getApplicationDocumentsDirectory();

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'KalaSetu_Sales_Report_$timestamp.csv';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(reportData);

    final lineCount = reportData.trim().split('\n').length;
    final rowCount = lineCount > 1 ? lineCount - 1 : 0;

    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.file_download_done_rounded,
                        color: AppColors.success, size: 36),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sales Report Downloaded!',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Exported $rowCount product(s) to CSV',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'File Name:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        Text(
                          fileName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Saved Location:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        Text(
                          file.path,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'File Size: ${file.lengthSync()} bytes',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.table_chart_outlined, size: 18),
                          label: const Text('Preview Report'),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showCsvPreviewModal(context, reportData, fileName, isDark);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppColors.accent : AppColors.primary,
                            foregroundColor: isDark ? AppColors.primary : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'Done',
                          variant: AppButtonVariant.outlined,
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download report: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

void _showCsvPreviewModal(BuildContext context, String csvData, String fileName, bool isDark) {
  final lines = csvData.trim().split('\n').where((l) => l.trim().isNotEmpty).toList();
  if (lines.isEmpty) return;

  final rows = lines.skip(1).map((l) => l.split(',').map((c) => c.trim().replaceAll('"', '')).toList()).toList();

  int totalStock = 0;
  double totalRevenue = 0.0;
  for (final r in rows) {
    if (r.length > 3) totalStock += int.tryParse(r[3]) ?? 0;
    if (r.length > 8) totalRevenue += double.tryParse(r[8]) ?? 0.0;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sales Report Preview',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        fileName,
                        style: AppTextStyles.caption.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Listings', style: AppTextStyles.caption),
                        Text('${rows.length}', style: AppTextStyles.titleMedium.copyWith(color: isDark ? AppColors.accent : AppColors.primary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Stock', style: AppTextStyles.caption),
                        Text('$totalStock pcs', style: AppTextStyles.titleMedium.copyWith(color: AppColors.info, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Est. Revenue', style: AppTextStyles.caption),
                        Text(AppFormatters.inrCompact(totalRevenue), style: AppTextStyles.titleMedium.copyWith(color: AppColors.success, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 16,
                    headingRowColor: WidgetStateProperty.all(
                      isDark ? Colors.white10 : Colors.grey.shade100,
                    ),
                    columns: const [
                      DataColumn(label: Text('Product')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Stock')),
                      DataColumn(label: Text('Base Price')),
                      DataColumn(label: Text('Views')),
                      DataColumn(label: Text('Inquiries')),
                      DataColumn(label: Text('Est. Revenue')),
                    ],
                    rows: rows.map((r) {
                      final title = r.length > 1 ? r[1] : '';
                      final status = r.length > 2 ? r[2] : '';
                      final stock = r.length > 3 ? r[3] : '0';
                      final price = r.length > 4 ? '₹${r[4]}' : '₹0';
                      final views = r.length > 5 ? r[5] : '0';
                      final inqs = r.length > 6 ? r[6] : '0';
                      final rev = r.length > 8 ? '₹${r[8]}' : '₹0';

                      return DataRow(cells: [
                        DataCell(SizedBox(
                          width: 140,
                          child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        )),
                        DataCell(Text(status)),
                        DataCell(Text(stock)),
                        DataCell(Text(price)),
                        DataCell(Text(views)),
                        DataCell(Text(inqs)),
                        DataCell(Text(rev, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success))),
                      ]);
                    }).toList(),
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

class _AnalyticsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final analyticsAsync = ref.watch(_artisanAnalyticsProvider);
    return analyticsAsync.when(
      data: (data) {
        final totalProducts = data['total_products'] ?? data['total_listings'] ?? 0;
        final totalOrders = data['total_orders'] ?? 0;
        final revenue = ((data['revenue_estimate'] ?? data['total_revenue_estimate'] ?? 0) as num).toDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_profileTr(lang, 'performance'), style: AppTextStyles.headlineSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _AnalyticCard(
                  label: _profileTr(lang, 'totalProducts'),
                  value: '$totalProducts',
                  icon: Icons.inventory_2_outlined,
                  color: AppColors.info,
                )),
                const SizedBox(width: 12),
                Expanded(child: _AnalyticCard(
                  label: _profileTr(lang, 'totalOrders'),
                  value: '$totalOrders',
                  icon: Icons.shopping_bag_outlined,
                  color: AppColors.success,
                )),
                const SizedBox(width: 12),
                Expanded(child: _AnalyticCard(
                  label: _profileTr(lang, 'revenue'),
                  value: AppFormatters.inrCompact(revenue),
                  icon: Icons.currency_rupee_rounded,
                  color: AppColors.accent,
                )),
              ],
            ),
          ],
        );
      },
      loading: () => const ShimmerLoader(width: double.infinity, height: 80, borderRadius: 12),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _AnalyticCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.headlineSmall.copyWith(color: color)),
          Text(label, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: isDark ? AppColors.accent : AppColors.primary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary) : null),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

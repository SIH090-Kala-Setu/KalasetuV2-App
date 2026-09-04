// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'कलाSetu';

  @override
  String get appTagline => 'Empowering Rural Artisans';

  @override
  String get welcome => 'Welcome to कलाSetu';

  @override
  String get welcomeSubtitle =>
      'AI-powered marketplace for India\'s master craftspeople';

  @override
  String get getStarted => 'Get Started';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get register => 'Register';

  @override
  String get continueText => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get retry => 'Retry';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get share => 'Share';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get all => 'All';

  @override
  String get loading => 'Loading...';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get selectLanguage => 'Select Your Language';

  @override
  String get selectLanguageSubtitle =>
      'Choose your preferred language to continue';

  @override
  String get selectRole => 'Who are you?';

  @override
  String get selectRoleSubtitle => 'Choose your role to get started';

  @override
  String get artisan => 'Artisan';

  @override
  String get artisanDesc => 'I create handcrafted products';

  @override
  String get aggregator => 'Aggregator';

  @override
  String get aggregatorDesc => 'I manage artisan clusters';

  @override
  String get buyer => 'B2B Buyer';

  @override
  String get buyerDesc => 'I source crafts for my business';

  @override
  String get enterPhone => 'Enter Your Phone Number';

  @override
  String get enterPhoneHint => '+91 98765 43210';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String enterOtpSubtitle(Object phone) {
    return '6-digit code sent to $phone';
  }

  @override
  String get verifyOtp => 'Verify & Continue';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String resendOtpIn(Object seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get registerAccount => 'Create Account';

  @override
  String get personalDetails => 'Personal Details';

  @override
  String get craftDetails => 'Craft & Location';

  @override
  String get kycDetails => 'KYC Verification';

  @override
  String get pendingVerification => 'Verification Pending';

  @override
  String get fullName => 'Full Name';

  @override
  String get craftType => 'Craft Specialization';

  @override
  String get region => 'Region';

  @override
  String get district => 'District';

  @override
  String get village => 'Village';

  @override
  String get aadhaarNumber => 'Aadhaar Number';

  @override
  String get bankAccount => 'Bank Account Number';

  @override
  String get ifscCode => 'IFSC Code';

  @override
  String get upiId => 'UPI ID';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get home => 'Home';

  @override
  String get catalogue => 'Catalogue';

  @override
  String get inquiries => 'Inquiries';

  @override
  String get profile => 'Profile';

  @override
  String get studio => 'AI Studio';

  @override
  String get artisanHome => 'My Dashboard';

  @override
  String get earnings => 'Earnings';

  @override
  String get monthlyEarnings => 'Monthly Earnings';

  @override
  String get activeListings => 'Active Listings';

  @override
  String get pendingInquiries => 'Pending Inquiries';

  @override
  String get totalViews => 'Total Views';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addProduct => 'Add Product';

  @override
  String get viewCatalogue => 'View Catalogue';

  @override
  String get viewInquiries => 'View Inquiries';

  @override
  String get exhibitions => 'Exhibitions';

  @override
  String get recentInquiries => 'Recent Inquiries';

  @override
  String get viewAll => 'View All';

  @override
  String get schemes => 'Govt. Schemes';

  @override
  String get aiStudio => 'AI Camera Studio';

  @override
  String get aiStudioSubtitle => 'Capture, Enhance & Publish your craft';

  @override
  String get phase1Title => 'Capture Your Craft';

  @override
  String get phase1Subtitle => 'Take a photo or choose from gallery';

  @override
  String get phase2Title => 'AI Enhancement';

  @override
  String get phase2Subtitle => 'Removing background & adding studio lighting';

  @override
  String get phase3Title => 'Voice Description';

  @override
  String get phase3Subtitle => 'Describe your craft in your language';

  @override
  String get phase4Title => 'Smart Pricing';

  @override
  String get phase4Subtitle => 'AI-calculated fair-wage price';

  @override
  String get capturePhoto => 'Capture Photo';

  @override
  String get chooseGallery => 'Choose from Gallery';

  @override
  String get enhancing => 'Enhancing with AI...';

  @override
  String get enhancementDone => 'Enhancement Complete';

  @override
  String get beforeLabel => 'Before';

  @override
  String get afterLabel => 'After';

  @override
  String get recordVoice => 'Record Voice Note';

  @override
  String get stopRecording => 'Stop Recording';

  @override
  String get generating => 'Generating with AI...';

  @override
  String get generatedTitle => 'Generated Title';

  @override
  String get generatedDescription => 'Generated Description';

  @override
  String get materialCost => 'Material Cost (₹)';

  @override
  String get laborHours => 'Labor Hours';

  @override
  String get suggestedPrice => 'Suggested Price';

  @override
  String get retailPrice => 'Retail Price';

  @override
  String get wholesalePrice => 'Wholesale Price';

  @override
  String get publishListing => 'Publish to Marketplace';

  @override
  String get saveDraft => 'Save as Draft';

  @override
  String get resumeDraft => 'Resume Draft';

  @override
  String get resumeDraftMessage =>
      'You have an unfinished draft. Resume where you left off?';

  @override
  String get marketplace => 'Marketplace';

  @override
  String get searchProducts => 'Search products, artisans, crafts...';

  @override
  String get productDetail => 'Product Detail';

  @override
  String get addToInquiry => 'Send Wholesale Inquiry';

  @override
  String get viewArtisanPortfolio => 'View Artisan Portfolio';

  @override
  String get artisanPortfolio => 'Artisan Portfolio';

  @override
  String get sharePortfolio => 'Share Portfolio';

  @override
  String get myInquiries => 'My Inquiries';

  @override
  String get sentInquiries => 'Sent Inquiries';

  @override
  String get craftStory => 'Craft Story';

  @override
  String get craftStoryHindi => 'Hindi Story';

  @override
  String get giTagCertified => 'GI Tag Certified';

  @override
  String get moq => 'Minimum Order Qty';

  @override
  String get stock => 'In Stock';

  @override
  String get notifications => 'Notifications';

  @override
  String get markAllRead => 'Mark All Read';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get settings => 'Settings';

  @override
  String get serverConfig => 'Server Configuration';

  @override
  String get backendUrl => 'Backend URL';

  @override
  String get saveUrl => 'Save URL';

  @override
  String get verifiedArtisan => 'MoSJE Certified Master Artisan';

  @override
  String get kycApproved => 'KYC Approved';

  @override
  String get kycPending => 'KYC Pending';

  @override
  String get myPortfolio => 'View My Portfolio';

  @override
  String get salesReport => 'Download Sales Report';

  @override
  String get bankDetails => 'Bank & UPI Details';

  @override
  String get clusterHealth => 'Cluster Health';

  @override
  String get myArtisans => 'My Artisans';

  @override
  String get analytics => 'Analytics';

  @override
  String get alerts => 'Alerts & Schemes';

  @override
  String get totalArtisans => 'Total Artisans';

  @override
  String get activeListingsCount => 'Active Listings';

  @override
  String get assistOnboard => 'Assist & Onboard Artisan';

  @override
  String get onboardArtisan => 'Onboard New Artisan';

  @override
  String get relayScheme => 'Relay Scheme';

  @override
  String get submitReport => 'Submit Monthly Report';

  @override
  String get offlineSaved => 'Saved offline. Will publish when connected.';

  @override
  String get offlineSyncBanner =>
      'Pending uploads will sync when internet returns.';

  @override
  String get publishedSuccess =>
      'Your craft listing was successfully published!';

  @override
  String get writeReview => 'Write a Review';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get yourReview => 'Your Review';

  @override
  String get wouldRecommend => 'Would you recommend this to other buyers?';

  @override
  String get verifiedBuyer => 'Verified Buyer';

  @override
  String get language_en => 'English';

  @override
  String get language_hi => 'हिन्दी';

  @override
  String get language_bn => 'বাংলা';

  @override
  String get language_ta => 'தமிழ்';

  @override
  String get language_te => 'తెలుగు';

  @override
  String get language_mr => 'मराठी';

  @override
  String get language_kn => 'ಕನ್ನಡ';

  @override
  String get language_gu => 'ગુજરાતી';
}

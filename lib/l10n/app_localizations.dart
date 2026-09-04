import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'कलाSetu'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Empowering Rural Artisans'**
  String get appTagline;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to कलाSetu'**
  String get welcome;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-powered marketplace for India\'s master craftspeople'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Your Language'**
  String get selectLanguage;

  /// No description provided for @selectLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language to continue'**
  String get selectLanguageSubtitle;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Who are you?'**
  String get selectRole;

  /// No description provided for @selectRoleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your role to get started'**
  String get selectRoleSubtitle;

  /// No description provided for @artisan.
  ///
  /// In en, this message translates to:
  /// **'Artisan'**
  String get artisan;

  /// No description provided for @artisanDesc.
  ///
  /// In en, this message translates to:
  /// **'I create handcrafted products'**
  String get artisanDesc;

  /// No description provided for @aggregator.
  ///
  /// In en, this message translates to:
  /// **'Aggregator'**
  String get aggregator;

  /// No description provided for @aggregatorDesc.
  ///
  /// In en, this message translates to:
  /// **'I manage artisan clusters'**
  String get aggregatorDesc;

  /// No description provided for @buyer.
  ///
  /// In en, this message translates to:
  /// **'B2B Buyer'**
  String get buyer;

  /// No description provided for @buyerDesc.
  ///
  /// In en, this message translates to:
  /// **'I source crafts for my business'**
  String get buyerDesc;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Phone Number'**
  String get enterPhone;

  /// No description provided for @enterPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'+91 98765 43210'**
  String get enterPhoneHint;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @enterOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'6-digit code sent to {phone}'**
  String enterOtpSubtitle(Object phone);

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @resendOtpIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendOtpIn(Object seconds);

  /// No description provided for @registerAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerAccount;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @craftDetails.
  ///
  /// In en, this message translates to:
  /// **'Craft & Location'**
  String get craftDetails;

  /// No description provided for @kycDetails.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification'**
  String get kycDetails;

  /// No description provided for @pendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get pendingVerification;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @craftType.
  ///
  /// In en, this message translates to:
  /// **'Craft Specialization'**
  String get craftType;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @village.
  ///
  /// In en, this message translates to:
  /// **'Village'**
  String get village;

  /// No description provided for @aadhaarNumber.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar Number'**
  String get aadhaarNumber;

  /// No description provided for @bankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank Account Number'**
  String get bankAccount;

  /// No description provided for @ifscCode.
  ///
  /// In en, this message translates to:
  /// **'IFSC Code'**
  String get ifscCode;

  /// No description provided for @upiId.
  ///
  /// In en, this message translates to:
  /// **'UPI ID'**
  String get upiId;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @catalogue.
  ///
  /// In en, this message translates to:
  /// **'Catalogue'**
  String get catalogue;

  /// No description provided for @inquiries.
  ///
  /// In en, this message translates to:
  /// **'Inquiries'**
  String get inquiries;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @studio.
  ///
  /// In en, this message translates to:
  /// **'AI Studio'**
  String get studio;

  /// No description provided for @artisanHome.
  ///
  /// In en, this message translates to:
  /// **'My Dashboard'**
  String get artisanHome;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @monthlyEarnings.
  ///
  /// In en, this message translates to:
  /// **'Monthly Earnings'**
  String get monthlyEarnings;

  /// No description provided for @activeListings.
  ///
  /// In en, this message translates to:
  /// **'Active Listings'**
  String get activeListings;

  /// No description provided for @pendingInquiries.
  ///
  /// In en, this message translates to:
  /// **'Pending Inquiries'**
  String get pendingInquiries;

  /// No description provided for @totalViews.
  ///
  /// In en, this message translates to:
  /// **'Total Views'**
  String get totalViews;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @viewCatalogue.
  ///
  /// In en, this message translates to:
  /// **'View Catalogue'**
  String get viewCatalogue;

  /// No description provided for @viewInquiries.
  ///
  /// In en, this message translates to:
  /// **'View Inquiries'**
  String get viewInquiries;

  /// No description provided for @exhibitions.
  ///
  /// In en, this message translates to:
  /// **'Exhibitions'**
  String get exhibitions;

  /// No description provided for @recentInquiries.
  ///
  /// In en, this message translates to:
  /// **'Recent Inquiries'**
  String get recentInquiries;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @schemes.
  ///
  /// In en, this message translates to:
  /// **'Govt. Schemes'**
  String get schemes;

  /// No description provided for @aiStudio.
  ///
  /// In en, this message translates to:
  /// **'AI Camera Studio'**
  String get aiStudio;

  /// No description provided for @aiStudioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture, Enhance & Publish your craft'**
  String get aiStudioSubtitle;

  /// No description provided for @phase1Title.
  ///
  /// In en, this message translates to:
  /// **'Capture Your Craft'**
  String get phase1Title;

  /// No description provided for @phase1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or choose from gallery'**
  String get phase1Subtitle;

  /// No description provided for @phase2Title.
  ///
  /// In en, this message translates to:
  /// **'AI Enhancement'**
  String get phase2Title;

  /// No description provided for @phase2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Removing background & adding studio lighting'**
  String get phase2Subtitle;

  /// No description provided for @phase3Title.
  ///
  /// In en, this message translates to:
  /// **'Voice Description'**
  String get phase3Title;

  /// No description provided for @phase3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Describe your craft in your language'**
  String get phase3Subtitle;

  /// No description provided for @phase4Title.
  ///
  /// In en, this message translates to:
  /// **'Smart Pricing'**
  String get phase4Title;

  /// No description provided for @phase4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-calculated fair-wage price'**
  String get phase4Subtitle;

  /// No description provided for @capturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Capture Photo'**
  String get capturePhoto;

  /// No description provided for @chooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseGallery;

  /// No description provided for @enhancing.
  ///
  /// In en, this message translates to:
  /// **'Enhancing with AI...'**
  String get enhancing;

  /// No description provided for @enhancementDone.
  ///
  /// In en, this message translates to:
  /// **'Enhancement Complete'**
  String get enhancementDone;

  /// No description provided for @beforeLabel.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get beforeLabel;

  /// No description provided for @afterLabel.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get afterLabel;

  /// No description provided for @recordVoice.
  ///
  /// In en, this message translates to:
  /// **'Record Voice Note'**
  String get recordVoice;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop Recording'**
  String get stopRecording;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating with AI...'**
  String get generating;

  /// No description provided for @generatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Generated Title'**
  String get generatedTitle;

  /// No description provided for @generatedDescription.
  ///
  /// In en, this message translates to:
  /// **'Generated Description'**
  String get generatedDescription;

  /// No description provided for @materialCost.
  ///
  /// In en, this message translates to:
  /// **'Material Cost (₹)'**
  String get materialCost;

  /// No description provided for @laborHours.
  ///
  /// In en, this message translates to:
  /// **'Labor Hours'**
  String get laborHours;

  /// No description provided for @suggestedPrice.
  ///
  /// In en, this message translates to:
  /// **'Suggested Price'**
  String get suggestedPrice;

  /// No description provided for @retailPrice.
  ///
  /// In en, this message translates to:
  /// **'Retail Price'**
  String get retailPrice;

  /// No description provided for @wholesalePrice.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Price'**
  String get wholesalePrice;

  /// No description provided for @publishListing.
  ///
  /// In en, this message translates to:
  /// **'Publish to Marketplace'**
  String get publishListing;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save as Draft'**
  String get saveDraft;

  /// No description provided for @resumeDraft.
  ///
  /// In en, this message translates to:
  /// **'Resume Draft'**
  String get resumeDraft;

  /// No description provided for @resumeDraftMessage.
  ///
  /// In en, this message translates to:
  /// **'You have an unfinished draft. Resume where you left off?'**
  String get resumeDraftMessage;

  /// No description provided for @marketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products, artisans, crafts...'**
  String get searchProducts;

  /// No description provided for @productDetail.
  ///
  /// In en, this message translates to:
  /// **'Product Detail'**
  String get productDetail;

  /// No description provided for @addToInquiry.
  ///
  /// In en, this message translates to:
  /// **'Send Wholesale Inquiry'**
  String get addToInquiry;

  /// No description provided for @viewArtisanPortfolio.
  ///
  /// In en, this message translates to:
  /// **'View Artisan Portfolio'**
  String get viewArtisanPortfolio;

  /// No description provided for @artisanPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Artisan Portfolio'**
  String get artisanPortfolio;

  /// No description provided for @sharePortfolio.
  ///
  /// In en, this message translates to:
  /// **'Share Portfolio'**
  String get sharePortfolio;

  /// No description provided for @myInquiries.
  ///
  /// In en, this message translates to:
  /// **'My Inquiries'**
  String get myInquiries;

  /// No description provided for @sentInquiries.
  ///
  /// In en, this message translates to:
  /// **'Sent Inquiries'**
  String get sentInquiries;

  /// No description provided for @craftStory.
  ///
  /// In en, this message translates to:
  /// **'Craft Story'**
  String get craftStory;

  /// No description provided for @craftStoryHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi Story'**
  String get craftStoryHindi;

  /// No description provided for @giTagCertified.
  ///
  /// In en, this message translates to:
  /// **'GI Tag Certified'**
  String get giTagCertified;

  /// No description provided for @moq.
  ///
  /// In en, this message translates to:
  /// **'Minimum Order Qty'**
  String get moq;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get stock;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All Read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @serverConfig.
  ///
  /// In en, this message translates to:
  /// **'Server Configuration'**
  String get serverConfig;

  /// No description provided for @backendUrl.
  ///
  /// In en, this message translates to:
  /// **'Backend URL'**
  String get backendUrl;

  /// No description provided for @saveUrl.
  ///
  /// In en, this message translates to:
  /// **'Save URL'**
  String get saveUrl;

  /// No description provided for @verifiedArtisan.
  ///
  /// In en, this message translates to:
  /// **'MoSJE Certified Master Artisan'**
  String get verifiedArtisan;

  /// No description provided for @kycApproved.
  ///
  /// In en, this message translates to:
  /// **'KYC Approved'**
  String get kycApproved;

  /// No description provided for @kycPending.
  ///
  /// In en, this message translates to:
  /// **'KYC Pending'**
  String get kycPending;

  /// No description provided for @myPortfolio.
  ///
  /// In en, this message translates to:
  /// **'View My Portfolio'**
  String get myPortfolio;

  /// No description provided for @salesReport.
  ///
  /// In en, this message translates to:
  /// **'Download Sales Report'**
  String get salesReport;

  /// No description provided for @bankDetails.
  ///
  /// In en, this message translates to:
  /// **'Bank & UPI Details'**
  String get bankDetails;

  /// No description provided for @clusterHealth.
  ///
  /// In en, this message translates to:
  /// **'Cluster Health'**
  String get clusterHealth;

  /// No description provided for @myArtisans.
  ///
  /// In en, this message translates to:
  /// **'My Artisans'**
  String get myArtisans;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts & Schemes'**
  String get alerts;

  /// No description provided for @totalArtisans.
  ///
  /// In en, this message translates to:
  /// **'Total Artisans'**
  String get totalArtisans;

  /// No description provided for @activeListingsCount.
  ///
  /// In en, this message translates to:
  /// **'Active Listings'**
  String get activeListingsCount;

  /// No description provided for @assistOnboard.
  ///
  /// In en, this message translates to:
  /// **'Assist & Onboard Artisan'**
  String get assistOnboard;

  /// No description provided for @onboardArtisan.
  ///
  /// In en, this message translates to:
  /// **'Onboard New Artisan'**
  String get onboardArtisan;

  /// No description provided for @relayScheme.
  ///
  /// In en, this message translates to:
  /// **'Relay Scheme'**
  String get relayScheme;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Monthly Report'**
  String get submitReport;

  /// No description provided for @offlineSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved offline. Will publish when connected.'**
  String get offlineSaved;

  /// No description provided for @offlineSyncBanner.
  ///
  /// In en, this message translates to:
  /// **'Pending uploads will sync when internet returns.'**
  String get offlineSyncBanner;

  /// No description provided for @publishedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your craft listing was successfully published!'**
  String get publishedSuccess;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get writeReview;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// No description provided for @yourReview.
  ///
  /// In en, this message translates to:
  /// **'Your Review'**
  String get yourReview;

  /// No description provided for @wouldRecommend.
  ///
  /// In en, this message translates to:
  /// **'Would you recommend this to other buyers?'**
  String get wouldRecommend;

  /// No description provided for @verifiedBuyer.
  ///
  /// In en, this message translates to:
  /// **'Verified Buyer'**
  String get verifiedBuyer;

  /// No description provided for @language_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_en;

  /// No description provided for @language_hi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get language_hi;

  /// No description provided for @language_bn.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get language_bn;

  /// No description provided for @language_ta.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get language_ta;

  /// No description provided for @language_te.
  ///
  /// In en, this message translates to:
  /// **'తెలుగు'**
  String get language_te;

  /// No description provided for @language_mr.
  ///
  /// In en, this message translates to:
  /// **'मराठी'**
  String get language_mr;

  /// No description provided for @language_kn.
  ///
  /// In en, this message translates to:
  /// **'ಕನ್ನಡ'**
  String get language_kn;

  /// No description provided for @language_gu.
  ///
  /// In en, this message translates to:
  /// **'ગુજરાતી'**
  String get language_gu;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

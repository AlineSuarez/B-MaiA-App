// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'B-MaiA';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get cancel => 'Cancel';

  @override
  String get accept => 'Accept';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get finish => 'Finish';

  @override
  String get skip => 'Skip';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get more => 'More';

  @override
  String get less => 'Less';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get welcome => 'Welcome';

  @override
  String welcomeUser(String name) {
    return 'Welcome, $name';
  }

  @override
  String welcomeBack(String name) {
    return 'Welcome back, $name!';
  }

  @override
  String get signInToContinue => 'Sign in to continue with B-MaiA';

  @override
  String get login => 'Sign in';

  @override
  String get loginSuccess => 'Sign in successful!';

  @override
  String get logout => 'Sign out';

  @override
  String get logoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get register => 'Sign up';

  @override
  String get registerNow => 'Sign up now';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinBMaia => 'Join B-MaiA and start your experience';

  @override
  String get registerSuccess => 'Registration successful!';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get email => 'Email';

  @override
  String get emailPlaceholder => 'Enter your email';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get password => 'Password';

  @override
  String get passwordPlaceholder => 'Enter your password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get confirmPasswordPlaceholder => 'Confirm your password';

  @override
  String get newPassword => 'New password';

  @override
  String get currentPassword => 'Current password';

  @override
  String get fullName => 'Full name';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get region => 'Region';

  @override
  String get commune => 'Commune';

  @override
  String get rut => 'RUT';

  @override
  String get businessName => 'Business name';

  @override
  String get sagRegistry => 'SAG Beekeeper Registration Number';

  @override
  String get requiredField => 'This field is required';

  @override
  String get requiredFields => 'Please fill in all fields';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get invalidEmailFormat => 'Please enter a valid email address';

  @override
  String passwordTooShort(int count) {
    return 'Password must be at least $count characters';
  }

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String nameTooShort(int count) {
    return 'Name must be at least $count characters';
  }

  @override
  String get acceptTerms => 'You must accept the terms and conditions';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get forgotPasswordTitle => 'Forgot your password?';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send you instructions to recover it';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get sendInstructions => 'Send Instructions';

  @override
  String get emailSent => 'Email Sent!';

  @override
  String get emailSentMessage => 'Check your email to reset your password';

  @override
  String get emailSentTitle => 'Check your email';

  @override
  String get checkEmailMessage =>
      'We\'ve sent you instructions to reset your password';

  @override
  String get emailSentTo => 'We\'ve sent an email to:';

  @override
  String get resendEmail => 'Resend Email';

  @override
  String get backToLogin => 'Back to sign in';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get orContinueWith => 'or continue with';

  @override
  String get orRegisterWith => 'or register with';

  @override
  String get googleTokenError => 'Could not get Google authentication token';

  @override
  String get termsAndConditions => 'terms and conditions';

  @override
  String acceptTermsMessage(String terms) {
    return 'I accept the $terms';
  }

  @override
  String get home => 'Home';

  @override
  String get intelligentAssistant => 'Intelligent assistant';

  @override
  String get newConversation => 'New conversation';

  @override
  String get history => 'History';

  @override
  String get clearChat => 'Clear chat';

  @override
  String get clearChatConfirm =>
      'Are you sure you want to delete all messages from this conversation?';

  @override
  String get clear => 'Clear';

  @override
  String get messageInputPlaceholder => 'Type your message here...';

  @override
  String get typingIndicator => 'B-MaiA is typing...';

  @override
  String get sendMessage => 'Send message';

  @override
  String get helloBMaia => 'Hello! I\'m B-MaiA';

  @override
  String get aiAssistantDescription =>
      'Your artificial intelligence assistant. Ask me anything you need, I\'m here to help.';

  @override
  String get writeFirstQuestion => 'Write your first question';

  @override
  String get trySaying => 'Try asking:';

  @override
  String get howCanYouHelp => 'How can you help me?';

  @override
  String get helpWithProgramming => 'Help me with programming';

  @override
  String get explainConcept => 'Explain a concept';

  @override
  String get helpMeWrite => 'Help me write';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get application => 'Application';

  @override
  String get security => 'Security';

  @override
  String get preferences => 'Preferences';

  @override
  String get account => 'Account';

  @override
  String get subscription => 'Subscription';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'Follow system';

  @override
  String get selectTheme => 'Select theme';

  @override
  String get systemTheme => 'System';

  @override
  String get systemThemeSubtitle => 'Follow system';

  @override
  String get lightMode => 'Light mode';

  @override
  String get lightModeSubtitle => 'Force light mode';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeSubtitle => 'Force dark mode';

  @override
  String get useSystemTheme => 'Use system theme';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select app language';

  @override
  String get spanish => 'Español';

  @override
  String get english => 'English';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Notification preferences';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get notificationSettings => 'Notification settings';

  @override
  String get helpSupport => 'Help and support';

  @override
  String get helpSupportSubtitle => 'Help center and contact';

  @override
  String get helpCenter => 'Help center';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get faq => 'Frequently asked questions';

  @override
  String get documentation => 'Documentation';

  @override
  String get about => 'About';

  @override
  String get aboutSubtitle => 'Application information';

  @override
  String get version => 'Version';

  @override
  String get build => 'Build';

  @override
  String get termsOfService => 'Terms of service';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get licenses => 'Licenses';

  @override
  String get profile => 'My Profile';

  @override
  String get myProfile => 'My Profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get location => 'Location';

  @override
  String get legalData => 'Legal data';

  @override
  String get legalDataRut => 'User or Legal Representative RUT';

  @override
  String get legalDataBusinessName => 'Business name';

  @override
  String get sagRegistryNumber => 'SAG Beekeeper Registration Number';

  @override
  String get memberSince => 'Member since';

  @override
  String get userId => 'User ID';

  @override
  String get profilePicture => 'Profile picture';

  @override
  String get selectPhoto => 'Select photo';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get photoSelected => 'Photo selected (preview)';

  @override
  String get photoRemoved => 'Photo removed (preview)';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordSubtitle => 'Update your password';

  @override
  String get twoFactorAuth => 'Two-factor authentication';

  @override
  String get twoFactorAuthSubtitle => 'Add an extra layer of security';

  @override
  String get securitySettings => 'Security settings';

  @override
  String get languageSettings => 'Language';

  @override
  String get languageSubtitle => 'English';

  @override
  String get dataManagement => 'Data management';

  @override
  String get dataManagementSubtitle => 'History and storage';

  @override
  String get storageManagement => 'Storage management';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get freePlan => 'Free Plan';

  @override
  String get premiumPlan => 'Premium Plan';

  @override
  String get upgradePlan => 'Upgrade plan';

  @override
  String get upgradeForMore => 'Upgrade for more features';

  @override
  String get viewPremiumPlans => 'View Premium plans';

  @override
  String get currentPlan => 'Current plan';

  @override
  String get billing => 'Billing';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirm =>
      'This action is irreversible. All your data and conversations will be deleted.';

  @override
  String get accountDeleted => 'Account deleted';

  @override
  String get welcomeToBMaia => 'Welcome to B-MaiA!';

  @override
  String get onboardingTitle1 => 'Welcome to B-MaiA!';

  @override
  String get onboardingDesc1 =>
      'Discover a new way to manage your projects with advanced artificial intelligence.';

  @override
  String get onboardingTitle2 => 'Advanced Technology';

  @override
  String get onboardingDesc2 =>
      'We use the latest AI innovations to give you the best possible experience.';

  @override
  String get onboardingTitle3 => 'Personalized Experience';

  @override
  String get onboardingDesc3 =>
      'Every feature is designed with your specific needs and preferences in mind.';

  @override
  String get getStarted => 'Get started';

  @override
  String get viewIntroduction => 'View introduction';

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get errorConnection => 'Connection error';

  @override
  String get errorTimeout => 'Request timeout';

  @override
  String get errorServer => 'Server error';

  @override
  String get errorNotFound => 'Not found';

  @override
  String get errorUnauthorized => 'Unauthorized';

  @override
  String get errorForbidden => 'Access denied';

  @override
  String get errorTryAgain => 'Please try again';

  @override
  String get errorImageSelection => 'Error selecting image';

  @override
  String get featureInDevelopment => 'Feature in development';

  @override
  String get successGeneric => 'Operation successful';

  @override
  String get successSaved => 'Saved successfully';

  @override
  String get successUpdated => 'Updated successfully';

  @override
  String get successDeleted => 'Deleted successfully';

  @override
  String get successSent => 'Sent successfully';

  @override
  String get menu => 'Menu';

  @override
  String get chats => 'Conversations';

  @override
  String chatHistory(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversations',
      one: '1 conversation',
      zero: 'No conversations',
    );
    return '$_temp0';
  }

  @override
  String get myAccount => 'My Account';

  @override
  String get chat => 'Chat';

  @override
  String get message => 'Message';

  @override
  String get messages => 'Messages';

  @override
  String get noMessages => 'No messages';

  @override
  String get typing => 'Typing...';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get lastSeen => 'Last seen';

  @override
  String get readBy => 'Read by';

  @override
  String get deliveredTo => 'Delivered to';

  @override
  String get sent => 'Sent';

  @override
  String get received => 'Received';

  @override
  String get read => 'Read';

  @override
  String get now => 'Now';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get orWord => 'or';

  @override
  String get andWord => 'and';

  @override
  String get toWord => 'to';

  @override
  String get fromWord => 'from';

  @override
  String get inWord => 'in';

  @override
  String get atWord => 'at';

  @override
  String get onWord => 'on';

  @override
  String get byWord => 'by';

  @override
  String get withWord => 'with';

  @override
  String get withoutWord => 'without';

  @override
  String get forWord => 'for';

  @override
  String get notAvailable => '—';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get betaLabel => 'Beta';

  @override
  String get newLabel => 'New';

  @override
  String get nameMinLength => 'Name must be at least 3 characters';
}

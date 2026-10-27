import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get appTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get searchHint;

  /// No description provided for @sortAscending.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'Z-A'**
  String get sortDescending;

  /// No description provided for @foundCount.
  ///
  /// In en, this message translates to:
  /// **'Found: {count}'**
  String foundCount(int count);

  /// No description provided for @permissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'No access to contacts'**
  String get permissionDeniedTitle;

  /// No description provided for @permissionDeniedBody.
  ///
  /// In en, this message translates to:
  /// **'Allow the app to read contacts to show the address book. This is different from an empty book.'**
  String get permissionDeniedBody;

  /// No description provided for @requestPermission.
  ///
  /// In en, this message translates to:
  /// **'Request access'**
  String get requestPermission;

  /// No description provided for @permissionBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Access is blocked'**
  String get permissionBlockedTitle;

  /// No description provided for @permissionBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'The system will not show the request again. Open the app settings and allow contacts.'**
  String get permissionBlockedBody;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @emptyBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Address book is empty'**
  String get emptyBookTitle;

  /// No description provided for @emptyBookBody.
  ///
  /// In en, this message translates to:
  /// **'There are no contacts. Read access is already granted.'**
  String get emptyBookBody;

  /// No description provided for @emptySearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get emptySearchTitle;

  /// No description provided for @emptySearchBody.
  ///
  /// In en, this message translates to:
  /// **'No contacts with this name.'**
  String get emptySearchBody;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading contacts'**
  String get loading;

  /// No description provided for @readErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not read contacts'**
  String get readErrorTitle;

  /// No description provided for @readErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while reading the address book.'**
  String get readErrorBody;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @emailBadge.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailBadge;

  /// No description provided for @unnamedContact.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get unnamedContact;

  /// No description provided for @phonesSection.
  ///
  /// In en, this message translates to:
  /// **'Phones'**
  String get phonesSection;

  /// No description provided for @emailsSection.
  ///
  /// In en, this message translates to:
  /// **'Emails'**
  String get emailsSection;

  /// No description provided for @extrasSection.
  ///
  /// In en, this message translates to:
  /// **'Additional'**
  String get extrasSection;

  /// No description provided for @noPhones.
  ///
  /// In en, this message translates to:
  /// **'No phone number'**
  String get noPhones;

  /// No description provided for @noEmails.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmails;

  /// No description provided for @labelMobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get labelMobile;

  /// No description provided for @labelHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get labelHome;

  /// No description provided for @labelWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get labelWork;

  /// No description provided for @labelMain.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get labelMain;

  /// No description provided for @labelFax.
  ///
  /// In en, this message translates to:
  /// **'Fax'**
  String get labelFax;

  /// No description provided for @labelPager.
  ///
  /// In en, this message translates to:
  /// **'Pager'**
  String get labelPager;

  /// No description provided for @labelSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get labelSchool;

  /// No description provided for @labelIphone.
  ///
  /// In en, this message translates to:
  /// **'iPhone'**
  String get labelIphone;

  /// No description provided for @labelOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get labelOther;

  /// No description provided for @labelCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get labelCompany;

  /// No description provided for @labelJobTitle.
  ///
  /// In en, this message translates to:
  /// **'Job title'**
  String get labelJobTitle;

  /// No description provided for @labelDepartment.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get labelDepartment;

  /// No description provided for @labelOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get labelOffice;

  /// No description provided for @labelJobDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get labelJobDescription;

  /// No description provided for @labelAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get labelAddress;

  /// No description provided for @labelWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get labelWebsite;

  /// No description provided for @labelBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get labelBirthday;

  /// No description provided for @labelAnniversary.
  ///
  /// In en, this message translates to:
  /// **'Anniversary'**
  String get labelAnniversary;

  /// No description provided for @labelEvent.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get labelEvent;

  /// No description provided for @labelNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get labelNote;

  /// No description provided for @labelRelation.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get labelRelation;

  /// No description provided for @labelSocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get labelSocial;
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

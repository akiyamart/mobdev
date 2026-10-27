// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Contacts';

  @override
  String get searchHint => 'Search by name';

  @override
  String get sortAscending => 'A-Z';

  @override
  String get sortDescending => 'Z-A';

  @override
  String foundCount(int count) {
    return 'Found: $count';
  }

  @override
  String get permissionDeniedTitle => 'No access to contacts';

  @override
  String get permissionDeniedBody =>
      'Allow the app to read contacts to show the address book. This is different from an empty book.';

  @override
  String get requestPermission => 'Request access';

  @override
  String get permissionBlockedTitle => 'Access is blocked';

  @override
  String get permissionBlockedBody =>
      'The system will not show the request again. Open the app settings and allow contacts.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get emptyBookTitle => 'Address book is empty';

  @override
  String get emptyBookBody =>
      'There are no contacts. Read access is already granted.';

  @override
  String get emptySearchTitle => 'Nothing found';

  @override
  String get emptySearchBody => 'No contacts with this name.';

  @override
  String get loading => 'Loading contacts';

  @override
  String get readErrorTitle => 'Could not read contacts';

  @override
  String get readErrorBody =>
      'Something went wrong while reading the address book.';

  @override
  String get retry => 'Retry';

  @override
  String get emailBadge => 'Email';

  @override
  String get unnamedContact => 'No name';

  @override
  String get phonesSection => 'Phones';

  @override
  String get emailsSection => 'Emails';

  @override
  String get extrasSection => 'Additional';

  @override
  String get noPhones => 'No phone number';

  @override
  String get noEmails => 'No email';

  @override
  String get labelMobile => 'Mobile';

  @override
  String get labelHome => 'Home';

  @override
  String get labelWork => 'Work';

  @override
  String get labelMain => 'Main';

  @override
  String get labelFax => 'Fax';

  @override
  String get labelPager => 'Pager';

  @override
  String get labelSchool => 'School';

  @override
  String get labelIphone => 'iPhone';

  @override
  String get labelOther => 'Other';

  @override
  String get labelCompany => 'Company';

  @override
  String get labelJobTitle => 'Job title';

  @override
  String get labelDepartment => 'Department';

  @override
  String get labelOffice => 'Office';

  @override
  String get labelJobDescription => 'Description';

  @override
  String get labelAddress => 'Address';

  @override
  String get labelWebsite => 'Website';

  @override
  String get labelBirthday => 'Birthday';

  @override
  String get labelAnniversary => 'Anniversary';

  @override
  String get labelEvent => 'Event';

  @override
  String get labelNote => 'Note';

  @override
  String get labelRelation => 'Relation';

  @override
  String get labelSocial => 'Social';
}

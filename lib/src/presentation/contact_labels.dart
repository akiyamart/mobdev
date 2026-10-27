import '../domain/address_contact.dart';
import '../domain/custom_label.dart';
import '../../l10n/app_localizations.dart';

String displayName(AppLocalizations l10n, AddressContact contact) {
  final name = contact.name.trim();
  if (name.isEmpty) return l10n.unnamedContact;
  return name;
}

String entryLabel(AppLocalizations l10n, ContactEntry entry) {
  final custom = normalizeCustomLabel(entry.customLabel);
  const preferCustom = {
    ContactLabelKind.custom,
    ContactLabelKind.other,
    ContactLabelKind.social,
    ContactLabelKind.relation,
  };
  if (custom != null && preferCustom.contains(entry.kind)) return custom;
  return switch (entry.kind) {
    ContactLabelKind.mobile => l10n.labelMobile,
    ContactLabelKind.home => l10n.labelHome,
    ContactLabelKind.work => l10n.labelWork,
    ContactLabelKind.main => l10n.labelMain,
    ContactLabelKind.fax => l10n.labelFax,
    ContactLabelKind.pager => l10n.labelPager,
    ContactLabelKind.school => l10n.labelSchool,
    ContactLabelKind.iphone => l10n.labelIphone,
    ContactLabelKind.other => l10n.labelOther,
    ContactLabelKind.custom => l10n.labelOther,
    ContactLabelKind.company => l10n.labelCompany,
    ContactLabelKind.jobTitle => l10n.labelJobTitle,
    ContactLabelKind.department => l10n.labelDepartment,
    ContactLabelKind.office => l10n.labelOffice,
    ContactLabelKind.jobDescription => l10n.labelJobDescription,
    ContactLabelKind.address => l10n.labelAddress,
    ContactLabelKind.website => l10n.labelWebsite,
    ContactLabelKind.birthday => l10n.labelBirthday,
    ContactLabelKind.anniversary => l10n.labelAnniversary,
    ContactLabelKind.event => l10n.labelEvent,
    ContactLabelKind.note => l10n.labelNote,
    ContactLabelKind.relation => l10n.labelRelation,
    ContactLabelKind.social => l10n.labelSocial,
  };
}

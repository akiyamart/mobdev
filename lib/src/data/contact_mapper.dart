import 'package:flutter_contacts/flutter_contacts.dart';

import '../domain/address_contact.dart';
import '../domain/custom_label.dart';

List<AddressContact> mapContacts(List<Contact> raw) {
  final seen = <String>{};
  final result = <AddressContact>[];
  for (var index = 0; index < raw.length; index++) {
    var contact = mapContact(raw[index], index: index);
    if (!seen.add(contact.id)) {
      contact = contact.copyWith(id: '${contact.id}-$index');
    }
    result.add(contact);
  }
  return result;
}

AddressContact mapContact(Contact contact, {required int index}) {
  final id = contact.id?.trim();
  return AddressContact(
    id: (id == null || id.isEmpty) ? 'missing-id-$index' : id,
    name: contact.displayName?.trim() ?? '',
    phones: _phones(contact.phones),
    emails: _emails(contact.emails),
    extras: [
      ..._organizations(contact.organizations),
      ..._addresses(contact.addresses),
      ..._websites(contact.websites),
      ..._events(contact.events),
      ..._relations(contact.relations),
      ..._socials(contact.socialMedias),
      ..._notes(contact.notes),
    ],
  );
}

List<ContactEntry> _phones(List<Phone> phones) {
  final entries = <ContactEntry>[];
  for (final phone in phones) {
    final number = phone.number.trim();
    if (number.isEmpty) continue;
    entries.add(
      ContactEntry(
        value: number,
        kind: _phoneKind(phone.label.label),
        customLabel: normalizeCustomLabel(phone.label.customLabel),
        isPrimary: phone.isPrimary ?? false,
      ),
    );
  }
  entries.sort((a, b) {
    if (a.isPrimary == b.isPrimary) return 0;
    return a.isPrimary ? -1 : 1;
  });
  return entries;
}

List<ContactEntry> _emails(List<Email> emails) {
  final entries = <ContactEntry>[];
  for (final email in emails) {
    final address = email.address.trim();
    if (address.isEmpty) continue;
    final kind = _emailKind(email.label.label);
    entries.add(
      ContactEntry(
        value: address,
        kind: kind,
        customLabel: kind == ContactLabelKind.custom
            ? normalizeCustomLabel(email.label.customLabel) ??
                  (email.label.label == EmailLabel.iCloud ? 'iCloud' : null)
            : normalizeCustomLabel(email.label.customLabel),
        isPrimary: email.isPrimary ?? false,
      ),
    );
  }
  entries.sort((a, b) {
    if (a.isPrimary == b.isPrimary) return 0;
    return a.isPrimary ? -1 : 1;
  });
  return entries;
}

List<ContactEntry> _organizations(List<Organization> organizations) {
  final entries = <ContactEntry>[];
  for (final organization in organizations) {
    _addText(entries, organization.name, ContactLabelKind.company);
    _addText(entries, organization.jobTitle, ContactLabelKind.jobTitle);
    _addText(entries, organization.departmentName, ContactLabelKind.department);
    _addText(entries, organization.officeLocation, ContactLabelKind.office);
    _addText(
      entries,
      organization.jobDescription,
      ContactLabelKind.jobDescription,
    );
  }
  return entries;
}

List<ContactEntry> _addresses(List<Address> addresses) {
  final entries = <ContactEntry>[];
  for (final address in addresses) {
    final value = _addressValue(address);
    if (value == null) continue;
    entries.add(
      ContactEntry(
        value: value,
        kind: _addressKind(address.label.label),
        customLabel: normalizeCustomLabel(address.label.customLabel),
      ),
    );
  }
  return entries;
}

List<ContactEntry> _websites(List<Website> websites) {
  final entries = <ContactEntry>[];
  for (final website in websites) {
    final url = website.url.trim();
    if (url.isEmpty) continue;
    entries.add(
      ContactEntry(
        value: url,
        kind: website.label.label == WebsiteLabel.custom
            ? ContactLabelKind.custom
            : ContactLabelKind.website,
        customLabel: normalizeCustomLabel(website.label.customLabel),
      ),
    );
  }
  return entries;
}

List<ContactEntry> _events(List<Event> events) {
  return [
    for (final event in events)
      ContactEntry(
        value: _eventValue(event),
        kind: _eventKind(event.label.label),
        customLabel: normalizeCustomLabel(event.label.customLabel),
      ),
  ];
}

List<ContactEntry> _relations(List<Relation> relations) {
  final entries = <ContactEntry>[];
  for (final relation in relations) {
    final name = relation.name.trim();
    if (name.isEmpty) continue;
    entries.add(
      ContactEntry(
        value: name,
        kind: relation.label.label == RelationLabel.custom
            ? ContactLabelKind.custom
            : ContactLabelKind.relation,
        customLabel: normalizeCustomLabel(relation.label.customLabel),
      ),
    );
  }
  return entries;
}

List<ContactEntry> _socials(List<SocialMedia> socials) {
  final entries = <ContactEntry>[];
  for (final social in socials) {
    final username = social.username.trim();
    if (username.isEmpty) continue;
    entries.add(
      ContactEntry(
        value: username,
        kind: social.label.label == SocialMediaLabel.custom
            ? ContactLabelKind.custom
            : ContactLabelKind.social,
        customLabel: normalizeCustomLabel(social.label.customLabel),
      ),
    );
  }
  return entries;
}

List<ContactEntry> _notes(List<Note> notes) {
  final entries = <ContactEntry>[];
  for (final note in notes) {
    _addText(entries, note.note, ContactLabelKind.note);
  }
  return entries;
}

void _addText(List<ContactEntry> entries, String? raw, ContactLabelKind kind) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return;
  entries.add(ContactEntry(value: value, kind: kind));
}

String? _addressValue(Address address) {
  final formatted = address.formatted?.trim() ?? '';
  if (formatted.isNotEmpty) return formatted;
  final parts =
      [
            address.street,
            address.city,
            address.state,
            address.postalCode,
            address.country,
            address.poBox,
            address.neighborhood,
          ]
          .whereType<String>()
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty);
  if (parts.isEmpty) return null;
  return parts.join(', ');
}

String _eventValue(Event event) {
  final day = event.day.toString().padLeft(2, '0');
  final month = event.month.toString().padLeft(2, '0');
  if (event.year == null) return '$day.$month';
  return '$day.$month.${event.year}';
}

ContactLabelKind _phoneKind(PhoneLabel label) {
  switch (label) {
    case PhoneLabel.mobile:
    case PhoneLabel.workMobile:
      return ContactLabelKind.mobile;
    case PhoneLabel.home:
      return ContactLabelKind.home;
    case PhoneLabel.work:
      return ContactLabelKind.work;
    case PhoneLabel.main:
    case PhoneLabel.companyMain:
      return ContactLabelKind.main;
    case PhoneLabel.homeFax:
    case PhoneLabel.workFax:
    case PhoneLabel.otherFax:
      return ContactLabelKind.fax;
    case PhoneLabel.pager:
    case PhoneLabel.workPager:
      return ContactLabelKind.pager;
    case PhoneLabel.school:
      return ContactLabelKind.school;
    case PhoneLabel.iPhone:
      return ContactLabelKind.iphone;
    case PhoneLabel.custom:
      return ContactLabelKind.custom;
    case PhoneLabel.appleWatch:
    case PhoneLabel.assistant:
    case PhoneLabel.callback:
    case PhoneLabel.car:
    case PhoneLabel.isdn:
    case PhoneLabel.mms:
    case PhoneLabel.other:
    case PhoneLabel.radio:
    case PhoneLabel.telex:
    case PhoneLabel.ttyTdd:
      return ContactLabelKind.other;
  }
}

ContactLabelKind _emailKind(EmailLabel label) {
  switch (label) {
    case EmailLabel.home:
      return ContactLabelKind.home;
    case EmailLabel.work:
      return ContactLabelKind.work;
    case EmailLabel.mobile:
      return ContactLabelKind.mobile;
    case EmailLabel.school:
      return ContactLabelKind.school;
    case EmailLabel.iCloud:
    case EmailLabel.custom:
      return ContactLabelKind.custom;
    case EmailLabel.other:
      return ContactLabelKind.other;
  }
}

ContactLabelKind _addressKind(AddressLabel label) {
  switch (label) {
    case AddressLabel.home:
      return ContactLabelKind.home;
    case AddressLabel.work:
      return ContactLabelKind.work;
    case AddressLabel.school:
      return ContactLabelKind.school;
    case AddressLabel.custom:
      return ContactLabelKind.custom;
    case AddressLabel.other:
      return ContactLabelKind.address;
  }
}

ContactLabelKind _eventKind(EventLabel label) {
  switch (label) {
    case EventLabel.birthday:
      return ContactLabelKind.birthday;
    case EventLabel.anniversary:
      return ContactLabelKind.anniversary;
    case EventLabel.custom:
      return ContactLabelKind.custom;
    case EventLabel.other:
      return ContactLabelKind.event;
  }
}

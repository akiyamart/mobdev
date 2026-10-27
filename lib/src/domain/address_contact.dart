enum ContactLabelKind {
  mobile,
  home,
  work,
  main,
  fax,
  pager,
  school,
  iphone,
  other,
  custom,
  company,
  jobTitle,
  department,
  office,
  jobDescription,
  address,
  website,
  birthday,
  anniversary,
  event,
  note,
  relation,
  social,
}

class ContactEntry {
  const ContactEntry({
    required this.value,
    required this.kind,
    this.customLabel,
    this.isPrimary = false,
  });

  final String value;
  final ContactLabelKind kind;
  final String? customLabel;
  final bool isPrimary;
}

class AddressContact {
  const AddressContact({
    required this.id,
    required this.name,
    this.phones = const [],
    this.emails = const [],
    this.extras = const [],
  });

  final String id;
  final String name;
  final List<ContactEntry> phones;
  final List<ContactEntry> emails;
  final List<ContactEntry> extras;

  bool get hasEmail => emails.any((email) => email.value.trim().isNotEmpty);

  String? get primaryPhone {
    for (final phone in phones) {
      if (phone.isPrimary && phone.value.trim().isNotEmpty) {
        return phone.value.trim();
      }
    }
    for (final phone in phones) {
      final value = phone.value.trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  AddressContact copyWith({String? id}) {
    return AddressContact(
      id: id ?? this.id,
      name: name,
      phones: phones,
      emails: emails,
      extras: extras,
    );
  }
}

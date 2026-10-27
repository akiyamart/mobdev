import 'package:device_contacts/src/data/contact_mapper.dart';
import 'package:device_contacts/src/domain/address_contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('контакт собирается с основным номером, почтой и доп. полями', () {
    final mapped = mapContact(
      Contact(
        id: '1',
        displayName: 'Анна',
        phones: [
          Phone(number: '111', label: const Label(PhoneLabel.home)),
          Phone(number: '  ', label: const Label(PhoneLabel.mobile)),
          Phone(
            number: '222',
            isPrimary: true,
            label: Label(PhoneLabel.custom, r'_$!<Emergency>!$_'),
          ),
        ],
        emails: [
          Email(
            address: 'anna@example.com',
            label: const Label(EmailLabel.work),
          ),
        ],
        organizations: [Organization(name: 'БГУ', jobTitle: 'Студент')],
        addresses: [
          Address(
            street: 'Ленина',
            city: 'Минск',
            label: const Label(AddressLabel.home),
          ),
        ],
        websites: [Website(url: 'https://example.com')],
        events: [
          Event(
            year: 2000,
            month: 5,
            day: 9,
            label: const Label(EventLabel.birthday),
          ),
        ],
        notes: [Note(note: 'друг')],
        relations: [
          Relation(
            name: 'Иван',
            label: const Label(RelationLabel.custom, 'брат'),
          ),
        ],
        socialMedias: [
          SocialMedia(
            username: 'anna',
            label: const Label(SocialMediaLabel.custom, 'Telegram'),
          ),
        ],
      ),
      index: 0,
    );

    expect(mapped.primaryPhone, '222');
    expect(mapped.hasEmail, isTrue);
    expect(
      mapped.phones.singleWhere((phone) => phone.value == '222').kind,
      ContactLabelKind.custom,
    );
    expect(
      mapped.phones.singleWhere((phone) => phone.value == '222').customLabel,
      'Emergency',
    );
    expect(mapped.phones.map((phone) => phone.value), isNot(contains('')));
    expect(mapped.extras.map((entry) => entry.value), [
      'БГУ',
      'Студент',
      'Ленина, Минск',
      'https://example.com',
      '09.05.2000',
      'Иван',
      'anna',
      'друг',
    ]);
  });

  test('пустой идентификатор не ломает список', () {
    final mapped = mapContacts([
      Contact(displayName: 'Без id'),
      Contact(displayName: 'Тоже'),
    ]);

    expect(mapped.map((contact) => contact.id).toSet(), hasLength(2));
    expect(mapped.first.name, 'Без id');
  });
}

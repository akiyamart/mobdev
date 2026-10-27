import 'package:device_contacts/src/domain/address_contact.dart';
import 'package:device_contacts/src/domain/contact_view.dart';
import 'package:device_contacts/src/domain/custom_label.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_contacts_gateway.dart';

void main() {
  test('поиск идёт по имени и не меняет исходный список', () {
    final source = [
      person(
        '2',
        'Борис',
        phones: const [
          ContactEntry(value: 'Анна', kind: ContactLabelKind.mobile),
        ],
      ),
      person('1', 'Анна'),
      person('3', 'анна петрова'),
    ];

    final found = applyContactView(
      source,
      query: '  АН  ',
      sort: NameSort.ascending,
    );

    expect(found.map((contact) => contact.id), ['1', '3']);
    expect(source.map((contact) => contact.id), ['2', '1', '3']);
  });

  test('сортировка по имени в обе стороны, пустые имена в конце', () {
    final source = [
      person('y', 'Яков'),
      person('empty', ''),
      person('a', 'Анна'),
      person('b', 'Борис'),
    ];

    expect(
      applyContactView(
        source,
        query: '',
        sort: NameSort.ascending,
      ).map((contact) => contact.id),
      ['a', 'b', 'y', 'empty'],
    );
    expect(
      applyContactView(
        source,
        query: '',
        sort: NameSort.descending,
      ).map((contact) => contact.id),
      ['y', 'b', 'a', 'empty'],
    );
  });

  test('пустой поиск возвращает всех, номер телефона не участвует', () {
    final source = [
      person(
        '1',
        'Анна',
        phones: const [
          ContactEntry(value: '111', kind: ContactLabelKind.mobile),
        ],
      ),
    ];

    expect(
      applyContactView(source, query: '   ', sort: NameSort.ascending),
      hasLength(1),
    );
    expect(
      applyContactView(source, query: '111', sort: NameSort.ascending),
      isEmpty,
    );
  });

  test('служебная метка Apple превращается в обычный текст', () {
    expect(normalizeCustomLabel(r'_$!<Emergency>!$_'), 'Emergency');
    expect(normalizeCustomLabel('  Дом  '), 'Дом');
    expect(normalizeCustomLabel('   '), isNull);
  });
}

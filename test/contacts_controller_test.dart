import 'package:device_contacts/src/data/contacts_gateway.dart';
import 'package:device_contacts/src/domain/contact_view.dart';
import 'package:device_contacts/src/presentation/contacts_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_contacts_gateway.dart';

void main() {
  test('разрешение уже есть: книга читается один раз', () async {
    final gateway = FakeContactsGateway(contacts: [person('1', 'Анна')]);
    final controller = ContactsController(gateway);

    await controller.start();

    expect(controller.status, ContactsViewStatus.ready);
    expect(controller.foundCount, 1);
    expect(gateway.requestCount, 0);
    expect(gateway.loadCount, 1);

    controller.setQuery('нет такого');
    controller.setQuery('ан');
    controller.setSort(NameSort.descending);
    await controller.onAppResumed();

    expect(controller.visibleContacts.single.id, '1');
    expect(gateway.loadCount, 1);
    controller.dispose();
  });

  test(
    'отказ можно запросить снова, вечный запрет ведёт в настройки',
    () async {
      final denied = FakeContactsGateway(
        access: ContactsAccess.denied,
        requestResult: ContactsAccess.denied,
      );
      final deniedController = ContactsController(denied);
      await deniedController.start();
      expect(deniedController.status, ContactsViewStatus.denied);
      expect(denied.requestCount, 1);
      expect(denied.loadCount, 0);

      denied.requestResult = ContactsAccess.granted;
      denied.contacts = [person('1', 'Борис')];
      await deniedController.requestAccess();
      expect(deniedController.status, ContactsViewStatus.ready);
      expect(denied.loadCount, 1);
      deniedController.dispose();

      final blocked = FakeContactsGateway(access: ContactsAccess.blocked);
      final blockedController = ContactsController(blocked);
      await blockedController.start();
      expect(blockedController.status, ContactsViewStatus.needsSettings);
      expect(blocked.requestCount, 0);
      await blockedController.openSettings();
      expect(blocked.settingsCount, 1);

      blocked.access = ContactsAccess.granted;
      blocked.contacts = [person('1', 'Анна')];
      await blockedController.onAppResumed();
      expect(blockedController.contacts.single.name, 'Анна');
      expect(blocked.loadCount, 1);

      await blockedController.onAppResumed();
      expect(blocked.loadCount, 1);
      blockedController.dispose();
    },
  );

  test(
    'повторный запрос, который система уже не показывает, открывает настройки',
    () async {
      final gateway = FakeContactsGateway(
        access: ContactsAccess.denied,
        requestResult: ContactsAccess.blocked,
      );
      final controller = ContactsController(gateway);

      await controller.start();

      expect(controller.status, ContactsViewStatus.needsSettings);
      expect(gateway.requestCount, 1);
      expect(gateway.loadCount, 0);
      controller.dispose();
    },
  );

  test('пустая книга не путается с отказом и с ошибкой чтения', () async {
    final empty = ContactsController(FakeContactsGateway());
    await empty.start();
    expect(empty.status, ContactsViewStatus.ready);
    expect(empty.contacts, isEmpty);
    empty.dispose();

    final failing = FakeContactsGateway(loadError: StateError('boom'));
    final failed = ContactsController(failing);
    await failed.start();
    expect(failed.status, ContactsViewStatus.failure);

    failing.loadError = null;
    failing.contacts = [person('1', 'Анна')];
    await failed.retry();
    expect(failed.status, ContactsViewStatus.ready);
    expect(failed.contacts.single.name, 'Анна');
    failed.dispose();
  });

  test('отзыв разрешения очищает список и не читает книгу', () async {
    final gateway = FakeContactsGateway(contacts: [person('1', 'Анна')]);
    final controller = ContactsController(gateway);
    await controller.start();

    gateway.access = ContactsAccess.denied;
    await controller.onAppResumed();

    expect(controller.status, ContactsViewStatus.denied);
    expect(controller.contacts, isEmpty);
    expect(gateway.loadCount, 1);
    controller.dispose();
  });

  test('сбой проверки разрешения не роняет контроллер', () async {
    final gateway = FakeContactsGateway(failCheck: true);
    final controller = ContactsController(gateway);

    await controller.start();

    expect(controller.status, ContactsViewStatus.failure);
    controller.dispose();
  });
}

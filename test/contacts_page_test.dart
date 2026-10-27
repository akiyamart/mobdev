import 'package:device_contacts/l10n/app_localizations.dart';
import 'package:device_contacts/src/data/contacts_gateway.dart';
import 'package:device_contacts/src/domain/address_contact.dart';
import 'package:device_contacts/src/domain/contact_view.dart';
import 'package:device_contacts/src/presentation/contacts_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_contacts_gateway.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('ru'));

  Future<void> pumpApp(WidgetTester tester, ContactsGateway gateway) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    await tester.pumpWidget(
      ContactsApp(
        key: ObjectKey(gateway),
        gateway: gateway,
        locale: const Locale('ru'),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> resume(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  }

  testWidgets('отказ, повторный запрос и выдача разрешения', (tester) async {
    final gateway = FakeContactsGateway(
      access: ContactsAccess.denied,
      requestResult: ContactsAccess.denied,
    );

    await pumpApp(tester, gateway);

    expect(find.byKey(const Key('state-denied')), findsOneWidget);
    expect(find.text(l10n.requestPermission), findsOneWidget);
    expect(find.byKey(const Key('state-empty-book')), findsNothing);
    expect(gateway.requestCount, 1);
    expect(gateway.loadCount, 0);

    gateway.requestResult = ContactsAccess.granted;
    gateway.contacts = [
      person(
        '1',
        'Борис',
        phones: const [
          ContactEntry(
            value: '555',
            kind: ContactLabelKind.mobile,
            isPrimary: true,
          ),
        ],
      ),
    ];
    await tester.tap(find.byKey(const Key('request-access')));
    await tester.pumpAndSettle();

    expect(find.text('Борис'), findsOneWidget);
    expect(find.text('555'), findsOneWidget);
    expect(gateway.loadCount, 1);
  });

  testWidgets(
    'вечный запрет предлагает настройки и читает книгу после возврата',
    (tester) async {
      final gateway = FakeContactsGateway(access: ContactsAccess.blocked);

      await pumpApp(tester, gateway);

      expect(find.byKey(const Key('state-blocked')), findsOneWidget);
      expect(gateway.requestCount, 0);
      await tester.tap(find.byKey(const Key('open-settings')));
      await tester.pump();
      expect(gateway.settingsCount, 1);

      gateway.access = ContactsAccess.granted;
      gateway.contacts = [person('1', 'Анна')];
      await resume(tester);

      expect(find.text('Анна'), findsOneWidget);
      expect(gateway.loadCount, 1);

      await resume(tester);
      expect(gateway.loadCount, 1);
    },
  );

  testWidgets('список, детали, поиск, обе сортировки и пустой результат', (
    tester,
  ) async {
    final gateway = FakeContactsGateway(
      contacts: [
        person(
          'b',
          'Борис',
          phones: const [
            ContactEntry(value: '111', kind: ContactLabelKind.home),
            ContactEntry(
              value: '222',
              kind: ContactLabelKind.mobile,
              isPrimary: true,
            ),
          ],
          emails: const [
            ContactEntry(
              value: 'boris@example.com',
              kind: ContactLabelKind.work,
            ),
          ],
          extras: const [
            ContactEntry(value: 'БГУ', kind: ContactLabelKind.company),
          ],
        ),
        person('a', 'Анна'),
        person('y', 'Яков'),
      ],
    );

    await pumpApp(tester, gateway);

    expect(find.text(l10n.foundCount(3)), findsOneWidget);
    expect(find.text('222'), findsOneWidget);
    expect(find.text('111'), findsNothing);
    expect(find.text(l10n.emailBadge), findsOneWidget);
    expect(
      tester.widget<ListView>(find.byType(ListView)).childrenDelegate,
      isA<SliverChildBuilderDelegate>(),
    );

    await tester.tap(find.text('Борис'));
    await tester.pumpAndSettle();
    expect(find.text('111'), findsOneWidget);
    expect(find.text('222'), findsOneWidget);
    expect(find.text('boris@example.com'), findsOneWidget);
    expect(find.text('БГУ'), findsOneWidget);
    expect(find.text(l10n.labelCompany), findsOneWidget);
    expect(gateway.loadCount, 1);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(gateway.loadCount, 1);

    await tester.enterText(find.byKey(const Key('search-field')), 'я');
    await tester.pump();
    expect(find.text('Яков'), findsOneWidget);
    expect(find.text('Анна'), findsNothing);
    expect(find.text(l10n.foundCount(1)), findsOneWidget);
    expect(gateway.loadCount, 1);

    await tester.enterText(find.byKey(const Key('search-field')), 'zzzz');
    await tester.pump();
    expect(find.byKey(const Key('state-empty-search')), findsOneWidget);
    expect(find.text(l10n.foundCount(0)), findsOneWidget);
    expect(gateway.loadCount, 1);

    await tester.enterText(find.byKey(const Key('search-field')), '');
    await tester.pump();
    await tester.tap(find.text(l10n.sortDescending));
    await tester.pump();
    expect(find.text('Яков'), findsWidgets);
    final names = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data)
        .where((text) => text == 'Анна' || text == 'Борис' || text == 'Яков')
        .toList();
    expect(names, ['Яков', 'Борис', 'Анна']);

    tester.view.physicalSize = const Size(900, 420);
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('search-field')))
          .controller
          ?.text,
      isEmpty,
    );
    expect(
      tester
          .widget<SegmentedButton<NameSort>>(
            find.byType(SegmentedButton<NameSort>),
          )
          .selected,
      {NameSort.descending},
    );
    expect(gateway.loadCount, 1);
  });

  testWidgets('поворот сохраняет введённый поиск и выбранную сортировку', (
    tester,
  ) async {
    final gateway = FakeContactsGateway(
      contacts: [person('a', 'Анна'), person('y', 'Яков')],
    );
    await pumpApp(tester, gateway);

    await tester.enterText(find.byKey(const Key('search-field')), 'ан');
    await tester.pump();
    await tester.tap(find.text(l10n.sortDescending));
    await tester.pump();

    tester.view.physicalSize = const Size(800, 360);
    await tester.pump();

    expect(
      tester
          .widget<TextField>(find.byKey(const Key('search-field')))
          .controller
          ?.text,
      'ан',
    );
    expect(
      tester
          .widget<SegmentedButton<NameSort>>(
            find.byType(SegmentedButton<NameSort>),
          )
          .selected,
      {NameSort.descending},
    );
    expect(find.text('Анна'), findsOneWidget);
    expect(find.text('Яков'), findsNothing);
    expect(gateway.loadCount, 1);
  });

  testWidgets('пустая книга, контакт без телефона и почты, ошибка чтения', (
    tester,
  ) async {
    final empty = FakeContactsGateway();
    await pumpApp(tester, empty);
    expect(find.byKey(const Key('state-empty-book')), findsOneWidget);
    expect(find.byKey(const Key('state-denied')), findsNothing);
    expect(find.text(l10n.foundCount(0)), findsOneWidget);

    final sparse = FakeContactsGateway(
      contacts: [person('1', ''), person('2', 'Вера')],
    );
    await pumpApp(tester, sparse);
    expect(find.text(l10n.unnamedContact), findsOneWidget);
    await tester.tap(find.text(l10n.unnamedContact));
    await tester.pumpAndSettle();
    expect(find.text(l10n.noPhones), findsOneWidget);
    expect(find.text(l10n.noEmails), findsOneWidget);
    expect(sparse.loadCount, 1);

    final failing = FakeContactsGateway(loadError: StateError('boom'));
    await pumpApp(tester, failing);
    expect(find.byKey(const Key('state-failure')), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);
    failing.loadError = null;
    failing.contacts = [person('1', 'Галина')];
    await tester.tap(find.byKey(const Key('retry-load')));
    await tester.pumpAndSettle();
    expect(find.text('Галина'), findsOneWidget);
  });

  testWidgets(
    'длинный список строится лениво и не залезает под системные зоны',
    (tester) async {
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(
        top: 24,
        left: 40,
        right: 40,
        bottom: 16,
      );
      tester.view.viewPadding = const FakeViewPadding(
        top: 24,
        left: 40,
        right: 40,
        bottom: 16,
      );
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);

      final contacts = [
        for (var index = 0; index < 40; index++)
          person(
            'c${index.toString().padLeft(2, '0')}',
            'Имя ${index.toString().padLeft(2, '0')}',
          ),
      ];
      await tester.pumpWidget(
        ContactsApp(
          gateway: FakeContactsGateway(contacts: contacts),
          locale: const Locale('ru'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('c00')), findsOneWidget);
      expect(find.byKey(const ValueKey('c39')), findsNothing);
      expect(
        tester
            .widget<ListView>(find.byKey(const Key('contact-list')))
            .childrenDelegate,
        isA<SliverChildBuilderDelegate>(),
      );
      expect(
        tester.getTopLeft(find.text(l10n.appTitle)).dx,
        greaterThanOrEqualTo(40),
      );
      expect(
        tester.getTopLeft(find.text(l10n.appTitle)).dy,
        greaterThanOrEqualTo(24),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('search-field'))).dx,
        greaterThanOrEqualTo(40),
      );
      expect(
        tester.getBottomLeft(find.byKey(const Key('contact-list'))).dy,
        lessThanOrEqualTo(400 - 16),
      );
    },
  );
}

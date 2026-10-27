// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Контакты';

  @override
  String get searchHint => 'Поиск по имени';

  @override
  String get sortAscending => 'А-Я';

  @override
  String get sortDescending => 'Я-А';

  @override
  String foundCount(int count) {
    return 'Найдено: $count';
  }

  @override
  String get permissionDeniedTitle => 'Нет доступа к контактам';

  @override
  String get permissionDeniedBody =>
      'Разрешите чтение контактов, чтобы показать адресную книгу. Это не то же самое, что пустая книга.';

  @override
  String get requestPermission => 'Запросить доступ';

  @override
  String get permissionBlockedTitle => 'Доступ запрещён';

  @override
  String get permissionBlockedBody =>
      'Система больше не показывает запрос. Откройте настройки приложения и разрешите контакты.';

  @override
  String get openSettings => 'Открыть настройки';

  @override
  String get emptyBookTitle => 'Адресная книга пуста';

  @override
  String get emptyBookBody => 'Контактов нет. Разрешение на чтение уже есть.';

  @override
  String get emptySearchTitle => 'Ничего не найдено';

  @override
  String get emptySearchBody => 'Нет контактов с таким именем.';

  @override
  String get loading => 'Загрузка контактов';

  @override
  String get readErrorTitle => 'Не удалось прочитать контакты';

  @override
  String get readErrorBody => 'Произошла ошибка при чтении адресной книги.';

  @override
  String get retry => 'Повторить';

  @override
  String get emailBadge => 'Email';

  @override
  String get unnamedContact => 'Без имени';

  @override
  String get phonesSection => 'Телефоны';

  @override
  String get emailsSection => 'Почта';

  @override
  String get extrasSection => 'Дополнительно';

  @override
  String get noPhones => 'Нет номера телефона';

  @override
  String get noEmails => 'Нет email';

  @override
  String get labelMobile => 'Мобильный';

  @override
  String get labelHome => 'Домашний';

  @override
  String get labelWork => 'Рабочий';

  @override
  String get labelMain => 'Основной';

  @override
  String get labelFax => 'Факс';

  @override
  String get labelPager => 'Пейджер';

  @override
  String get labelSchool => 'Школа';

  @override
  String get labelIphone => 'iPhone';

  @override
  String get labelOther => 'Другое';

  @override
  String get labelCompany => 'Компания';

  @override
  String get labelJobTitle => 'Должность';

  @override
  String get labelDepartment => 'Отдел';

  @override
  String get labelOffice => 'Офис';

  @override
  String get labelJobDescription => 'Описание';

  @override
  String get labelAddress => 'Адрес';

  @override
  String get labelWebsite => 'Сайт';

  @override
  String get labelBirthday => 'День рождения';

  @override
  String get labelAnniversary => 'Годовщина';

  @override
  String get labelEvent => 'Событие';

  @override
  String get labelNote => 'Заметка';

  @override
  String get labelRelation => 'Связь';

  @override
  String get labelSocial => 'Соцсеть';
}

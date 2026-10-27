import 'package:device_contacts/src/data/contacts_gateway.dart';
import 'package:device_contacts/src/domain/address_contact.dart';

class FakeContactsGateway implements ContactsGateway {
  FakeContactsGateway({
    this.access = ContactsAccess.granted,
    this.requestResult,
    this.contacts = const [],
    this.loadError,
    this.failCheck = false,
  });

  ContactsAccess access;
  ContactsAccess? requestResult;
  List<AddressContact> contacts;
  Object? loadError;
  bool failCheck;
  int loadCount = 0;
  int requestCount = 0;
  int settingsCount = 0;
  int checkCount = 0;

  @override
  Future<ContactsAccess> checkAccess() async {
    checkCount++;
    if (failCheck) throw StateError('check failed');
    return access;
  }

  @override
  Future<ContactsAccess> requestAccess() async {
    requestCount++;
    final result = requestResult ?? access;
    access = result;
    return result;
  }

  @override
  Future<void> openAppSettings() async {
    settingsCount++;
  }

  @override
  Future<List<AddressContact>> loadContacts() async {
    loadCount++;
    if (loadError != null) throw loadError!;
    return contacts;
  }
}

AddressContact person(
  String id,
  String name, {
  List<ContactEntry> phones = const [],
  List<ContactEntry> emails = const [],
  List<ContactEntry> extras = const [],
}) {
  return AddressContact(
    id: id,
    name: name,
    phones: phones,
    emails: emails,
    extras: extras,
  );
}

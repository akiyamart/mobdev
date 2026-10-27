import '../domain/address_contact.dart';

enum ContactsAccess { granted, denied, blocked }

abstract interface class ContactsGateway {
  Future<ContactsAccess> checkAccess();

  Future<ContactsAccess> requestAccess();

  Future<void> openAppSettings();

  Future<List<AddressContact>> loadContacts();
}

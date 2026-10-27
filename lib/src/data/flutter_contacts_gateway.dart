import 'package:flutter_contacts/flutter_contacts.dart';

import '../domain/address_contact.dart';
import 'contact_mapper.dart';
import 'contacts_gateway.dart';

class FlutterContactsGateway implements ContactsGateway {
  static const _properties = ContactProperties.allProperties;

  @override
  Future<ContactsAccess> checkAccess() async {
    final status = await FlutterContacts.permissions.check(PermissionType.read);
    return _mapStatus(status);
  }

  @override
  Future<ContactsAccess> requestAccess() async {
    final status = await FlutterContacts.permissions.request(
      PermissionType.read,
    );
    return _mapStatus(status);
  }

  @override
  Future<void> openAppSettings() {
    return FlutterContacts.permissions.openSettings();
  }

  @override
  Future<List<AddressContact>> loadContacts() async {
    final contacts = await FlutterContacts.getAll(properties: _properties);
    return mapContacts(contacts);
  }

  ContactsAccess _mapStatus(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
        return ContactsAccess.granted;
      case PermissionStatus.permanentlyDenied:
      case PermissionStatus.restricted:
        return ContactsAccess.blocked;
      case PermissionStatus.denied:
      case PermissionStatus.notDetermined:
        return ContactsAccess.denied;
    }
  }
}

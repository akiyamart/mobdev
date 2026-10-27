import 'package:flutter/foundation.dart';

import '../data/contacts_gateway.dart';
import '../domain/address_contact.dart';
import '../domain/contact_view.dart';

enum ContactsViewStatus { loading, denied, needsSettings, ready, failure }

class ContactsController extends ChangeNotifier {
  ContactsController(this._gateway);

  final ContactsGateway _gateway;

  ContactsViewStatus status = ContactsViewStatus.loading;
  NameSort sort = NameSort.ascending;
  String query = '';

  List<AddressContact> _contacts = const [];
  bool _loaded = false;
  bool _loading = false;
  bool _requesting = false;
  bool _started = false;
  bool _disposed = false;

  List<AddressContact> get contacts => _contacts;

  bool get isLoaded => _loaded;

  List<AddressContact> get visibleContacts =>
      applyContactView(_contacts, query: query, sort: sort);

  int get foundCount => visibleContacts.length;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _openInitialAccess();
  }

  Future<void> requestAccess() => _askAndApply();

  Future<void> openSettings() async {
    try {
      await _gateway.openAppSettings();
    } catch (_) {
      _fail();
    }
  }

  Future<void> retry() async {
    try {
      final access = await _gateway.checkAccess();
      if (_disposed) return;
      if (access != ContactsAccess.granted) {
        _clearFor(access);
        return;
      }
      await _load();
    } catch (_) {
      _fail();
    }
  }

  /// Checks permission after the app returns to the foreground.
  /// An unchanged grant does not read the address book again.
  Future<void> onAppResumed() async {
    if (_disposed || _loading || _requesting) return;
    try {
      final access = await _gateway.checkAccess();
      if (_disposed) return;
      if (access == ContactsAccess.granted) {
        if (!_loaded) await _load();
        return;
      }
      _clearFor(access);
    } catch (_) {
      _fail();
    }
  }

  void setQuery(String value) {
    if (value == query) return;
    query = value;
    _notify();
  }

  void setSort(NameSort value) {
    if (value == sort) return;
    sort = value;
    _notify();
  }

  Future<void> _openInitialAccess() async {
    try {
      final access = await _gateway.checkAccess();
      if (_disposed) return;
      if (access == ContactsAccess.granted) {
        await _load();
        return;
      }
      if (access == ContactsAccess.blocked) {
        _clearFor(access);
        return;
      }
      await _askAndApply();
    } catch (_) {
      _fail();
    }
  }

  Future<void> _askAndApply() async {
    if (_requesting) return;
    _requesting = true;
    try {
      final access = await _gateway.requestAccess();
      if (_disposed) return;
      if (access == ContactsAccess.granted) {
        await _load();
        return;
      }
      _clearFor(access);
    } catch (_) {
      _fail();
    } finally {
      _requesting = false;
    }
  }

  Future<void> _load() async {
    if (_loading) return;
    _loading = true;
    status = ContactsViewStatus.loading;
    _notify();
    try {
      final loaded = await _gateway.loadContacts();
      if (_disposed) return;
      _contacts = List.unmodifiable(loaded);
      _loaded = true;
      status = ContactsViewStatus.ready;
    } catch (_) {
      if (_disposed) return;
      _contacts = const [];
      _loaded = false;
      status = ContactsViewStatus.failure;
    } finally {
      _loading = false;
      _notify();
    }
  }

  void _clearFor(ContactsAccess access) {
    final next = access == ContactsAccess.blocked
        ? ContactsViewStatus.needsSettings
        : ContactsViewStatus.denied;
    final changed = status != next || _loaded || _contacts.isNotEmpty;
    _loaded = false;
    _contacts = const [];
    status = next;
    if (changed) _notify();
  }

  void _fail() {
    if (_disposed) return;
    _loaded = false;
    status = ContactsViewStatus.failure;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

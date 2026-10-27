import 'package:flutter/material.dart';

import 'src/data/flutter_contacts_gateway.dart';
import 'src/presentation/contacts_app.dart';

void main() {
  runApp(ContactsApp(gateway: FlutterContactsGateway()));
}

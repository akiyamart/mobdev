import 'package:flutter/material.dart';

import '../domain/address_contact.dart';
import '../../l10n/app_localizations.dart';
import 'contact_labels.dart';

class ContactDetailsPage extends StatelessWidget {
  const ContactDetailsPage({super.key, required this.contact});

  final AddressContact contact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(displayName(l10n, contact))),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _Section(
              title: l10n.phonesSection,
              emptyText: l10n.noPhones,
              entries: contact.phones,
            ),
            _Section(
              title: l10n.emailsSection,
              emptyText: l10n.noEmails,
              entries: contact.emails,
            ),
            if (contact.extras.isNotEmpty)
              _Section(title: l10n.extrasSection, entries: contact.extras),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.entries, this.emptyText});

  final String title;
  final List<ContactEntry> entries;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(title, style: theme.textTheme.titleMedium),
        ),
        if (entries.isEmpty && emptyText != null)
          ListTile(title: Text(emptyText!))
        else
          for (final entry in entries)
            ListTile(
              title: Text(entry.value),
              subtitle: Text(entryLabel(l10n, entry)),
            ),
      ],
    );
  }
}

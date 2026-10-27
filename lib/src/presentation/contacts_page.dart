import 'package:flutter/material.dart';

import '../domain/address_contact.dart';
import '../domain/contact_view.dart';
import '../../l10n/app_localizations.dart';
import 'contact_details_page.dart';
import 'contact_labels.dart';
import 'contacts_controller.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key, required this.controller});

  final ContactsController controller;

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage>
    with WidgetsBindingObserver {
  late final TextEditingController _search = TextEditingController(
    text: widget.controller.query,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _search.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.controller.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.appTitle)),
        body: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.controller.status == ContactsViewStatus.ready) ...[
                  _SearchField(
                    controller: _search,
                    onChanged: widget.controller.setQuery,
                  ),
                  _SortBar(
                    sort: widget.controller.sort,
                    onChanged: widget.controller.setSort,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      l10n.foundCount(widget.controller.foundCount),
                      key: const Key('found-count'),
                    ),
                  ),
                ],
                Expanded(child: _ContactsBody(controller: widget.controller)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        key: const Key('search-field'),
        controller: controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _SortBar extends StatelessWidget {
  const _SortBar({required this.sort, required this.onChanged});

  final NameSort sort;
  final ValueChanged<NameSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SegmentedButton<NameSort>(
        key: const Key('sort-control'),
        showSelectedIcon: false,
        segments: [
          ButtonSegment<NameSort>(
            value: NameSort.ascending,
            label: Text(l10n.sortAscending),
          ),
          ButtonSegment<NameSort>(
            value: NameSort.descending,
            label: Text(l10n.sortDescending),
          ),
        ],
        selected: {sort},
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }
}

class _ContactsBody extends StatelessWidget {
  const _ContactsBody({required this.controller});

  final ContactsController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (controller.status) {
      case ContactsViewStatus.loading:
        return const _StatusMessage(
          messageKey: Key('state-loading'),
          showProgress: true,
        );
      case ContactsViewStatus.denied:
        return _StatusMessage(
          messageKey: const Key('state-denied'),
          title: l10n.permissionDeniedTitle,
          body: l10n.permissionDeniedBody,
          actionKey: const Key('request-access'),
          actionLabel: l10n.requestPermission,
          onAction: controller.requestAccess,
        );
      case ContactsViewStatus.needsSettings:
        return _StatusMessage(
          messageKey: const Key('state-blocked'),
          title: l10n.permissionBlockedTitle,
          body: l10n.permissionBlockedBody,
          actionKey: const Key('open-settings'),
          actionLabel: l10n.openSettings,
          onAction: controller.openSettings,
        );
      case ContactsViewStatus.failure:
        return _StatusMessage(
          messageKey: const Key('state-failure'),
          title: l10n.readErrorTitle,
          body: l10n.readErrorBody,
          actionKey: const Key('retry-load'),
          actionLabel: l10n.retry,
          onAction: controller.retry,
        );
      case ContactsViewStatus.ready:
        if (controller.contacts.isEmpty) {
          return _StatusMessage(
            messageKey: const Key('state-empty-book'),
            title: l10n.emptyBookTitle,
            body: l10n.emptyBookBody,
          );
        }
        final visible = controller.visibleContacts;
        if (visible.isEmpty) {
          return _StatusMessage(
            messageKey: const Key('state-empty-search'),
            title: l10n.emptySearchTitle,
            body: l10n.emptySearchBody,
          );
        }
        return ListView.builder(
          key: const Key('contact-list'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: visible.length,
          itemBuilder: (context, index) {
            final contact = visible[index];
            return _ContactTile(contact: contact);
          },
        );
    }
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.contact});

  final AddressContact contact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phone = contact.primaryPhone;
    return ListTile(
      key: ValueKey(contact.id),
      title: Text(
        displayName(l10n, contact),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: phone == null
          ? null
          : Text(phone, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: contact.hasEmail
          ? Chip(
              label: Text(l10n.emailBadge),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )
          : null,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => ContactDetailsPage(contact: contact),
          ),
        );
      },
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.messageKey,
    this.title,
    this.body,
    this.actionKey,
    this.actionLabel,
    this.onAction,
    this.showProgress = false,
  });

  final Key messageKey;
  final String? title;
  final String? body;
  final Key? actionKey;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          key: messageKey,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showProgress) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(l10n.loading),
            ],
            if (title != null)
              Text(
                title!,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(body!, textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                key: actionKey,
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'address_contact.dart';

enum NameSort { ascending, descending }

List<AddressContact> applyContactView(
  List<AddressContact> source, {
  required String query,
  required NameSort sort,
}) {
  final needle = query.trim().toLowerCase();
  final filtered = needle.isEmpty
      ? source
      : source
            .where((contact) => contact.name.toLowerCase().contains(needle))
            .toList();

  final named = <AddressContact>[];
  final unnamed = <AddressContact>[];
  for (final contact in filtered) {
    if (contact.name.trim().isEmpty) {
      unnamed.add(contact);
    } else {
      named.add(contact);
    }
  }

  int byName(AddressContact a, AddressContact b) {
    final byLabel = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    if (byLabel != 0) return byLabel;
    return a.id.compareTo(b.id);
  }

  named.sort(byName);
  unnamed.sort(byName);
  if (sort == NameSort.descending) {
    return [...named.reversed, ...unnamed];
  }
  return [...named, ...unnamed];
}

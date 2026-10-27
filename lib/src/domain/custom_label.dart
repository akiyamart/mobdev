String? normalizeCustomLabel(String? raw) {
  if (raw == null) return null;
  var value = raw.trim();
  if (value.isEmpty) return null;

  const prefix = r'_$!<';
  const suffix = r'>!$_';
  if (value.startsWith(prefix) &&
      value.endsWith(suffix) &&
      value.length > prefix.length + suffix.length) {
    value = value.substring(prefix.length, value.length - suffix.length).trim();
  }
  if (value.isEmpty) return null;
  return value;
}

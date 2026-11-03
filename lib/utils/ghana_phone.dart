/// Ghana mobile number parsing, shared by validation, E.164 formatting and
/// network detection so all three always agree.
///
/// Accepts any common format, e.g.:
///   0209431336, 020 943 1336, 020-943-1336, (020) 943 1336,
///   209431336, 233209431336, +233209431336, +233 20 943 1336,
///   +233 (0) 20 943 1336, 00233209431336
class GhanaPhone {
  GhanaPhone._();

  /// Mobile network prefixes (the 2 digits after the leading 0).
  static const Map<String, String> _networks = {
    '24': 'MTN', '25': 'MTN', '53': 'MTN', '54': 'MTN', '55': 'MTN', '59': 'MTN',
    '20': 'Telecel', '50': 'Telecel',
    '26': 'AT', '27': 'AT', '56': 'AT', '57': 'AT',
    '23': 'Glo',
    '28': 'Expresso',
  };

  /// Returns the 9-digit national significant number (e.g. "209431336"),
  /// or null if the input isn't a Ghanaian mobile number.
  static String? nationalNumber(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00233')) {
      digits = digits.substring(5);
    } else if (digits.startsWith('233') && digits.length >= 12) {
      digits = digits.substring(3);
    }
    // Handles "0XXXXXXXXX" and the "+233 (0) XX..." style.
    if (digits.length == 10 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    if (digits.length != 9) return null;
    if (!_networks.containsKey(digits.substring(0, 2))) return null;
    return digits;
  }

  static bool isValid(String raw) => nationalNumber(raw) != null;

  /// E.164 format (+233XXXXXXXXX), or null if invalid.
  static String? toE164(String raw) {
    final n = nationalNumber(raw);
    return n == null ? null : '+233$n';
  }

  /// Detects the network from a (possibly partial) number while typing.
  static String networkOf(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00233')) {
      digits = digits.substring(5);
    } else if (digits.startsWith('233')) {
      digits = digits.substring(3);
    }
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits.length < 2) return '';
    return _networks[digits.substring(0, 2)] ?? '';
  }
}

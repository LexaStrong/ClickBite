import 'package:flutter_test/flutter_test.dart';
import 'package:clickbites/utils/ghana_phone.dart';

void main() {
  group('GhanaPhone accepts any valid format', () {
    const valid = [
      '0209431336',
      '020 943 1336',
      '020-943-1336',
      '(020) 943 1336',
      '209431336',
      '20 943 1336',
      '233209431336',
      '+233209431336',
      '+233 20 943 1336',
      '+233 (0) 20 943 1336',
      '+2330209431336',
      '00233209431336',
      ' 020.943.1336 ',
    ];
    for (final v in valid) {
      test(v, () => expect(GhanaPhone.toE164(v), '+233209431336'));
    }
  });

  test('all networks recognised', () {
    expect(GhanaPhone.networkOf('0241234567'), 'MTN');
    expect(GhanaPhone.networkOf('0531234567'), 'MTN');
    expect(GhanaPhone.networkOf('0201234567'), 'Telecel');
    expect(GhanaPhone.networkOf('0501234567'), 'Telecel');
    expect(GhanaPhone.networkOf('0561234567'), 'AT');
    expect(GhanaPhone.networkOf('+233 27'), 'AT');
    expect(GhanaPhone.networkOf('0231234567'), 'Glo');
  });

  group('GhanaPhone rejects invalid numbers', () {
    const invalid = [
      '',
      '020943133', // too short
      '02094313366', // too long
      '0309431336', // landline / unknown prefix
      '+234 803 123 4567', // Nigeria
      '1234567890',
      'abc',
    ];
    for (final v in invalid) {
      test('"$v"', () => expect(GhanaPhone.isValid(v), isFalse));
    }
  });
}

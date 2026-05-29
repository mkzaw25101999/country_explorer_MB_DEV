import 'package:flutter_test/flutter_test.dart';
import 'package:country_explorer/utils/validators.dart';

void main() {
  group('validateSearchQuery', () {
    test('returns null for null input', () {
      expect(validateSearchQuery(null), isNull);
    });

    test('returns null for empty string', () {
      expect(validateSearchQuery(''), isNull);
    });

    test('returns null for whitespace only', () {
      expect(validateSearchQuery('   '), isNull);
    });

    test('returns error for single character', () {
      expect(validateSearchQuery('a'), 'Please enter at least 2 characters');
    });

    test('returns error for numbers', () {
      expect(validateSearchQuery('123'), 'Only letters and spaces are allowed');
    });

    test('returns error for special chars', () {
      expect(
        validateSearchQuery('fin@'),
        'Only letters and spaces are allowed',
      );
    });

    test('returns null for valid input', () {
      expect(validateSearchQuery('Finland'), isNull);
    });

    test('returns null for input with spaces', () {
      expect(validateSearchQuery('South Korea'), isNull);
    });
  });
}

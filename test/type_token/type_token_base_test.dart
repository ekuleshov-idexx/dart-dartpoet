
import 'package:test/test.dart';

import 'package:dartpoet/dartpoet.dart';

void main() {

  test('fullName', () {
    expect(TypeToken.ofFullName('int').toString(), 'int');
    expect(TypeToken.ofFullName('int', true).toString(), 'int?');
    expect(TypeToken.ofFullName('int?').toString(), 'int?');
  });

}

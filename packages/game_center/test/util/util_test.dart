import 'package:flutter_test/flutter_test.dart';
import 'package:game_center/util.dart';

void main() {
  test('Safe put on empty map', () {
    var emptyMap = Map();
    var inserted = safePut(emptyMap, ['foo'], 'test');
    expect(inserted.containsKey('foo'), isTrue);
    expect(inserted['foo'], equals('test'));

    emptyMap = Map();
    inserted = safePut(emptyMap, ['foo', 'bar'], 'test');
    expect(inserted.containsKey('foo'), isTrue);
    expect(inserted['foo'].containsKey('bar'), isTrue);
    expect(inserted['foo']['bar'], equals('test'));
  });

  test('Safe put on non-empty map', () {
    var map = <String, dynamic>{
      'foo': {
        'bar': 'test',
      },
      'bar': 'test',
    };
    var inserted = safePut(map, ['foo', 'test'], 'bar');
    expect(inserted.containsKey('foo'), isTrue);
    expect(inserted['foo'].containsKey('bar'), isTrue);
    expect(inserted['foo'].containsKey('test'), isTrue);
    expect(inserted['foo']['test'], equals('bar'));
  });
}

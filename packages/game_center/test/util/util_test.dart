import 'package:flutter_test/flutter_test.dart';
import 'package:game_center/util.dart';

void main() {
  test('Safe put on empty map', () {
    var emptyMap = {};
    var inserted = safePut(emptyMap, ['foo'], 'test');
    expect(inserted.containsKey('foo'), isTrue);
    expect(inserted['foo'], equals('test'));

    emptyMap = {};
    inserted = safePut(emptyMap, ['foo', 'bar'], 'test');
    expect(inserted.containsKey('foo'), isTrue);
    expect(inserted['foo'].containsKey('bar'), isTrue);
    expect(inserted['foo']['bar'], equals('test'));
  });

  test('Safe put on non-empty map', () {
    final map = <String, dynamic>{
      'foo': {
        'bar': 'test',
      },
      'bar': 'test',
    };
    final inserted = safePut(map, ['foo', 'test'], 'bar');
    expect(inserted.containsKey('foo'), isTrue);
    expect(inserted['foo'].containsKey('bar'), isTrue);
    expect(inserted['foo'].containsKey('test'), isTrue);
    expect(inserted['foo']['test'], equals('bar'));
  });
}

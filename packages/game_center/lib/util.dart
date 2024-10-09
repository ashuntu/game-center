/// Safely insert a deeply nested key into a map.
Map<dynamic, dynamic> safePut(
  Map<dynamic, dynamic> map,
  List<String> keys,
  dynamic value,
) {
  final newMap = Map.from(map);
  var current = newMap;

  for (var i = 0; i < keys.length - 1; i++) {
    final key = keys[i];
    current = current.putIfAbsent(key, Map.new) as Map;
  }

  current[keys.last] = value;
  return newMap;
}

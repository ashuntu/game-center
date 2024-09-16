Map safePut(Map map, List<String> keys, dynamic value) {
  final newMap = Map.from(map);
  var current = newMap;

  for (var i = 0; i < keys.length - 1; i++) {
    var key = keys[i];
    current = current.putIfAbsent(key, () => Map());
  }

  current[keys.last] = value;
  return newMap;
}

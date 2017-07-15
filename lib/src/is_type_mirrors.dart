import 'dart:mirrors';

final Map<Type, TypeMirror> _cache = {};

bool isInstanceOf(value, Type type) {
  var mirror = _cache[type] ??= reflectType(type);
  return reflect(value).type.isSubtypeOf(mirror);
}

/// Dart union type library.
library union_type;

import 'dart:collection';
import 'src/is_type_no_mirrors.dart'
    if (dart.library.io) 'src/is_type_mirrors.dart';

/// Represents a union of multiple types.
class UnionType {
  /// This union type's name.
  final String name;

  /// The types to join.
  ///
  /// `types` can contain either [Type]s or [UnionType]s.
  final List types;

  const UnionType(this.name, {this.types: const []});

  /// Returns `true` if [value] can matched to any type in [types].
  bool check(value) {
    if (types.contains(value.runtimeType)) return true;

    for (var type in types) {
      if (type is UnionType) {
        if (type.check(value)) return true;
      } else if (type is Type) {
        if (value.runtimeType == type)
          return true;
        else if (isInstanceOf(value, type))
          return true;
      } else
        throw new UnionTypeException('$type is not a type.');
    }

    return false;
  }

  /// Returns `true` if every item in [iterable] can be matched to a type in [types].
  bool checkAll(Iterable iterable) => iterable.every(check);

  /// Throws a [TypeError] if [check] returns `false` for [value].
  void enforce(value) {
    if (!check(value)) {
      throw new _UnionTypeError(this, value);
    }
  }

  /// Enforces that all items in [iterable] match this [UnionType].
  void enforceAll(Iterable iterable) {
    iterable.forEach(enforce);
  }
}

/// A list that asserts that its members match a given [UnionType].
class TypedList extends ListBase implements List {
  final List _items = [];
  final UnionType type;

  TypedList(this.type);

  /// Creates a new [TypedList], and adds all items in [list], after
  /// a type assertion.
  factory TypedList.from(UnionType type, List list) =>
      new TypedList(type)..addAll(list);

  @override
  int get length => _items.length;

  @override
  void set length(int value) {
    _items.length = value;
  }

  @override
  void operator []=(int index, value) {
    type.enforce(value);
    _items[index] = value;
  }

  operator [](int index) => _items[index];

  @override
  void add(item) {
    type.enforce(item);
    _items.add(item);
  }

  @override
  void addAll(Iterable iterable) {
    type.enforceAll(iterable);
    _items.addAll(iterable);
  }
}

/// Thrown when an invalid object is used as a type.
class UnionTypeException implements Exception {
  final String message;

  UnionTypeException(this.message);

  @override
  String toString() => 'UnionTypeException: $message';
}

class _UnionTypeError extends TypeError {
  final UnionType type;
  final value;

  _UnionTypeError(this.type, this.value);

  @override
  String toString() => '$value is not a(n) ${type.name}.';
}

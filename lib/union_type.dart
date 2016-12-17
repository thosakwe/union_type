/// Dart union type library.
library union_type;

import 'dart:mirrors';
import 'package:matcher/matcher.dart';

/// Represents a union of multiple types.
class UnionType {
  /// This union type's name.
  final String name;

  /// The types to join.
  ///
  /// `types` can contain either [Type]s or [UnionType]s.
  final List types;

  const UnionType(this.name, {this.types: const []});

  /// Returns true if [value] can matched to any type in [types].
  bool check(value) {
    if (types.contains(value.runtimeType)) return true;

    for (var type in types) {
      if (type is UnionType) {
        if (type.check(value)) return true;
      } else if (type is Type) {
        if (value.runtimeType == type)
          return true;
        else if (reflect(value).type.isAssignableTo(reflectType(type)))
          return true;
      } else
        throw new UnionTypeException('$type is not a type.');
    }

    return false;
  }

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
class TypedList {
  final List _items = [];
  final UnionType type;

  TypedList(this.type);

  /// Creates a new [TypedList], and adds all items in [list], after
  /// a type assertion.
  factory TypedList.from(UnionType type, List list) =>
      new TypedList(type)..addAll(list);

  get first => _items.first;

  List get items => _items;

  Iterator get iterator => _items.iterator;

  get last => _items.last;

  void operator []=(int index, value) {
    type.enforce(value);
    _items[index] = value;
  }

  operator [](int index) => _items[index];

  void add(item) {
    type.enforce(item);
    _items.add(item);
  }

  void addAll(Iterable iterable) {
    type.enforceAll(iterable);
    _items.addAll(iterable);
  }

  bool contains(element) => _items.contains(element);

  elementAt(int index) => _items.elementAt(index);

  String join([String separator]) => _items.join(separator);

  bool remove(item) => _items.remove(item);
}

/// Thrown when an invalid object is used as a type.
class UnionTypeException implements Exception {
  final String message;

  UnionTypeException(this.message);

  @override
  String toString() => 'UnionTypeException: $message';
}

/// Asserts that the given value matches the given [UnionType].
Matcher isUnion(UnionType type) => new _UnionTypeMatcher(type);

class _UnionTypeMatcher extends Matcher {
  final UnionType type;

  _UnionTypeMatcher(this.type);

  @override
  Description describe(Description description) {
    return description
        .add(' should be an instance of the union type ${type.name}');
  }

  @override
  bool matches(item, Map matchState) => type.check(item);
}

class _UnionTypeError extends TypeError {
  final UnionType type;
  final value;

  _UnionTypeError(this.type, this.value);

  @override
  String toString() => '$value is not a(n) ${type.name}.';
}

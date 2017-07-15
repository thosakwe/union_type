import 'package:matcher/matcher.dart';
import 'union_type.dart';

/// Asserts that the given value matches the given [UnionType].
Matcher isUnion(UnionType type) => new _UnionTypeMatcher(type);

/// Asserts that all of the given values match the given [UnionType].
Matcher allAreUnion(UnionType type) => new _AllUnionTypeMatcher(type);

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

class _AllUnionTypeMatcher extends Matcher {
  final UnionType type;

  _AllUnionTypeMatcher(this.type);

  @override
  Description describe(Description description) {
    return description
        .add(' should all be an instances of the union type ${type.name}');
  }

  @override
  bool matches(item, Map matchState) => type.checkAll(item);
}
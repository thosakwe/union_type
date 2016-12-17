import 'package:test/test.dart';
import 'package:union_type/union_type.dart';

const UnionType PRIMITIVE = const UnionType('Primitive',
    types: const [String, num, int, double, Symbol, Null]);
const UnionType PRIMITIVE_OR_TYPE =
    const UnionType('PrimitiveOrType', types: const [PRIMITIVE, Type]);

main() {
  test('check', check);
  test('enforce', enforce);
  test('list', list);
}

check() {
  expect(1, isUnion(PRIMITIVE));
  expect(null, isUnion(PRIMITIVE));
  expect([1, 2, '3', #four, 5, null], allAreUnion(PRIMITIVE));
  expect(PRIMITIVE.check(1), isTrue);
  expect(PRIMITIVE.check(null), isTrue);
  expect(PRIMITIVE.check({}), isFalse);
  expect(PRIMITIVE.check([1, 2, 3]), isFalse);
  expect(1, isUnion(PRIMITIVE_OR_TYPE));
  expect(String, isUnion(PRIMITIVE_OR_TYPE));
  expect(PRIMITIVE_OR_TYPE.check(1), isTrue);
  expect(PRIMITIVE_OR_TYPE.check(String), isTrue);
  expect(PRIMITIVE_OR_TYPE.check([4, 5, 6]), isFalse);
}

enforce() {
  PRIMITIVE.enforce(2);
  PRIMITIVE_OR_TYPE.enforce(int);

  expect(() {
    PRIMITIVE.enforce({});
  }, throwsA(new isInstanceOf<TypeError>()));

  expect(() {
    PRIMITIVE_OR_TYPE.enforce(() => print('Hi!'));
  }, throwsA(new isInstanceOf<TypeError>()));
}

list() {
  final list = new TypedList(PRIMITIVE);
  list.add('String');
  list.addAll([1, 2, '3', #four, null]);

  expect(() {
    list.add({});
  }, throwsA(new isInstanceOf<TypeError>()));

  expect(() {
    list.addAll([
      [],
      {'foo': 'bar'},
      UnionType
    ]);
  }, throwsA(new isInstanceOf<TypeError>()));
}

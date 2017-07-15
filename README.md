# union_type

[![version 1.0.0+1](https://img.shields.io/badge/pub-v1.0.0+1-brightgreen.svg)](https://pub.dartlang.org/packages/union_type)
[![build status](https://travis-ci.org/thosakwe/union_type.svg)](https://travis-ci.org/thosakwe/union_type)

Dart union type library. This library no longer depends on `dart:mirrors`.

# Usage
`union_type` provides helpers for type assertions across types that do not share
ancestry.

```dart
import 'package:union_type/union_type.dart';
const UnionType BAZ = const UnionType('Baz', types: const [Foo, Bar]);

main() {
    BAZ.enforce(new Foo()); // No error
    BAZ.enforce(new Bar()); // No error
    BAZ.enforce({}); // TypeError
    BAZ.enforceAll([1, 2]); // TypeError
    
    if (BAZ.check(foo)) {
        // Do something
    } else {
        // Do something else
    }
}
```

Union types can assert other union types as well.

```dart
const UnionType MASTER =
    const UnionType('MasterType', types: const [BAZ, OtherType]);
```

You can also create a list of items, asserting that they match the type.

```dart
import 'package:union_type/union_type.dart';
const UnionType MONSTER =
    const UnionType('Monster', types: const [Franken, Stein]);

main() {
    var monsterArmy = new TypedList(MONSTER);

    monsterArmy.add(new Franken());
    monsterArmy.add(new Stein());

    for (var monster in monsterArmy) {
        print('MWAHAHAHA: $monster');
    }

    monsterArmy.add(2); // TypeError
    monsterArmy.addAll([2, 3, 4, '5']); // TypeError
}
```
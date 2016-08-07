# Path-dependent types

Type members defined in classes are resolved relatively to the variable which contains an instance of such class:

```scala
class Container {
  type Item = Int
  val n: Item = 10
}

val x = new Container

val c1 = Vector[x.Item]()
```

In other words, it is possible for types to depend on the value, or, more correctly, on the "path" to the type, expressed in terms of values.

This is one of the most confusing features of Scala type system, and while it can lead to more type safe code when used correctly, it is very difficult to actually used it correctly, and it may produce quite incomprehensible errors.

Therefore, using path-dependent types is forbidden. There is almost always a better way to do something than  relying on them.

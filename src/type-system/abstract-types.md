# Abstract (associated) types

Scala allows one to define abstract types in classes which then could be overridden in subclasses:

```scala
trait Container {
  type Item
}

class IntContainer extends Container {
  override type Item = Int
}
```

This feature is related to path-dependent types and very often leads to very confusing code, and therefore must be avoided at all costs.

Note that defining type aliases (which is also done with the `type` keyword) is perfectly fine; it's abstract types which are overridden with a concrete type are forbidden.

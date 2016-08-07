# `override` modifier

Scala requires `override` modifiers on items which override items with the same defined in the parent class, but it does not require it if these parent items are `abstract`:

```scala
abstract class Root {
  def x: Int = 10
  abstract def y: Int
}

class Child extends Root {
  override def x: Int = 12
  def y: Int = 42
}
```

However, you should always use `override` modifier even for implementing abstract methods. This makes the fact that the item actually "comes" from a parent class obvious and it allows accidental non-overrides, for example, as a side effect of refactoring, to be caught during compilation easily.

Note that you must use the `override` modifier even if you define the overriding field as a part of constructor arguments declaration:

```scala
trait Entity {
  def id: String
}

case class User(override val id: String) extends Entity
```


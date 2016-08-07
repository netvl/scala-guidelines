# Pattern matching

Pattern matching is used everywhere in Scala.  Pattern matching combines conditional execution, destructuring and casting in one construct. It is one of the tools which are able to increase both clarity and safety of the code at the same time.

When you pattern match on an ADT, prefer extracting values instead of accessing them with the method notation. In other words, write this:

```scala
animal match {
  case Dog(name) => s"A dog named $name"
  case other => "Someone else"
}
```

instead of this:

```scala
animal match {
  case dog: Dog => s"A dog named ${dog.name}"
  case other => "Someone else"
}
```

However, if a case class contains lots of fields, and you only need a handful of them, use the latter syntax because it would make the code less cluttered, and it would be harder to make a mistake when selecting a field to extract:

```scala
component match {
  case Composite(_, _, _, _, children, _, _) =>
    processComponents(children)
  case _ => ...
}
```

versus

```scala
component match {
  case composite: Composite =>
    processComponents(composite.children)
  case _ => ...
}
```

## `unapply` methods

Scala allows to define a special method on a object called `unapply`. Objects with such methods can be used in the patterns to extract values using this method:

```scala
case class Reference(entity: String, parameter: String) {
  override def toString: String = s"$entity.$parameter"
}

object Reference {
  def fromString(s: String): Option[Reference] = s.split(".", 2) match {
    case Array(entity, parameter) => Some(Reference(entity, parameter))
    case _ => None
  }
}

object ReferenceString {
  def unapply(s: String): Option[Reference] = Reference.fromString(s)
}

someString match {
  case ReferenceString(Reference(_, parameter)) =>
    println("Parameter: $parameter")
  case _ => ...
}
```

It is hard to remember how `unapply` methods should be defined, and their overuse makes the code less readable, so they should not be used unless they significantly improve readability, e.g. when their functionality is used in many places in the code base.

`unapply` methods must never be defined in regular classes, only in objects.


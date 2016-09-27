# Imports

## Imports order

Use the IDEA imports optimizer to sort imports. The following IDEA configuration snippet displays the optimal sort order:

```
java
_______ blank line _______
scala
_______ blank line _______
all other imports
_______ blank line _______
your.app.root.package
```

Source code files should not contain unused imports. Use IDEA imports optimizer to fix this, but remember that sometimes IDEA may remove imports which are actually used (this happens mostly with importing of implicits).

## Relative imports

Always use absolute imports; IDEA code style configuration should enforce this. Relative imports almost always decrease the readability.

## Imports location

Always put imports at the top of the file instead of nested scopes. In other words, imports must always be grouped together in one place. The only exception is when you need to use some kind of [DSL](../patterns-and-architecture/domain-specific-languages.html) which provides many identifiers which you don't want to pollute the file namespace. Examples of such DSLs are Cassandra's `QueryBuilder` and akka-streams `GraphDSL`.

## Wildcard imports

Avoid using wildcard imports, unless you're importing more than 6 items from the same package. This behavior is also enforced by IDEA.

## Importing object internals

Avoid importing inner classes and methods from objects. For example, do this:

```scala
object SomeObject {
  class SomeClass

  def someMethod(): SomeClass = ...
}

val t: SomeObject.SomeClass = SomeObject.someMethod()
```

instead of this

```scala
import SomeObject.{SomeClass, someMethod}

val t: SomeClass = someMethod()
```

While this may marginally decrease clutter, it makes it unclear where the respective methods come from, and, more importantly, whether they are defined in the same class or not. Moreover, some types and values are intended to be used with explicit qualifications, for example:

```scala
sealed trait TypeName
object TypeName {
  case class String(...) extends TypeName
  case class Int(...) extends TypeName
  case class Double(...) extends TypeName
}
```

Here, importing internals of `TypeName` may cause havok in the respective code because these names will override the standard names for primitive types. When they are used with the qualifer, like `TypeName.String`, it is perfectly okay and does not cause problems.

The same reasoning should be applied to constants defined in objects as well, although there is an exception: if a constant is used multiple times, especially inside string patterns, it is okay to import it:

```scala
import SomeObject.{Constant1, Constant2, Constant3}

val pattern = s"""
  |Some text with patterns $Constant1 intermixed
  |with $Constant1 constants $Constant2 multiple
  |$Constant3 lines and whatever""".stripMargin

object SomeObject {
  val Constant1 = ...
  val Constant2 = ...
  val Constant3 = ...
  ...
}
```

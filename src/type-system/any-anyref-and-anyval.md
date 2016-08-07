# `Any`, `AnyRef` and `AnyVal`

`Any` and `AnyRef` represent the top-level types, for all values, for all references and for all non-references, respectively. Because of the subtyping, every value may be stored in a variable typed `Any`. Therefore, `Any` can be thought as an "escape hatch" from the type system, and so should not be used in regular code.

If you need to encode values which may be of a finite set of different types, consider writing an ADT which encodes these types as its variants:

```scala
sealed trait Variant
object Variant {
  case class Int(value: scala.Int) extends Variant
  case class String(value: java.lang.String) extends Variant
  // etc.
}
```


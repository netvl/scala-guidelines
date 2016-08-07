# `isInstanceOf`, `asInstanceOf`

These methods are often used in conjunction with `Any*` types, and thus should be avoided in the regular code. If you do need to check a runtime type of a variable, use pattern matching instead:

```scala
value match {
  case x: SomeType => ...
  case _ => ...
}
```

One of the most common applications of this pattern are algebraic data types which are described in their own section.

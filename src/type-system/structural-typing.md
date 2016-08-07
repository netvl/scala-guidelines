# Structural typing

Scala allows structural typing based on reflection, i.e. it is possible to define the interface which a variable should have directly as type:

```scala
case class Something(id: String)

val x: { def id: String } = Something("abcde")
```

Structural typing must be avoided in all its forms because it hurts both runtime performance and code readability and maintainability.

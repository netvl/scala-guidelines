# Generics and variance

The necessity to create types with generic parameters should be very rare, however, if there is a need to create one, then their type should be properly annotated with variance.

There is a general rule about that: if a type only "produces" values of the generic type, i.e. when this type is present only in return positions in all methods in the class, then this generic parameter must be marked as covariant:

```scala
trait Collection[+T] {
  def head: T
}
```

If a type only "consumes" values of the generic type, i.e. when this type is present only in parameters positions in all methods in the class, then this generic parameter must be marked as contravariant:

```scala
trait Comparator[-T] {
  def compare(left: T, right: T): Int
}
```

If a type both "produces" and "consumes" values of the generic type, then this generic type must not be marked with any markers and therefore be invariant:

```scala
trait MutableBuffer[T] {
  def head: T
  def push(value: T)
}
```

Using appropriate variance increases the maintainability of the code, like any other contract between types.


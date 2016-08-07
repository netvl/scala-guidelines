## Higher-kinded types

Higher-kinded types represent an ability to abstract over type constructors, as opposed to abstracting over concrete types. For example, regular collections are examples of types of the first kind:

```scala
class ArrayBuffer[T] {
  private val data: Array[T] = ...
  ...
}
```

Here `T` is a concrete type - it may be `Int`, `String`, `Vector[Double]`, or whatever else.

The following definition, however, is a type of the second kind:

```scala
trait Functor[F[_]] {
  def map[A, B](f: A => B): F[A] => F[B]
}
```

Note how exactly the `F` type parameter of the trait is defined and the fact that it is used with *different* type arguments inside the trait body. This trait accepts not a concrete type, but a *type constructor* - something which can be applied to a concrete type to get another concrete type.

Higher-kinded types, that is, an ability to define traits like the `Functor` above, are an extremely powerful feature which allows expression of many complex abstractions, however, these abstractions are objectively hard to understand for people who never worked with them before. Therefore, declaring custom higher-kinded types is forbidden. Not many languages which have generics also have the support for higher-kinded types, and they do nicely without them, so there are always ways to solve the problem at hand without HKTs.

Unfortunately, higher-kinded types are sometimes used in libraries. One of the most prominent examples are the standard Scala collections. Usually you won't need to even know about HKTs to work with Scala collections, which is a good thing; however, if you intend to extend the collections library in any way, e.g. by adding extension methods to collections, the necessity to work with higher-kinded types should taken into account. Thus it is not forbidden to use higher-kinded types, but always try to think about whether it is possible to solve the problem you're working on without relying on them.


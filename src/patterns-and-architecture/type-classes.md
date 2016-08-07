# Type classes

Type classes are a pattern which relies on implicits resolution to inject pieces of functionality based on one or more types. A classic example of a type class is `Ordering`:

```scala
trait Ordering[-T] {
  def compare(left: T, right: T): Int
}

object Ordering {
  implicit object IntOrdering extends Ordering[Int] {
    override def compare(left: Int, right: Int): Int = left - right
  }
}

def sorted(v: Vector[T])(implicit ord: Ordering[T]): Vector[T] = {
  ...
}

// IntOrdering is injected automatically as
// the implicit parameter for `sorted`
val s = sorted(Vector(4, 2, 7, 1, 3))
```

Type classes are very similar to regular interfaces/traits but allow adding "implementations" to types without changing their `extends` clause. 

So, type classes are a very powerful tool, but, as usual, if they are overused, they can lead to very confusing code. The need to declare custom type classes should be exceedingly rare, therefore unless they significantly increase the clarity of the architecture, they should not be used - regular object-oriented features like traits should be used instead.

However, many important libraries, in particular, for serialization, provide their type classes which are expected to be implemented for custom types. This is usually unavoidable and in some cases lead to reduction of boilerplate code. For example, instead of writing custom low-level serializers for a class to JSON representation, using a predefined method to generate the corresponding type class instance will lead to more succinct and understandable code.

Therefore, you may write such implementations. See the section on implicit values for more information on how to handle them.



# Implicits

Implicits comprise a very powerful part of the Scala language, however (or even therefore) they often lead to code which is very hard to understand if they are overused.

Implicits as a feature are used pervasively for many tasks across the entire Scala ecosystem, so it unfeasible to completely disallow their usage. In particular, they solve both the expression problem (adding new methods to existing types) and the cross-cutting concerns problem (using a single globally configured value in different places of code) transparently. However, they must be used sparingly, and only when their usage is motivated by a significant increase in readability or by the necessity to integrate with other libraries.

The general rule is as follows (quoting Twitter's Effective Scala):

> If you do find yourself using implicits, always ask yourself if there is a way to achieve the same thing without their help.

## Implicit conversions

Implicit conversions are declared as functions which accept a value and return a value of a different type. These functions are then used by the compiler to implicitly convert the original value if necessary, e.g. when it is passed to somewhere when the target type is expected or when a method is called which is not available on the source type but available on the return type:

```scala
implicit def intAsString(x: Int): String = x.toString

x.length  // equivalent to x.toString.length
```

Implicit conversions are absolutely forbidden to be declared, and their usage from the third-party libraries must be avoided at all costs. Fortunately, the Scala community at large considers implicit conversions as an anti-feature and therefore most popular libraries do not depend on it. One of the notable examples of implicit conversions is the built-in Scala-to-Java collection conversions:

```scala
import scala.collection.JavaConversions._

val s: Vector[Int] = Vector(1, 2, 3)
val x: java.util.List[Int] = s  // gets converted automatically
```

Using `JavaConversions` (and additionally `wrapAsJava`, `wrapAsScala` and `wrapAll`) is strictly forbidden; in case if such conversions are necessary, `decoratedAsJava`, `decorateAsScala` or `decorateAll` should be used:

```scala
import scala.collection.convert.decorateAsJava._

val s: Vector[Int] = Vector(1, 2, 3)
val x: java.util.List[Int] = s.asJava
```

## The expression problem, extension methods

[Expression problem](https://en.wikipedia.org/wiki/Expression_problem) is basically a task of adding new operations to an already defined type. It is well known that most of the "old" static languages, like C, C++ and Java, do not have any kind of solution for it. In most dynamic languages this is not a problem due to dynamic typing and monkey patching, but static languages also have their own solutions. For example, C# and Kotlin have extension methods, while Haskell and Rust have type classes (called traits in the latter). Scala solution for the expression problem are methods injected through implicits.

Modern IDEs, in particular, IntelliJ IDEA, are able to understand most if not all commonly used implicits usage scenarios: in particular, they are able to highlight methods added through implicit classes and show implicit parameters of a method call, and allow to navigate to the definition of these methods. Therefore, using implicits for simple tasks, like adding new methods to existing types, is not forbidden:

```scala
implicit class ArrayOps[A](val arr: Array[A]) extends AnyVal {
  def firstTwoOpt: Option[(A, A)] = if (arr.length >= 2) Some((arr(0), arr(1))) else None
}
```

Note, however, that for this to be acceptable, such extension must be motivated by a significant increase of readability. In particular, this is justified when the newly added operation is used very often in some part of code. If this operation is defined as a regular function, it would require calling it with the function syntax instead of the method syntax:

```scala
arr.firstTwoOpt
// vs
firstTwoOpt(arr)
```

The function syntax requires parentheses, and when there are many calls of this function or if they are present in some complex expression which already has parentheses, it hurts readability. Extension methods, therefore, may be used if they help to reduce the noise.

Extension methods must only be defined with an `implicit class` declaration, never via an `implicit def` conversion (see the above section). If possible, such `implicit class` must be defined in some object (including package objects) and extend `AnyVal` in order to avoid performance penalties of boxing.  It makes sense to add such operations to some common internal utilities library, and putting them *not* there should be avoided.

## Implicit arguments

Implicit arguments are used quite frequently by concurrency and serialization libraries in order to pass some auxiliary values around without them unnecessarily cluttering the code. Examples of such libraries are those using implicits to define class serializers (most JSON libraries in Scala do that) and passing around `ExecutionContext` with `Future`s.

IDEs, in particular, IntelliJ IDEA, are quite capable of showing which implicit values are used in the particular method invocation, so understanding the code when they are used is not a hard problem. Thus, it is allowed to declare implicit arguments, especially when integrating with libraries mentioned above:

```scala
// here both query() and map() calls accept the execution context implicitly
def load(id: String)(implicit ec: ExecutionContext): Future[SomeObject] =
  remoteApi.query(id).map(convertFromJson)
```

However, it is almost never necessary to use implicit parameters of the types defined in the custom code base. Oftentimes this is done to "simplify" the code which eventually results in code which is messy and hard to read. Therefore, using implicit parameters for custom types unrelated to other libraries should be avoided.

When interacting with the third-party libraries, it is sometimes necessary to define new implicit objects. The most prominent example is defining serializers for custom types. Definition of these implicits must be as contained as possible. Ideally a set of such definitions which are related in some way should be grouped together in one object, and this object should be imported when these implicits are needed:

```scala
object ModelJsonFormatters {
  implicit val userFormat = Json.format[User]
  implicit val serviceFormat = Json.format[Service]
  implicit val whateverFormat = Json.format[Whatever]
}

// at the use site
import some.pkg.ModelJsonFormatters._

val jsonData = Json.toJson(Whatever(...))
```

Naturally, using them must not contradict the rules about imports as they are defined above.

As a final note, implicits are sometimes feared because they are used in complex libraries like scalaz. However, these libraries actually provide *concepts* which are hard to understand without prior experience; implicits only allow these libraries not to look absolutely horrible, and their absence from there would not make things better. This is the reason why usage of implicits is allowed: if used correctly (according to the guidelines presented above), they lead to much clearer code. If they are used together with a library which itself is very complex, they make things worse. The solution is to avoid using such libraries but not implicits; more on this below.


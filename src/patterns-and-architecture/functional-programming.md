# Functional programming

Functional programming can loosely be defined as a paradigm which treats computation as a sequence of evaluations of mathematical functions. This implies that it places emphasis on avoiding mutable state and side effects and is heavily based around returning and combining expressions. Among language features usually associated with functional programming are first-class functions, immutability of data, lack of side effects (pure and referentially transparent functions), recursive computations instead of imperative loops, and so on.

Design of the Scala language strongly favors the aforementioned functional programming practices. To make them easy to implement, Scala provides tools like case classes, pattern matching, type inference, lightweight closure syntax and powerful built-in collections library. Moreover, a major part of the standard Scala library is designed using functional idioms, and many of the popular community libraries follow suit.

## Immutability

Immutability of data is one of the cornerstones of the functional programming. It may sound very limiting to those who are accustomed to the conventional imperative languages like C/C++ or Java, but when immutability has proper support in the language, it allows writing much cleaner code with stronger invariants, and which is also thread-safe by default.

Therefore, as a general rule, avoid creating objects with mutable state. In particular, algebraic data types (see the section below) must not have `var` members, as well as indirectly mutable things like mutable collections.

Mutability on the method level, i.e. using local `var`s and mutable structures, should also be avoided as much as possible. There are times, however, when relying on mutability does make the code clearer and/or is required for performance reasons. In that case mutability should be isolated: the public interface should avoid exposing the mutability used to implement it.

## Algebraic data types

Algebraic data types (ADTs for short), while may sound somewhat scary, are a very simple concept. ADTs are the simplest composite types, that is, they are types which combine other types in two simple ways.

First, an ADT may combine several values in a tuple:

```scala
case class User(name: String, password: String)
```

`User` is a simple *product* ADT: an instance of `User` is fully defined by its `name` and `password` fields. The simplest possible product is a nullary product which contain no fields; it is just a single value:

```scala
case object EmptyList
```

Second, an ADT may combine several mutually exclusive variants of products:

```scala
sealed trait OptionalInt
case class SomeInt(value: Int) extends OptionalInt
case object NoneInt extends OptionalInt
```

Here `OptionalInt` is the ADT, and `SomeInt` and `NoneInt` are its variants. Each variant is a product ADT in itself. A value of type `OptionalInt` may be either an instance of `SomeInt` or `NoneInt`, and because the trait is sealed, it cannot be extended anywhere else except where it is defined, so there are no other possible values for it. Such combinations of product types are called *sum* types, or sometimes *disjoint unions*. Another common example of such an ADT is a tree, which also demonstrates how an ADT can be recursive:

```scala
sealed trait Tree
object Tree {
  case class Node(left: Tree, right: Tree) extends Tree
  case class Leaf(value: Int) extends Tree
}
```

As can be seen above, in Scala sealed traits and case classes are used to create algebraic data types.

ADTs are useful to model a wide range data structures, simple data types and state machines being the most prominent examples. Pattern matching together with the exhaustiveness analysis allow writing more correct code. Many algorithms on ADTs are naturally recursive, and pattern matching leads to very clear and correct code:

```scala
def findMax(tree: Tree): Int = tree match {
  case Tree.Node(left, right) => Vector(findMax(left), findMax(right)).max
  case Tree.Leaf(value) => value
}
```

Because of the exhaustiveness analysis, such pattern matches will make sure that you didn't forget to check any variants of an ADT: if for some reason you didn't check a value of a sum type for one of its variants, it would be a compiler error.

### Sum types declarations

If you need to write a sum data type, declare all its variants inside the companion object of the root sealed trait:

```scala
// write this
sealed trait IntList
object IntList {
  case class Cons(value: Int, rest: IntList) extends IntList
  case object Empty extends IntList
}

// not this
sealed trait IntList
case class IntListCons(value: Int, rest: IntList) extends IntList
case object IntListEmpty extends IntList
```

Putting variants of a sum type into the companion object reduces the namespace pollution, allows to use nicer names for variants and makes the code which uses these names clearer because it becomes visible to which type these variants belong.

### Enumerations

One important case of sum ADTs are enumerations, i.e. a fixed small set of values (objects). Lots of things are modeled with enumerations, for example, state of some system:

```scala
sealed trait State
object State {
  case object Stopped extends State
  case object Started extends State
  case object Failed extends State
}
```

So, when you need to declare something which would be an `enum` in Java, use the above pattern.

Just as with any other ADT, declare all enumeration constants inside the companion object of the respective sealed trait. Do not use `scala.Enumeration` because it has very unnatural API.

## Options and `null`

The easiest way to understand the `Option` type is to think of it as a container which may contain either one value of the given type or none. `Option` is an ADT of a very simple structure:

```scala
sealed trait Option[+T]
case class Some[+T](value: T) extends Option[T]
case object None extends Option[Nothing]
```

Because `Option[T]` is covariant in `T` (as signified by the `+` sign), and `Nothing` is a subtype of any other type, `None` which extends `Option[Nothing]` can be used as a value for `Option[T]` for any `T`.

Absence of a value is an extremely common idiom, and in Java it is usually modeled with `null`. In Scala code, however, `Option`s should always be used for this purpose.

`Option`s returned by functions force you to check for the absence of value before using it. This can be done using pattern matching:

```scala
val v: Vector[Int] = ...
v.find(_ > 0) match {
  case Some(n) => println("$n is positive")
  case None => println("No positive values")
}
```

Moreover, `Option` has several methods which make working with possibly absent values easier:

```scala
// when we only need to handle the "value is present" case
v.find(_ > 0).foreach { n =>
  println("$n is positive")
}

// when we need to return a default value in case
// the computed value is absent
val n = v.find(_ > 0).getOrElse(0)
```

When interfacing with Java code, all values coming from the Java side must be checked for `null`s if it is not stated explicitly that no `null` values are possible. `Option.apply` methods accepts a nullable value and returns an `Option` which will be `None` if the passed value is actually `null`:

```scala
Option(javaClass.getResourceAsStream("some_file"))
```

Do not call `get` on optional values except when you're absolutely sure that the optional value is always non-empty. Often such code may be rewritten more clearly using pattern matching or other optional combinators.

## Recursion

Recursion is often very natural for certain algorithms, especially on recursive structures like trees and lists. In many cases, however, recursion tends to make the code obscure.

Always try to solve the problem without explicit recursion first. Scala collections library provides lots of combinators which make explicit recursive traversals unnecessary in many cases.

If a problem cannot be solved with pre-defined, combinators, compare the imperative version using loops and recursion first. In many cases, especially when the logic is not very large, imperative implementation may be simpler than recursion. In other cases, recursion would be clearer.

When writing recursive functions, try to write them in a tail-recursive way, enforced by the `@tailrec` annotation. Tail-recursive functions will be optimized by the compiler into an imperative loop. However, tail-recursive functions may require passing lots of state in an accumulator parameter. Sometimes rewriting such functions using imperative loops may make the code nicer.


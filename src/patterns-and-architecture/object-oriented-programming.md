# Object-oriented programming

Scala is a powerful object-oriented language; if fact, it is even more pure than Java. Everything in Scala is an object, and its facilities for object-oriented design are very expressive and convenient. Naturally, most of object-oriented design practices are possible in Scala; they are described in numerous forms in various books and articles and therefore are omitted here. In this document we will examine Scala-specific features which help with the object-oriented programming.

## Dependency injection

Dependency injection is a wide range of practices related to how different parts of the program are combined together. Usually it boils down to how classes get instances of each other. In its simplest form dependency injection means passing dependencies of a class to this class from "outside", e.g. by passing their instances through the constructor. However, there are dependency injection frameworks which allows declarative description of the object graph.

Compared to Java, manual dependency injection in Scala is much more convenient, because there is no need to manually create fields and declare constructors. Moreover, factories are naturally modeled using functions. Here are examples from the Twitter's Effective Scala, they display a perfectly valid approach to structuring the program:

```scala
trait TweetStream {
  def subscribe(f: Tweet => Unit)
}
class HosebirdStream extends TweetStream ...
class FileStream extends TweetStream ...

class TweetCounter(stream: TweetStream) {
  stream.subscribe { tweet => count += 1 }
}

class FilteredTweetCounter(mkStream: Filter => TweetStream) {
  mkStream(PublicTweets).subscribe { tweet => publicCount += 1 }
  mkStream(DMs).subscribe { tweet => dmCount += 1 }
}
```

## Traits

Traits in Scala are very versatile and are used for many purposes. One of the roles of traits in Scala are Java-like interfaces, i.e. statically defined contracts which are extended by other classes which are intended to provide these contracts. Another role are mixins, which are a way to combine pieces of common functionality. Even another role, as can be seen from the section on ADTs, is to serve as a marker type for sum data types.

### Intention

Traits can be roughly divided in two groups: interface traits and mixin traits. Interface traits are intended to declare contracts for the implementing classes, while mixin traits are needed to share common functionality. Do not mix these "kinds" of traits: if a trait is declared as an interface, it must only be used for this purpose, and if it is declared as a mixin, it must not be used as an interface, for example, it should not be used as a type for variables. Think of it as a variant of the single responsibility principle, but on a higher level.

### Members

As a rule of thumb, always define all members of traits as `def`s. `def` is the most general variant of a class member, and it may be overridden with any other kind of member: `val`, `lazy val`, `var` and `def` are all allowed.

Sometimes it makes sense to declare a member as `val` instead of `def`, but cases when it is necessary are exceedingly rare. Never define `var`s or `lazy val`s as abstract members.

### Complexity

Keep traits short but cohesive: leave the bare minimum of methods comprising one interface for one task, but no less. Do not be afraid to create many interface traits, they can be combined together if necessary:

```scala
trait Reader {
  def read(n: Int): Array[Byte]
}

trait Writer {
  def write(bytes: Array[Byte])
}

type ReadWriter = Reader with Writer
```

is better than

```scala
trait ReadWriter {
  def read(n: Int): Array[Byte]
  def write(bytes: Array[Byte])
}
```

(adapted from the Twitter's Effective Scala)

### Traits with implementation

Traits in Scala can contain implementations for their methods. When a trait is used as an interface trait, it may make sense to add a method which delegates to other methods of the same trait to create a shortcut for the users of the interface. For example:

```scala
trait JsonWriter[T] {
  def write(value: T): JsonTree
  
  final def writeString(value: T): String = write(value).toString
}
```

These utility methods should almost always be declared as `final`.

## Visibility

Scala has very powerful visibility modifiers. It is possible to restrict visibility of an item in a very fine-grained way. Using them is very important for limiting the surface of your API. It is always easier to add new methods to the API than to remove them, because if you publish something, someone may start to depend on it, and removing it back or changing it would be very difficult without breaking the clients' code.

So, as a general rule, always make class and package members as less visible as possible. By default, make all items of a class `private`; you can always expose them at any time later, but hiding them back won't be easy in general.

One important case of visibility modifiers is `private[this]`. Regular `private` items are accessible from all instances of the class, while `private[this]` is accessible only within a single instance. Scala compiler is able to translate accesses to `private[this]` variable members directly to the field access, which may result in performance optimization.

## Class nesting

Scala, like Java, allows nesting classes. Moreover, nesting classes in Scala is quite an ubiquitous thing, given that Scala is a pure object-oriented language. However, due to the way the nesting is done (both in Java and in Scala), it should be used with care.

In Java, there are two kinds of nested classes: static and non-static. Static inner classes are used just for namespacing: a static inner class is absolutely equivalent to a top-level class, except for naming. Non-static inner classes, however, are special: they hold an implicit reference to the enclosing class, which allows them to access instance fields of the enclosing class, but they are naturally associated with instances of the enclosing class: it is impossible to create instances of them without creating an instance of the enclosing class first.

Scala does not have static anything, but there are direct analogues of the static and non-static nested classes. First, any classes defined in objects are equivalent to static nested classes from Java:

```scala
sealed trait OptionalInt
object OptionalInt {
  case class SomeInt(x: Int) extends OptionalInt
  case object NoneInt extends OptionalInt
}
```

This is quite natural because only one instance of an object can exist at one time, and therefore there is no need to store a hidden reference to it in the class itself.

On the other hand, any class defined in another class behaves as a non-static inner class:

```scala
class Outer(val n: Int) {
  class Inner {
    def printN(): Unit = println(n)
  }
  
  def makeInner: Inner = new Inner
}

new Outer(10).makeInner.printN()  // prints 10
```

Here `Inner` class may access an instance-level `val` in the enclosing class.

Nesting classes may increase readability because it allows grouping common functionality together even if it needed only in a single class without publishing it as a top-level class, eventually shrinking the surface of the API. However, because instances of classes nested in other classes (not objects) always hold a reference to an instance of the enclosing class, you should be careful when you store these instances in caches and when doing Java serialization.

Also keep in mind that declaring a class inside an object inside another class does not make them "static".


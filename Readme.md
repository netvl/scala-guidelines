# Introduction

Scala language has lots of features over the baseline Java, and many of them provide a quite significant boost in readability and correctness of the code, as well as productivity of a developer. However, many of these features, and many libraries which are or are not based on these features require considerable experience to be used correctly and actually hinder readability of the code, especially for people who are unfamiliar with the concepts used in these libraries, with the code base, or with the whole JVM/Java/Scala ecosystem in general.

The intention of this document is to provide a general overview of Scala usage practices which should be employed to keep the code base approachable, understandable and maintainable, while not hindering the developers productivity. These practices are also intended to allow new developers to get accustomed with the existing code more easily, and to make sure that they do not need to have significant background in mathematics or functional programming languages in order to start to hack on the code quickly.

Some of these practices are enforced automatically with the code style analyzers and linters, and therefore their violation will result in a failed build. Most, however, are enforced through the code review process. Therefore, it is absolutely necessary for the reviewers to understand this document by heart and apply it rigorously. To help with this task, a dedicated section at the end of the document serves as a handbook for reviewers, providing a list of most important things to look for during the code review.

This document is heavily based on the following existing Scala guidelines:

* Twitter's Effective Scala: https://twitter.github.io/effectivescala/
* Databricks Scala Guide: https://github.com/databricks/scala-style-guide
* Scala Best Practices: https://github.com/alexandru/scala-best-practices

as well as our own experience in writing Scala code.

This document will be updated in the future to include things we will encounter when dealing with new code contributions.

# Table of contents

[TOC]

# General code style (TODO?)

As a general rule, constantly monitor warnings and other notices which your IDE shows you. IntelliJ IDEA in particular has clever analysis features which are very helpful to avoid many mistakes in the code style. If you use IDEA to make commits, enable "Before commit / Perform code analysis" option in its commit window - it will display all errors and warnings it sees in the code you're about to commit.

## Formatting and whitespace

Formatting suggested by the configured IDEA should be preferred. If in doubt, use the "Reformat code" action.

Lines should be indented with two spaces. Lines longer than 120 characters in length should be avoided.

## Naming

### Length of names

Follow the rule "longer names for larger scopes, shorter names for smaller scopes". One-letter names for numeric loops indices are acceptable, same names for most of local variables and pattern variables are not.

### Apostrophes

Avoid using \`s to overload reserved names. Use of apostrophes in pattern matching for equality checking, on the other hand, is acceptable:

```scala
val name = "hello"

x match {
  case SomeClass(`name`) => ...
}
```

### Constant names

Constants must always follow the `PascalCase` naming rule, according to the default style used in Scala community. Do not use `CAPITAL_SNAKE_CASE` or `camelCase` for constant names.

Constants must always be defined in objects. If a constant is only used in one class, then it should be defined in its companion object. If a constant is used in multiple classes, it should be defined in some common object.

Constants must not be defined in package objects.

### Getters

Do not prefix getters with `get`, just name the getter after the thing it retrieves:

```scala
trait Nameable {
  def name: String
}
```

### Names shadowing

Avoid clashes of the names with pattern matching, e.g. don't do this:

```scala
case class User(...)
case class Organization(owner: User)

val user = User(...)
...
organization match {
  case Organization(user) => ...  // user clashes with the above val
}
```

do e.g. this:

```scala
organization match {
  case Organization(owner) => ...
}
```

Names shadowing can be resolved by the IDEs, but nevertheless is a bad idea because it is very easy to mistake one variable for another. Use more appropriate names for each variable and pattern.

## Imports

### Imports order

Use the IDEA imports optimizer to sort imports. **TODO: add the snippet with the imports configuration** Source code files should not contain unused imports.

### Relative imports

Always use absolute imports; IDEA code style configuration enforces this. Relative imports almost always decrease the readability.

### Imports location

Always put imports at the top of the file instead of nested scopes. In other words, imports must always be grouped together in one place. 

### Wildcard imports

Avoid using wildcard imports, unless you're importing more than 6 items from the same package. This behavior is also enforced by IDEA.

## Braces

### Definitions

Avoid using braces for simple expressions; write this:

```scala
def square(x: Int) = x * x
```

but not this:

```scala
def square(x: Int) = {
  x * x
}
```

even though it may be tempting to distinguish the method body syntactically. The first alternative has less clutter and is easier to read. Avoid syntactical ceremony unless it clarifies.

### Scoping and blocks

It is acceptable to use braces in order to limit the namespace pollution, but this should almost always be used only when the result of the block is assigned to another variable:

```scala
val someValue = {
  val localVariable = ...
  ...
}
```

Moreover, using blocks to put complex expressions in other expressions, most notable function calls, hinders readability in a really bad way and should be avoided:

```scala
// bad
someFunction(arg1, arg2, {
  ...more code...
}, arg4)

// good
val arg3 = {
  ...more code...
}
someFunction(arg1, arg2, arg3, arg4)
```

## Comments

Use Scaladoc to provide API documentation. Use the following style:

```scala
/**
 * ServiceBuilder builds services 
 * ...
 */
```

but not the standard Scaladoc style:

```scala
/** ServiceBuilder builds services
  * ...
  */
```

Public API must always be documented with Scaladoc.

Write comments to clarify parts of logic which are not obvious, but *only* when it is absolutely impossible to rewrite the logic to be obvious in the first place. In general, try follow the rule "readable code comments itself".

`TODO:`-like comments are acceptable when they are really necessary but should not be overused.

# Type system

The primary objective of a powerful static type system is to reduce the number of bugs and other programming errors. Moreover, static type system often gives benefits in code readability and navigation (with the help of IDEs). However, overusing the type system in Scala leads to code which is very hard to understand. Therefore, most of the advanced techniques which are possible with the Scala type system must be avoided.

## Return type annotations

Scala allows one to omit return type annotations on `def`s. However, these annotations increase readability and help to avoid many issues with the type system, therefore all public-facing methods must have return types:

```scala
trait PublicInterface {
  def computeValue(input: String): AnotherEntity
}
```

This includes overrides in the classes extending the supertype:

```scala
class PublicInterfaceImpl extends PublicInterface {
  override def computeValue(input: String): AnotherEntity = {
    ...
  }
}
```

It is acceptable to omit return types for *short* local functions or private methods, but only when it is very clear what the return type is, for example:

```scala
def updatedUser(user: User) = user.copy(parameter = anotherValue)
```

Here it is clear that the returned value is `User`, and the function itself is short, so it is okay to omit the return type.

## Structural typing

Scala allows structural typing based on reflection, i.e. it is possible to define the interface which a variable should have directly as type:

```scala
case class Something(id: String)

val x: { def id: String } = Something("abcde")
```

Structural typing must be avoided in all its forms because it hurts both runtime performance and code readability and maintainability.

## Generics and variance

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

## Abstract (associated) types

Scala allows one to define abstract types in classes which then could be overridden in subclasses:

```scala
trait Container {
  type Item
}

class IntContainer extends Container {
  override type Item = Int
}
```

This feature is related to path-dependent types and very often leads to very confusing code, and therefore must be avoided at all costs.

Note that defining type aliases (which is also done with the `type` keyword) is perfectly fine; it's abstract types which are overridden with a concrete type are forbidden.

## Path-dependent types

Type members defined in classes are resolved relatively to the variable which contains an instance of such class:

```scala
class Container {
  type Item = Int
  val n: Item = 10
}

val x = new Container

val c1 = Vector[x.Item]()
```

In other words, it is possible for types to depend on the value, or, more correctly, on the "path" to the type, expressed in terms of values.

This is one of the most confusing features of Scala type system, and while it can lead to more type safe code when used correctly, it is very difficult to actually used it correctly, and it may produce quite incomprehensible errors.

Therefore, using path-dependent types is forbidden. There is almost always a better way to do something than  relying on them.

## Type aliases

Defining type aliases for complex types is encouraged. However, self-explanatory types need not to be aliased. The following is a bad example:

```scala
type IntMaker = () => Int
```

Type aliases should be used instead of subtyping, when this subclassing does not actually extend the original type.

```scala
// don't do this
trait SocketFactory extends (SocketAddress => Socket)

// do this
type SocketFactory = SocketAddress => Socket
```

Type aliases are best defined in the companion objects of the classes they are used in, but if a particular type alias is exposed as a part of an API or otherwise is used in common by many other modules, it makes sense to put it into the package object.

## `Any`, `AnyRef` and `AnyVal`

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

## `isInstanceOf`, `asInstanceOf`

These methods are often used in conjunction with `Any*` types, and thus should be avoided in the regular code. If you do need to check a runtime type of a variable, use pattern matching instead:

```scala
value match {
  case x: SomeType => ...
  case _ => ...
}
```

One of the most common applications of this pattern are algebraic data types which are described in their own section.

# Language features

## Implicits

Implicits comprise a very powerful part of the Scala language, however (or even therefore) they often lead to code which is very hard to understand if they are overused.

Implicits as a feature are used pervasively for many tasks across the entire Scala ecosystem, so it unfeasible to completely disallow their usage. In particular, they solve both the expression problem (adding new methods to existing types) and the cross-cutting concerns problem (using a single globally configured value in different places of code) transparently. However, they must be used sparingly, and only when their usage is motivated by a significant increase in readability or by the necessity to integrate with other libraries.

The general rule is as follows (quoting Twitter's Effective Scala):

> If you do find yourself using implicits, always ask yourself if there is a way to achieve the same thing without their help.

### Implicit conversions

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

### The expression problem, extension methods

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

### Implicit arguments

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

## `override` modifier

Scala requires `override` modifiers on items which override items with the same defined in the parent class, but it does not require it if these parent items are `abstract`:

```scala
abstract class Root {
  def x: Int = 10
  abstract def y: Int
}

class Child extends Root {
  override def x: Int = 12
  def y: Int = 42
}
```

However, you should always use `override` modifier even for implementing abstract methods. This makes the fact that the item actually "comes" from a parent class obvious and it allows accidental non-overrides, for example, as a side effect of refactoring, to be caught during compilation easily.

Note that you must use the `override` modifier even if you define the overriding field as a part of constructor arguments declaration:

```scala
trait Entity {
  def id: String
}

case class User(override val id: String) extends Entity
```

## `abstract override` modifier

Scala allows to "incrementally" extend a root trait, delegating to linear supertypes in a sequential manner. One of the most common usages of such feature is to create a collection of some items provided by separate trait implementations. This can be used, for example, to implement some kind of module system:

```scala
trait Modules {
  def modules: Vector[Module]
}

trait EmptyModules extends Modules {
  override def modules: Vector[Module] =
    Vector.empty
}

trait PluginAModules extends Modules {
  abstract override def modules: Vector[Module] =
    super.modules :+ pluginAModule
}

trait PluginBModules extends Modules {
  abstract override def modules: Vector[Module] =
    super.modules ++ Vector(pluginBFirstModule, pluginBSecondModule)
}

class FinalModules
  extends EmptyModules
  with PluginAModules
  with PluginBModules

println(new FinalModules().modules)  // prints Vector(pluginAModule, pluginBFirstModule, pluginBSecondModule)
```

Another use of `abstract override` is to implement static chain of responsibility pattern, when all chain elements are compiled statically.

`abstract override` is difficult to get right, and it is extremely confusing because it is often very hard to understand in which order traits methods are called. For this reason using `abstract override` is forbidden. There are almost always better ways to do the same thing.

## Pattern matching

Pattern matching is used everywhere in Scala.  Pattern matching combines conditional execution, destructuring and casting in one construct. It is one of the tools which are able to increase both clarity and safety of the code at the same time.

When you pattern match on an ADT, prefer extracting values instead of accessing them with the method notation. In other words, write this:

```scala
animal match {
  case Dog(name) => s"A dog named $name"
  case other => "Someone else"
}
```

instead of this:

```scala
animal match {
  case dog: Dog => s"A dog named ${dog.name}"
  case other => "Someone else"
}
```

However, if a case class contains lots of fields, and you only need a handful of them, use the latter syntax because it would make the code less cluttered, and it would be harder to make a mistake when selecting a field to extract:

```scala
component match {
  case Composite(_, _, _, _, children, _, _) =>
    processComponents(children)
  case _ => ...
}
```

versus

```scala
component match {
  case composite: Composite =>
    processComponents(composite.children)
  case _ => ...
}
```

### `unapply` methods

Scala allows to define a special method on a object called `unapply`. Objects with such methods can be used in the patterns to extract values using this method:

```scala
case class Reference(entity: String, parameter: String) {
  override def toString: String = s"$entity.$parameter"
}

object Reference {
  def fromString(s: String): Option[Reference] = s.split(".", 2) match {
    case Array(entity, parameter) => Some(Reference(entity, parameter))
    case _ => None
  }
}

object ReferenceString {
  def unapply(s: String): Option[Reference] = Reference.fromString(s)
}

someString match {
  case ReferenceString(Reference(_, parameter)) =>
    println("Parameter: $parameter")
  case _ => ...
}
```

It is hard to remember how `unapply` methods should be defined, and their overuse makes the code less readable, so they should not be used unless they significantly improve readability, e.g. when their functionality is used in many places in the code base.

`unapply` methods must never be defined in regular classes, only in objects.

## Multiple parameter lists

Scala allows defining multiple parameter lists on methods and classes:

```scala
def compare(x: Int)(y: Int): Int = x - y

case class User(name: String, password: String)(secret: String)
```

This feature affects type inference across parameters list and in the case of case classes it excludes all members of the non-first parameter lists from the `equals`, `hashCode` and `unapply` implementations.

The latter point especially very often causes code which relies on multiple parameter lists to be confusing. Therefore, using them in general is forbidden.

There are two use cases for which multiple parameters lists are allowed. The first one is definition of implicit arguments (see the respective section above):

```scala
def doSomeWork(arg: String)(implicit ec: ExecutionContext) = ...
```

The second one is when the second parameter list is used to accept a single functional value:

```scala
def run(x: Int)(f: Int => String): String = f(x)

run(10) { x => x.toString }
```

Multiple parameter lists here allow using more concise syntax for passing an anonymous function which increases readability. That said, the need to declare such functions in itself should be rare, because of the rule against DSLs.

The second use case, however, does not extend to multiple parameter lists which accept functions; in other words, something like the following is not allowed:

```scala
def computeAnswer(onComplete: Int => Unit)
                 (onFailure: Throwable => Unit) = ...

computeAnswer { x => println(x) } { e => e.printStackTrace() }
```

If you do need to create a function which, for example, accepts multiple callbacks, use named parameters instead:

```scala
def computeAnswer(onComplete: Int => Unit,
                  onFailure: Throwable => Unit) = ...

run(
  onComplete = { x => println(x) },
  onFailure = { e => e.printStackTrace }
)
```

## Symbolic methods and infix and postfix notation

Scala allows to define methods which consist of symbols instead of regular letters. Combined with  the ability to call any method with the infix notation this allows one to define custom operators:

```scala
class Connectable {
  def =+~>(other: Connectable): Connectable = ...
}

val x = new Connectable
val y = new Connectable
x =+~> y
```

Symbolic method names do not convey what they do, and with the exception of regular well-known symbols (mathematical operations, `++`/`--` on collections, boolean operators, negation, etc.) tend to be obscure by themselves: `a =+~> x` could mean absolutely anything.

Therefore it is prohibited to define custom symbolic methods, while their use with the 3rd-party libraries should be as limited as possible. Naturally, using unicode characters, which is also allowed by the language, strictly prohibited as well.

Additionally, using the infix notation for calling regular, non-symbolic methods is discouraged and could be used only if it significantly increases readability. One example of a sufficiently motivated use of infix notation are matchers and other parts of the tests definition in ScalaTest.

Scala also allows calling methods using the postfix notation, when there is no dot present in the method call:

```scala
import scala.concurrent.duration._

val d = 10 minutes
```

Postfix method calls are forbidden in any form because they may lead to syntactic ambiguities. Dots should always be used instead:

```scala
val d = 10.minutes
```

## Apply method on classes

`apply()` method allows to use an object with the function call syntax. With the exception of functions, this may lead to very obscure code; additionally, it may be hard to go to the definition of such method in an IDE.

For these reasons defining `apply()` method on classes is forbidden, unless these classes extend one of the standard functional traits. Defining an `apply()` method on `object`s is fine, however: this is a pretty well-known idiom for creating constructor functions:

```scala
class SomeContainer private () { ... }

// This is okay
object SomeContainer {
  def apply(name: String): SomeContainer = {
    val result = new SomeContainer()
    ...
    result
  }
}

// This is not
class CustomFunction {
  def apply(x: Int): String = "'$x'"
}

val f = new CustomFunction
f(10)
```

## Call by name

Call by name is a way to "defer" the computation of a value passed into a function as an argument. It is a counterpart to the regular "call by value", when the argument to a function is computed entirely before the function is called:

```scala
def square(x: Int) = x * x

def squareByName(x: => Int) = x * x

def x: Int = { println("Computing x"); 8 }

square(x)        // prints "Computing x" once
squareByName(x)  // prints "Computing x" twice
```

Call by name allows the called function to determine when to compute its argument. This allows building incredibly powerful custom control structures, but it may also be a great source of confusion for the developer reading the code which uses such control structures.

Therefore, using call by name arguments is forbidden, unless its usage significantly increases readability. In general, if you need to get the semantics of a deferred computation, use a no-arguments function explicitly:

```scala
def squareDeferred(x: () => Int) = x() * x()

squareDeferred(() => x)
```

This syntax makes the fact that the value is computes multiple times clearly visible, both in the call site and in the called function.

## Return statements

Scala allows using return statements in order to return from methods early. However, Scala is primarily an expression-based language, therefore using imperative constructs like returns usually hurts readability.

Moreover, `return` statements are always bound to the enclosing `def`, therefore, if `return` is used e.g. inside a closure, it results in a `try/catch` for a `NonLocalReturnControl` exception generated by the compiler.

The general rule is to avoid using `return`s, however, there are cases when they do increase the clarity of the code. Therefore, whether they are appropriate or not should be decided on a case-by-case basis during code review. Basically, `return` is allowed for the following cases:

```scala
// As a guard to simplify the control flow:
def doSomething(input: String): String = {
  if (!valid(input)) {
    return "something went wrong"
  }
  ...
}

// As an early return from loops
while (condition) {
  if (somethingHappened) {
    return
  }
}
```

## Macros

Scala language supports defining macros, which basically are compile-time transformations of source code. Macros usually have access to the entire information about your code which is available to the compiler, including types, which allow implementing very powerful patterns, like generating boilerplate code for structured types like case classes automatically.

However, the current version of macros is notoriously hard to write. The code of macro definitions is usually very obscure. Also macros are often used to create custom DSLs, which not only require reading the source code of the macro to be understood completely, but also often upset the IDE syntax highlighters.

For this reason writing custom macros is forbidden in general. Using macros from other libraries, like serialization, is not disallowed, unless they hinder the readability.

## Exception handling

See the section about error handling for more information about error handling in general. This section is dedicated to the exception handling specifically.

Always use braces with the `try-catch-finally` construct, even if the body of the `try` contains one expression:

```scala
// bad
try doSomething()
catch {
  ...
}

// good
try {
  doSomething()
} catch {
  ...
}
```

Do not catch `Throwable` or ignore exceptions inside `catch` clauses; never *ever* ignore the caught exceptions; at the very least you should log them:

```scala
try {
  ...
} catch {
  // this is wrong
  case e: Throwable => ...
}

try {
  ...
} catch {
  // this is VERY wrong
  case _ =>
}
```

Use `scala.util.control.NonFatal` in case you need to catch "all" exceptions:

```scala
try {
  ...
} catch {
  case NonFatal(e) => logger.error("Something bad happened", e)
}
```

Never write any non-local control flow instructions in the `finally` blocks. This includes `return`s, `throw`s and calling functions which may throw exceptions:

```scala
try {
  ...
} finally {
  // VERY bad
  throw AnotherException()
}
```

## Operation chains

Many of the standard and non-standard Scala types contain so-called monadic operators, most notable of them being `map`, `flatMap` and `filter`. Scala collections provide many more operations which can also be chained in the same way.

This is a very powerful tool which allows expressing complex patterns very concisely. However, precisely for this reason - because such chains allow the code to be very dense in terms of meaning per line of code - chaining should be used sparingly.

In general, follow these rules:

1. Avoid chaining more than a few operations. The actual number will vary depending on the situation, but it usually should not be more than 5-7 operations at max. Split longer chains by creating temporary variables.

2. As a follow-up to the previous rule, the maximum number of chained operations heavily depends on the size of the code which is passed to the combinator functions. In other words, you should chain less operations if the lambdas you used are relatively large. The opposite does not hold, however: you shouldn't chain more operations just because your lambdas are small; while this may make sense depending on the situation, splitting chains and saving parts of expressions in separate variables is almost always a good thing.

3. As a rule of thumb, if understanding what a particular sequence of operations does takes more than 5-10 seconds, you should try to rewrite it in a simpler way.

Here is an example copied from the Twitter's Effective Scala:

```scala
val votes = Seq(("scala", 1), ("java", 4), ("scala", 10), ("scala", 1), ("python", 10))
val orderedVotes = votes
  .groupBy(_._1)
  .map { case (which, counts) => 
    (which, counts.foldLeft(0)(_ + _._2))
  }.toSeq
  .sortBy(_._2)
  .reverse
```

This piece of code is incomprehensible to anyone except its original author, and even they will forget what they meant in a very short time. Splitting the chain in logical parts and avoiding tuple accessors in favor of using named parameters allows to make the code much clearer:

```scala
val votesByLang = votes groupBy { case (lang, _) => lang }
val sumByLang = votesByLang map {
  case (lang, counts) =>
    val countsOnly = counts map { case (_, count) => count }
    (lang, countsOnly.sum)
}
val orderedVotes = sumByLang.toSeq
  .sortBy { case (_, count) => count }
  .reverse
```

## Operations nesting and `for` comprehensions

`for` comprehensions are a very nice syntactic sugar in Scala which allows expressing certain patterns in a very clean way. Of course, just like any other feature, it is crucial not to overuse it.

As a rule of thumb, prefer `for` comprehensions to nested `flatMap`s and `map`s, for example, when you need to flatten several collections. `for` comprehensions are rewritten internally into a nested sequence of method calls, so be careful for using `for`s in performance-critical code.

Be aware of implications of using `for` comprehensions for futures. See the section on concurrency for more on that.

### Using `for` comprehensions for different types

`for` comprehensions may be used with types which have `flatMap`, `map` and `withFilter` methods, and they do not guard you from using different types for each binding clause if it is allowed by typing:

```scala
val ints = Vector(1, 2, 4, 5)
val m = Map(1 -> "a", 3 -> "c")

for {
  n <- ints
  s <- m.get(n)
} yield s
```

This compiles, even though `ints` is of type `Vector[Int]` and `m.get(n)` is of type `Option[String]`. This is compiled into

```scala
ints.flatMap(n => m.get(n))
```

`flatMap` on Scala collections allows its argument function to return anything convertible to an iterable, and `Option[T]` satisfies this requirement. This makes the code harder to understand and, in some subtle cases, may lead to unexpected behavior, in particular, when collections with uniqueness semantics of keys or values (like maps or sets) are used. Therefore, in most cases when you need to iterate over multiple collections in a nested fashion, convert them to a common type. Usually it makes sense to use `.iterator` for that:

```scala
val resultsIterator = for {
  (interface, peers) <- signals.iterator
  (peer, values) <- peers.iterator
  value <- values.iterator
} yield interface -> value

val results = resultsIterator.toMap
```

## String interpolation

Scala allows writing references to other variables in scope inside strings using a special syntax:

```scala
val n = 10
println(s"The value is $n, for your information")
```

This syntax should be used instead of string formatting:

```scala
// bad
println("The value is %s, for your information".format(n))
```

and instead of explicit concatenation:

```scala
// also bad
println("The value is " + n + ", for your information")
```

String interpolation is both more concise and more performant than its alternatives, and it makes the code more readable.

Avoid using long expressions inside the string, though; if computation is long, store it in a lazy variable or a `def`:

```scala
val results: Map[String, Either[Vector[Error], Unit]] = ...

// bad
logger.error(s"Errors happened: ${errors.valuesIterator.flatMap(_.left.toOption).flatten.mkString(", ")}")

// good
def errorsIterator = for {
  result <- results.valuesIterator
  errors <- result.left.toOption.iterator
  error <- errors.iterator
} yield error

def errorsString = errorsIterator.mkString(", ")

logger.error(s"Errors happened: $errorsString")
```

The good variant is longer, but its intention is clearer for an unaccustomed reader. As a general rule, avoid nested braces inside the interpolated string. For example, nested field access is fine:

```scala
val message = "Owner name: ${organization.owner.name}"
```

But method calls should better be extracted to a separate `def`:

```scala
// bad
val message = "Owner email: ${organization.owner.email.getOrElse("<unknown>")}";

// better
def ownerEmail = organization.owner.email.getOrElse("<unknown>");
val message = "Owner email: $ownerEmail"
```

## Tuples

Tuples are ubiquitous in Scala; they are used very often to carry around values of several different types together. Maps in Scala use tuples to represent their entries. However, tuples have a big drawback: they do not assign semantic meaning to the structure they represent.

It is acceptable for use cases when they are used extremely frequently, and the lack of such meaning is not harmful: map entries is a prominent example of this. However, avoid storing them in data structures as fields or as values of a collection, because it only makes things obscure. Compare:

```scala
val actions: Map[(String, String), (Cancellable, Deadline, String)] = ...

// vs

case class PropertyId(interface: String, key: String)
case class ScheduledAction(timer: Cancellable,
                           finalDeadline: Deadline,
                           payload: String)
val actions: Map[PropertyId, ScheduledAction] = ...
```

Case classes essentially are named tuples, and it is very easy to define them in Scala, so don't hesitate to do it.

This gets even more prominent when there is a need to access individual fields, for example, when iterating. Do not ever write this:

```scala
val joinedPayloadByInterface = actions.iterator
  .map(kv => kv._1._1 -> kv._2._3).toVector
  .groupBy(_._1)
  .map(kv => kv._1 -> kv._2.mkString)
```

This is much better:

```scala
val joinedPayloadByInterface = actions.iterator
  .map { case (propId, action) => propId.interface -> action.payload }
  .toVector
  .groupBy { case (interface, _) => interface }
  .map { case (interface, payloads) => interface -> payloads.mkString }
```

And even this is rather complex; split the chained operations into several variable bindings:

```scala
val singlePayloadByInterface = actions.iterator
  .map { case (propId, action) => propId.interface -> action.payload }
  .toVector

val allPayloadsByInterface = singlePayloadByInterface
  .groupBy { case (interface, _) => interface }

val joinedPayloadByInterface = allPayloadsByInterface
  .map { case (interface, payloads) => interface -> payloads.mkString }
```

This way the intention of the code is very clear even to a relatively casual reader.

# Patterns and architecture

Scala is a multi-paradigm language, combining elements from functional and object-oriented programming. However, this is dangerous combination which may result in a very obscure code, if patterns and features from both paradigms are used indiscriminately.

As a general rule, object-oriented patterns should be used to model the high-level architecture of the program, while functional patterns should be used locally, to write the actual implementation code. Think of object-oriented design as a strategy, and of functional patterns as tactics: apply the commonly known object-oriented patterns when it is necessary to structure the overall program structure, and use functional idioms when you're writing concrete code which manipulates concrete data. For example, don't hesitate to use patterns like facade or adapter when you're designing your class structure, but when you actually begin to fill these classes with implementation, use functional patterns like immutability, optional values and operations on collections instead of what you would do in Java, like imperative loops and mutable collections.

Of course, it is sometimes difficult to make a clean separation, for example, relying on immutability leads to creation of many ADTs, which definitely affect the high-level structure of the program, and vice versa, using dependency injection patterns have very noticeable effect on the concrete implementation. But this approach allows ruling out harmful practices like using high-level functional idioms to structure the overall program (e.g. trying to design the entire program workflow as a monad transformer stack) or blindly using object-oriented patterns to structure low level code (e.g. using virtual dispatch with a trait hierarchy where a simple match would do nicely).


## Cake pattern

See the full rule description [here][cake-pattern].

In short, while the cake pattern is nice in theory, it is hard to get it right and take all the necessary things like dependencies lifetime into account. It also makes testing more difficult as the number of dependencies of different cake components grow.

Therefore, the cake pattern must not be used to structure dependencies of different components. Other, more conventional tools like dependency injection libraries or even manual dependency passing should be used instead.

  [cake-pattern]: https://github.com/alexandru/scala-best-practices/blob/master/sections/3-architecture.md#31-should-not-use-the-cake-pattern
  
## Type classes

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


## Error handling

Exceptions are ubiquitous in the JVM ecosystem, however, by their nature they may make control flow less understandable and clear because they are essentially nonlocal returns - they bubble up the call stack without explicit return statements.

Therefore, basing the control flow on exceptions is discouraged. Not only does it make the code less obvious, it also has performance implications - stack unwinding is not free. Do not use exceptions as a substitute for regular control flow instructions.

### Encoding errors in types

Exceptions should be used, as their name states, in exceptional situations, i.e. when something went wrong and the program cannot continue further because of a broken invariant. This means that you should not use exceptions when it is possible for an error to occur and you want the user of your code to handle it. In such cases errors should be encoded explicitly, using `Option`, `Try`, `Future` or `Either`-like types.

All rules described in the section on using chained method calls apply to the `Try` values, of course.

## Functional programming

Functional programming can loosely be defined as a paradigm which treats computation as a sequence of evaluations of mathematical functions. This implies that it places emphasis on avoiding mutable state and side effects and is heavily based around returning and combining expressions. Among language features usually associated with functional programming are first-class functions, immutability of data, lack of side effects (pure and referentially transparent functions), recursive computations instead of imperative loops, and so on.

Design of the Scala language strongly favors the aforementioned functional programming practices. To make them easy to implement, Scala provides tools like case classes, pattern matching, type inference, lightweight closure syntax and powerful built-in collections library. Moreover, a major part of the standard Scala library is designed using functional idioms, and many of the popular community libraries follow suit.

### Immutability

Immutability of data is one of the cornerstones of the functional programming. It may sound very limiting to those who are accustomed to the conventional imperative languages like C/C++ or Java, but when immutability has proper support in the language, it allows writing much cleaner code with stronger invariants, and which is also thread-safe by default.

Therefore, as a general rule, avoid creating objects with mutable state. In particular, algebraic data types (see the section below) must not have `var` members, as well as indirectly mutable things like mutable collections.

Mutability on the method level, i.e. using local `var`s and mutable structures, should also be avoided as much as possible. There are times, however, when relying on mutability does make the code clearer and/or is required for performance reasons. In that case mutability should be isolated: the public interface should avoid exposing the mutability used to implement it.

### Algebraic data types

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

#### Sum types declarations

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

#### Enumerations

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

### Options and `null`

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

### Recursion

Recursion is often very natural for certain algorithms, especially on recursive structures like trees and lists. In many cases, however, recursion tends to make the code obscure.

Always try to solve the problem without explicit recursion first. Scala collections library provides lots of combinators which make explicit recursive traversals unnecessary in many cases.

If a problem cannot be solved with pre-defined, combinators, compare the imperative version using loops and recursion first. In many cases, especially when the logic is not very large, imperative implementation may be simpler than recursion. In other cases, recursion would be clearer.

When writing recursive functions, try to write them in a tail-recursive way, enforced by the `@tailrec` annotation. Tail-recursive functions will be optimized by the compiler into an imperative loop. However, tail-recursive functions may require passing lots of state in an accumulator parameter. Sometimes rewriting such functions using imperative loops may make the code nicer.

## Object-oriented programming

Scala is a powerful object-oriented language; if fact, it is even more pure than Java. Everything in Scala is an object, and its facilities for object-oriented design are very expressive and convenient. Naturally, most of object-oriented design practices are possible in Scala; they are described in numerous forms in various books and articles and therefore are omitted here. In this document we will examine Scala-specific features which help with the object-oriented programming.

### Dependency injection

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

### Traits

Traits in Scala are very versatile and are used for many purposes. One of the roles of traits in Scala are Java-like interfaces, i.e. statically defined contracts which are extended by other classes which are intended to provide these contracts. Another role are mixins, which are a way to combine pieces of common functionality. Even another role, as can be seen from the section on ADTs, is to serve as a marker type for sum data types.

#### Intention

Traits can be roughly divided in two groups: interface traits and mixin traits. Interface traits are intended to declare contracts for the implementing classes, while mixin traits are needed to share common functionality. Do not mix these "kinds" of traits: if a trait is declared as an interface, it must only be used for this purpose, and if it is declared as a mixin, it must not be used as an interface, for example, it should not be used as a type for variables. Think of it as a variant of the single responsibility principle, but on a higher level.

#### Members

As a rule of thumb, always define all members of traits as `def`s. `def` is the most general variant of a class member, and it may be overridden with any other kind of member: `val`, `lazy val`, `var` and `def` are all allowed.

Sometimes it makes sense to declare a member as `val` instead of `def`, but cases when it is necessary are exceedingly rare. Never define `var`s or `lazy val`s as abstract members.

#### Complexity

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

#### Traits with implementation

Traits in Scala can contain implementations for their methods. When a trait is used as an interface trait, it may make sense to add a method which delegates to other methods of the same trait to create a shortcut for the users of the interface. For example:

```scala
trait JsonWriter[T] {
  def write(value: T): JsonTree
  
  final def writeString(value: T): String = write(value).toString
}
```

These utility methods should almost always be declared as `final`.

### Visibility

Scala has very powerful visibility modifiers. It is possible to restrict visibility of an item in a very fine-grained way. Using them is very important for limiting the surface of your API. It is always easier to add new methods to the API than to remove them, because if you publish something, someone may start to depend on it, and removing it back or changing it would be very difficult without breaking the clients' code.

So, as a general rule, always make class and package members as less visible as possible. By default, make all items of a class `private`; you can always expose them at any time later, but hiding them back won't be easy in general.

One important case of visibility modifiers is `private[this]`. Regular `private` items are accessible from all instances of the class, while `private[this]` is accessible only within a single instance. Scala compiler is able to translate accesses to `private[this]` variable members directly to the field access, which may result in performance optimization.

### Class nesting

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

## Domain-specific languages (DSLs)

Scala is a very DSL-friendly language, because of certain features which make writing embedded DSLs easy:

* by-name arguments;
* symbolic method names;
* infix method calls;
* implicits.

DSLs may be immensely expressive and compress huge amounts of meaning into a few lines of code. And precisely because of this reason they tend to be impenetrable for a reader who does not know these DSLs in advance.

Therefore, it is strictly forbidden to create custom domain-specific languages, even if they do increase readability locally. Domain-specific language implementations are hard to maintain, and they make difficult for new developers to dive into the code base. Prefer less fancy solutions for the problems at hand.

Moreover, using DSLs provided by third-party libraries should also be avoided, unless these libraries are very important to make the work done (e.g. if they are a transitive dependency of some framework) or are the only ones which provide the necessary functionality. First, try to avoid using the DSL, if the library provides the same functionality without it. If it is not possible, and using a DSL is unavoidable, explain everything which is not clear at the first glance thoroughly in comments.

# Libraries

Scala ecosystem contains vast amount of libraries virtually for any purpose, and since Scala is a JVM language, it can seamlessly interact with native Java libraries, which increases the pool of libraries even further. However, we must be discreet in which libraries we choose. There are basically the following points which should be considered here:

* Some libraries simply do not have high enough quality to be useful and reliable.
* There are libraries which rely heavily on the most obscure features of the language; while these libraries may solve the corresponding problems in a very succinct way, very often they make the code which uses them very hard to read, especially for people who do not know that library.
* There are libraries which expose complex concepts, which (regardless of the language features they rely on) require considerable background knowledge to be used and understood quickly.
* Java-only libraries require certain precautions for them to be used from Scala correctly. One of the most important and common concerns for using Java libraries in idiomatic Scala code is null safety.

One of the declared goals of this document is to keep the code base cleaner, approachable and maintainable. Virtually any relatively complex program uses tens of libraries directly and even more transitively. Therefore, we must choose which libraries we use and how we use them with utmost care, because their implementation and their API affect our own code greatly.

## Collections

Scala has a very powerful collections library, which contains immutable, mutable and parallel collections for virtually any purpose. While its implementation is quite complex, and extending it may be hard and would require using complex language features like higher-kinded types and implicits, in the everyday work it is very easy to use. To use the collections library efficiently, it is highly recommended to read [the official overview](http://docs.scala-lang.org/overviews/collections/introduction.html) of the collections library first.

### Overview

Here is a diagram of the basic collection types, both mutable and immutable:

**TODO (traversable, iterable, seq, set, map)**

The base trait, `Traversable[T]`, represents something which can be internally iterated - it provides a `foreach(f: T => Unit)` method which calls its argument for every item contained in the collection. This trait is very general and it can describe not only regular collections like lists or sets, but also e.g. ephemeral streams of data.

`Iterable[T]` is something which can be externally iterated - being quite similar to Java's `Iterable<T>`, it has one method, `def iterator: Iterator[T]`, which returns an iterator which can be used to walk over the collection. `foreach()` implementation for an `Iterable` is trivial, therefore it extends `Traversable`.

`Seq`, `Set` and `Map` are base types for the respective "kinds" of collections. `Seq`s are collections whose items are laid out sequentially and therefore can be accessed using zero-based index. `Set`s are collections which cannot contain duplicate elements, and usually have effective membership check. `Map`s are collections of key-value pairs where keys are unique, and they usually have effective lookup by key.

There is one weird quirk of the standard Scala library which should always be taken into account. `Map` and `Set`, when used in the regular code without any special imports, come from `scala.Predef` object (whose internals are imported into every Scala file automatically), and there they are declared as aliases to `scala.collection.immutable.*` types:

```scala
type Map = scala.collection.immutable.Map
type Set = scala.collection.immutable.Set
```

On the other hand, the alias for `Seq` is declared in `scala` package object, and it points to the root `scala.collection.Seq` type:

```scala
type Seq = scala.collection.Seq
```

Therefore, without any extra imports, variables with `Seq` type can hold both mutable and immutable collections, while `Map` and `Set` can hold immutable collections only. This inconsistency is quite jarring, but there is no simple way around it, and one must only remember how things are. The consequence is that using `Seq` is discouraged, but using `Map` and `Set` is fine.

### Usage

#### Collection constructors

When creating new instances of collections, use the default constructor for collection types, unless you do need a specific collection type for some purpose (e.g. `TreeSet` for ordered iteration):

```scala
val set = Set(1, 2, 3)
val map = Map("a" -> 1, "b" -> 2)
```

There is one exception from this rule: use `Vector` where possible to create instances of `Seq` type instead of the default `Seq` constructor:

```scala
val seq = Vector(1, 2, 3)
```

The rationale for this rule is that `Vector` collection is almost always preferable to `List`, and the `Seq` default constructor delegates to the `List` constructor.

The reasons why `Vector` should be preferred are listed, for example, [here](http://stackoverflow.com/questions/6928327/when-should-i-choose-vector-in-scala). In short, `Vector` is faster than `List` for almost all operations and is more memory-efficient. Because it is a trie consisting of arrays, memory and cache locality are also better for `Vector`. Unless you're writing a "hot" algorithm which heavily depends on a list-like structure (prepending to a collection and accessing its head and tail), `Vector` would perform better than `List`, and therefore should always be used. It is also harder to accidentally index a sequence in an inefficient way whey `Vector`s are used instead of `List`s.

And another reason for using concrete method is that the overall usage of `Seq` is discouraged (see the previous section).

Use `Collection.empty` to create empty instances of collections instead of `Collection()`:

```scala
var cache: Map[String, Item] = Map.empty  // not Map()

var queue: Vector[Item] = Vector.empty  // not Vector()
```

Using the explicit `.empty` method helps readability, since with it you're stating that you need an empty collection explicitly.

#### Collection types

Use `Map`, `Set` and `Vector` as default types for returning values from functions, for storing values in ADTs and for variables and fields:

```scala
def createUsers(params: Whatever): Vector[User] = ...

case class Application(parameters: Map[String, String])

class SomethingDoer(parameters: Parameters) {
  private val itemsCache: Set[Item] = computeItemsCache(parameters)
  ...
}
```

Of course, that is unless some specific collection type is necessary for its operations and/or semantics.

Use the most general type available for parameters of a method:

```scala
def processItems(items: Traversable[Item]): Unit = ...

def transformItems(items: Iterable[Item]): Vector[Item] =
  items.iterator.filter(_.someCondition).map(transform).toVector

def needsAMap(map: Map[String, Int]): Int = map.getOrElse("x", 0)
```

#### Mutable collections

Always prefer immutable collections to mutable ones. Being immutable, they make it easier to reason about their usage, and they are also thread-safe by default. Mutable collections should be used only for performance reasons (if they are mutated frequently, they may be faster than immutable collections stored in a `var`) and for certain classes of algorithms which are clearer when are based on a mutable collection.

If you decided to use a mutable collection, the `mutable` package name must always be imported and used instead of importing the collection name directly:

```scala
import scala.colleciton.mutable

val items: mutable.Map[String, Int] = mutable.Map.empty
```

If you use IntelliJ IDEA, it enforces this style for mutable collections.

#### Interacting with Java collections

Avoid using Java collections, unless they are needed for interfacing with Java code. In order to transform Scala collections to Java collections and back, use the implicit `asJava*` and `asScala*` methods imported from `scala.collection.convert.{decorateAs*}` objects:

```scala
import scala.collection.convert.decorateAsJava._

someJavaMethodAcceptingList(Vector(1, 2, 3).asJava)
```

Never use `scala.collection.convert.wrapAs*` objects, as well as `scala.collection.JavaConversions`, which provide implicit conversions to Java classes, as opposed to decorators. `scala.collection.JavaConverters` is functionally equivalent to `scala.collection.convert.decorateAll`, but objects defined in `scala.collection.convert` package are more granular and convey the intention better, therefore avoid using `JavaConverters` in favor of `decorate*` objects.

#### Transformations and iterators

When you're chaining more than one collection operation, or when you're transforming an original collection type (e.g. a set of identifiers) to another collection type (e.g. a map of identifiers to the things they identify), it is recommended to transform the collection to an iterator first and then do all transformations on the iterator instead of the original collection, and then collect the resulting iterator to the final collection:

```scala
val itemIds: Set[String] = ...

val itemsIterator = itemIds.iterator.flatMap(itemsDao.findById)
val itemsByName = items.map(item => item.name -> item).toMap
```

The reason for this recommendation is that all transformations on collections create intermediate collections as their results:

```scala
val items = itemsIds.flatMap(itemsDao.findById)  // items: Set[Item]
val itemsByName = items
  .map(item => item.name -> item)  // <temporary>: Set[(String, Item)]
  .toMap
```

When transformations are done on iterators, no intermediate collections are created, and the chain of transformations of iterators is done lazily. Operations like `toMap/toSet/toVector` or `fold/reduce` eagerly consume the iterator, creating the final collection in one go.

Note that not all operations are available on iterators, like `groupBy`. Also, if you need to reuse the intermediate result multiple times, be sure to collect it to a concrete collection first, because iterators can only be used once:

```scala
val items = itemIds.iterator.flatMap(itemsDao.findById).toVector
val itemsByName = items.iterator.map(item => item.name -> item).toMap
val itemsById = items.iterator.map(item => item.id -> item).toMap
```

If you're using `for` comprehensions, you can convert various types, e.g. `Option`s, to iterators to make sure that all types are uniform and there is no funny behavior e.g. with maps or sets (where because of the uniqueness constraint of elements it is possible for mapped elements to be dropped silently). The above examples are actually better written as a `for` comprehension:

```scala
val itemsByNameIterator = for {
  itemId <- itemIds.iterator
  item <- itemsDao.findById(itemId).iterator
} yield item.name -> item
val itemsByName = itemsByNameIterator.toMap
```

When you assign iterators to variables, name the variables with `Iterator` suffix to distinguish them from regular collections.

An alternative to iterators would be using collection views, which are essentially reusable iterators. However, views in Scala implement the same interfaces as regular collections, and therefore it is easy to store e.g. `MapView` as a `Map`. This is bad, because transformations applied to views are not executed eagerly, they are delayed until elements of the view are accessed, just like with iterators. When such a view is stored in a frequently used variable, all these transformations will be recomputed each time when elements of the view are accessed.

If you're doing only a single transformation operation, and you need to get a collection of the same type as the original collection, omit the iterator conversion because the necessary type will be constructed automatically:

```scala
val itemIds: Set[String] = ...
val items: Set[Item] = itemIds.flatMap(itemsDao.findById)
```

## Concurrency

Concurrency is a very complex topic, and is one of the most common source of bugs. JVM in general and Scala in particular provide lots of tools, libraries and frameworks which help working with concurrency and abstract away the low-level details of thread management, but introduce another level of semantics which should also be understood by the developer in order not to make more bugs. Therefore, choosing the particular tool should be done judiciously.

Instead of rephrasing the same things in different words, we suggest reading [the relevant chapter](https://github.com/alexandru/scala-best-practices/blob/master/sections/4-concurrency-parallelism.md) of the Scala Best Practices document. Consider its items to be fully applied by this document as well.

## Other Scala libraries

Scala ecosystem contains lots of libraries which often provide very convenient and powerful tools to solve various tasks, but at the same time they are often based on rather obscure concepts from the mathematical foundations of the programming (like category theory or abstract algebra) or are otherwise complex to understand.

One of the explicit goals of the document is to allow as much developers as possible to work with the code without previous knowledge of abstract mathematical concepts. Unfortunately, many popular libraries in Scala community are explicitly based on these concepts. Moreover, these libraries still provide convenient tools (like `Validation` or `Xor/Ior` types) which are used ubiquitously in the Scala community and are actually very simple to understand, but still integrated with the rest of the complex math-based machinery these libraries contain. Therefore, we must be very careful to decide what we would like to use in our code and what we would like to avoid entirely.

In general, it is recommended to avoid libraries which provide complex DSLs, as well as libraries which introduce and/or are based on complex concepts, like Scalaz (which, accidentally, also uses lots of symbolic identifiers). These libraries *are* helpful, and they *do* solve important problems, but when they are overused (and they do tend to be overused), they raise the complexity of the code, sometimes quite significantly, and they make introducing new people to the project harder, because they often require from the reader the knowledge of abstract concepts, e.g. from algebra or category theory.

## Java libraries

Scala runs on JVM, which gives an enormous advantage of having access to the whole JVM ecosystem, including all existing Java libraries. However, many of these libraries use Java-specific idioms, which often go against Scala idioms.

One of the most important thing when working with Java code is to take `null`-safety into account. Lots of Java libraries either accept null values or return them, either intentionally (for example, `java.util.Map` has it as a part of its API) or not (because of the programmer's negligence). Idiomatic Scala code does not use `null`s (and actually in these guidelines using `null` is expressly forbidden), therefore they should always be handled in the boundary code between the Scala codebase and Java library, for example, by wrapping a value with a possible `null` to an `Option`. Remember, `Option.apply` method (usually written in a functional notation like `Option(someValue)`) checks its argument for null and returns `None` if it is actually a `null`.

Another point is exception-safety. Lots of Java libraries signal errors through exceptions. The idiomatic Scala way is to encapsulate errors which should be handled by the user to an ADT like `Either` or `Try`, therefore, always consider which exceptions a Java library method throws and think if these exceptions are better represented as error values in Scala code. The general rule to follow here is that if these exceptions signify a programmer error, like passing an invalid value for an argument, it is fine not to catch them, but if these exceptions affect the business logic and are likely to happen during the normal flow, they should be caught and transformed to values.

And finally, try to prevent Java libraries from "creeping" into the code base. That is, create idiomatic Scala wrappers around these libraries (or better yet, find an already existing wrapper) which encapsulate all Java-specific quirks and provide an idiomatic Scala API instead of using these libraries everywhere in your code.

# Reference for code reviewers (TODO)

This section summarizes the entire guide in order to help those who perform code reviews to catch common mistakes and deviations from the code style guidelines. Consult this section when you're reviewing someone else's code to remind yourself the most common things which you should be on the lookout for.

Subsections of this section describe the things which require paying attention for during the code reviews. There are patterns which are forbidden to be used, and if you see one, you must not sign the patch which introduces it off. Other patterns, while not forbidden, require to be sufficiently motivated to pass the review.

Remember, the main intention of this guide is to increase the readability and maintainability of the code, so when reviewing someone else's code, always keep this in mind and try to consider how it will affect the long-term quality of the code base and how easy it would be for someone unfamiliar with the project to understand it.

## Forbidden (TODO)

The following language features and patterns are forbidden to be used in any case. Do not accept a patch if it contains any of them. Some of these items are automatically checked for by build system tools.

* Implicit conversions
* Structural typing
* Abstract types (do not confuse them with regular type aliases)
* Path-dependent types
* Declaring custom higher-kinded types
* Missing `override` modifier when it is applicable
* Missing return type annotations on the parts of public API
* `abstract override`
* `apply()` and `unapply()` methods in classes
* Custom symbolic methods declaration
* Postfix method calls
* `catch { case e: Throwable => }` or `catch { case _ => }`
* Custom macros
* Cake pattern
* `var` members or other mutable objects in case classes
* `var` or `lazy val` as abstract members
* Defining custom DSLs
* `null` (except for interaction with badly written Java libraries)

## Suspicious (TODO)

If you notice the following language features and patterns in the submitted code, you should take especially utmost care in reviewing them. Always ask yourself, whether it is possible to do away without using them altogether. Their usage should usually be motivated by a significant increase in code clarity and readability; do not hesitate to ask the author of the code to explain why they used these items and to rewrite the code without them if it benefits code readability (especially for developers who are unfamiliar with the code base) and maintainability.

* Missing return type annotations in non-public code
* `Any`, `AnyRef`, `AnyVal` and `isInstanceOf` and `asInstanceOf`
* Implicits in general: implicit arguments and implicit classes
* `unapply()` methods
* Multiple parameter lists
* Infix notation
* Call-by-name arguments
* Operations chains, operations nesting
* Tuples and their elements accessors
* Definition of custom type classes (should have *significant* motivation to be accepted)
* `null`s again
* `Option.get`
* Recursion
* Abstract `val` members
* Using DSLs provided by third-party libraries (only in exceptional cases when it cannot be avoided)

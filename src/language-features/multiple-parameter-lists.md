# Multiple parameter lists

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


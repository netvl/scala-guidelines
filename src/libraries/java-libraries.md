# Java libraries

Scala runs on JVM, which gives an enormous advantage of having access to the whole JVM ecosystem, including all existing Java libraries. However, many of these libraries use Java-specific idioms, which often go against Scala idioms.

One of the most important thing when working with Java code is to take `null`-safety into account. Lots of Java libraries either accept null values or return them, either intentionally (for example, `java.util.Map` has it as a part of its API) or not (because of the programmer's negligence). Idiomatic Scala code does not use `null`s (and actually in these guidelines using `null` is expressly forbidden), therefore they should always be handled in the boundary code between the Scala codebase and Java library, for example, by wrapping a value with a possible `null` to an `Option`. Remember, `Option.apply` method (usually written in a functional notation like `Option(someValue)`) checks its argument for null and returns `None` if it is actually a `null`.

Another point is exception-safety. Lots of Java libraries signal errors through exceptions. The idiomatic Scala way is to encapsulate errors which should be handled by the user to an ADT like `Either` or `Try`, therefore, always consider which exceptions a Java library method throws and think if these exceptions are better represented as error values in Scala code. The general rule to follow here is that if these exceptions signify a programmer error, like passing an invalid value for an argument, it is fine not to catch them, but if these exceptions affect the business logic and are likely to happen during the normal flow, they should be caught and transformed to values.

And finally, try to prevent Java libraries from "creeping" into the code base. That is, create idiomatic Scala wrappers around these libraries (or better yet, find an already existing wrapper) which encapsulate all Java-specific quirks and provide an idiomatic Scala API instead of using these libraries everywhere in your code.
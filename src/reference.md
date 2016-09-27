# Reference for code reviewers

This section summarizes the entire guide in order to help those who perform code reviews to catch common mistakes and deviations from the code style guidelines. Consult this section when you're reviewing someone else's code to remind yourself the most common things which you should be on the lookout for.

Subsections of this section describe the things which require paying attention for during the code reviews. There are patterns which are forbidden to be used, and if you see one, you must not sign the patch which introduces it off. Other patterns, while not forbidden, require to be sufficiently motivated to pass the review.

Remember, the main intention of this guide is to increase the readability and maintainability of the code, so, when you are reviewing someone else's code, always keep this in mind and try to consider how it will affect the long-term quality of the code base and how easy it would be for someone unfamiliar with the project to understand it.

## Forbidden

The following language features and patterns are forbidden to be used in any case. Do not accept a patch if it contains any of them. Some of these items are automatically checked for by build system tools.

* [Implicit conversions](language-features/implicits.html#Implicit%20conversions)
* [Structural typing](type-system/structural-typing.html)
* [Abstract types](type-system/abstract-types.html) (do not confuse them with regular type aliases)
* [Path-dependent types](type-system/path-dependent-types.html)
* Declaring custom [higher-kinded types](type-system/higher-kinded-types.html)
* Missing [`override` modifier](language-features/override-modifier.html) when it is applicable
* Missing [return type annotations](type-system/return-type-annotations.html) on the parts of public API
* [`abstract override`](language-features/abstract-override-modifier.html)
* [`apply()`](language-features/apply-method-on-classes.html) and [`unapply()`](language-features/pattern-matching.html#unapply%20methods) methods in classes
* [Custom symbolic methods declaration](language-features/symbolic-methods-and-infix-and-postfix-notation.html)
* [Postfix method calls](language-features/symbolic-methods-and-infix-and-postfix-notation.html)
* [`catch { case e: Throwable => }` or `catch { case _ => }`](language-features/exception-handling.html)
* [Custom macros](language-features/macros.html)
* [Cake pattern](patterns-and-architecture/cake-pattern.html)
* [`var` members or other mutable objects in case classes](patterns-and-architecture/functional-programming.html#Immutability)
* [`var` or `lazy val` as abstract members](patterns-and-architecture/object-oriented-programming.html#Members)
* [Defining custom DSLs](patterns-and-architecture/domain-specific-languages.html)
* [`null`s](patterns-and-architecture/functional-programming.html#Options%20and%20null) (except for interaction with Java libraries)
* Returning [collection views](libraries/collections.html#Views) from functions and storing them in other objects

## Suspicious

If you notice the following language features and patterns in the submitted code, you should take especially utmost care in reviewing them. Always ask yourself, whether it is possible to do away without using them altogether. Their usage should usually be motivated by a significant increase in code clarity and readability; do not hesitate to ask the author of the code to explain why they used these items and to rewrite the code without them if it benefits code readability (especially for developers who are unfamiliar with the code base) and maintainability.

* [`Any`, `AnyRef`, `AnyVal`](type-system/any-anyref-and-anyval.html)
* [`isInstanceOf` and `asInstanceOf`](type-system/isinstanceof-asinstanceof.html)
* [Implicits](language-features/implicits.html) in general, implicit arguments and implicit classes in particular
* [`unapply()`](language-features/pattern-matching.html#unapply%20methods) methods
* [Multiple parameter lists](language-features/multiple-parameter-lists.html)
* [Infix notation](language-features/symbolic-methods-and-infix-and-postfix-notation.html)
* [Call-by-name](language-features/call-by-name.html) arguments
* [Operation chains](language-features/operation-chains.html) and [operations nesting](language-features/operations-nesting-and-for-comprehensions.html)
* [Tuples](language-features/tuples.html) and their elements accessors
* Definition of custom [type classes](language-features/type-classes.html)
* [`null`s](patterns-and-architecture/functional-programming.html#Options%20and%20null) again
* [`Option.get`](patterns-and-architecture/functional-programming.html#Options%20and%20null)
* [Recursion](patterns-and-architecture/functional-programming.html#Recursion)
* [Abstract `val` members](patterns-and-architecture/object-oriented-programming.html#Members)
* [Using DSLs](patterns-and-architecture/domain-specific-languages.html) provided by third-party libraries
* Missing [return type annotations](type-system/return-type-annotations.html) in non-public code

## Recommended

    

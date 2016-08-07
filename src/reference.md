# Reference for code reviewers (TODO)

This section summarizes the entire guide in order to help those who perform code reviews to catch common mistakes and deviations from the code style guidelines. Consult this section when you're reviewing someone else's code to remind yourself the most common things which you should be on the lookout for.

Subsections of this section describe the things which require paying attention for during the code reviews. There are patterns which are forbidden to be used, and if you see one, you must not sign the patch which introduces it off. Other patterns, while not forbidden, require to be sufficiently motivated to pass the review.

Remember, the main intention of this guide is to increase the readability and maintainability of the code, so when reviewing someone else's code, always keep this in mind and try to consider how it will affect the long-term quality of the code base and how easy it would be for someone unfamiliar with the project to understand it.

## Forbidden (TODO)

The following language features and patterns are forbidden to be used in any case. Do not accept a patch if it contains any of them. Some of these items are automatically checked for by build system tools.

* [Implicit conversions](#implicit-conversions)
* [Structural typing](#structural-typing)
* [Abstract types](#abstract-associated-types) (do not confuse them with regular type aliases)
* [Path-dependent types](#path-dependent-types)
* Declaring custom [higher-kinded types](#higher-kinded-types)
* Missing [`override` modifier](#override-modifier) when it is applicable
* Missing [return type annotations](#return-type-annotations) on the parts of public API
* [`abstract override`](#abstract-override-modifier)
* [`apply()` and `unapply()` methods in classes](#apply-method-on-classes)
* [Custom symbolic methods declaration](#symbolic-methods-and-infix-and-postfix-notation)
* Postfix method calls
* `catch { case e: Throwable => }` or `catch { case _ => }`
* Custom macros
* Cake pattern
* `var` members or other mutable objects in case classes
* `var` or `lazy val` as abstract members
* Defining custom DSLs
* `null` (except for interaction with badly written Java libraries)
* Returning collection views from functions and storing them in other objects

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


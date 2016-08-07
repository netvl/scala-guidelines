# Macros

Scala language supports defining macros, which basically are compile-time transformations of source code. Macros usually have access to the entire information about your code which is available to the compiler, including types, which allow implementing very powerful patterns, like generating boilerplate code for structured types like case classes automatically.

However, the current version of macros is notoriously hard to write. The code of macro definitions is usually very obscure. Also macros are often used to create custom DSLs, which not only require reading the source code of the macro to be understood completely, but also often upset the IDE syntax highlighters.

For this reason writing custom macros is forbidden in general. Using macros from other libraries, like serialization, is allowed, unless they hinder the readability.

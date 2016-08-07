# Error handling

Exceptions are ubiquitous in the JVM ecosystem, however, by their nature they may make control flow less understandable and clear because they are essentially nonlocal returns - they bubble up the call stack without explicit return statements.

Therefore, basing the control flow on exceptions is discouraged. Not only does it make the code less obvious, it also has performance implications - stack unwinding is not free. Do not use exceptions as a substitute for regular control flow instructions.

## Encoding errors in types

Exceptions should be used, as their name states, in exceptional situations, i.e. when something went wrong and the program cannot continue further because of a broken invariant. This means that you should not use exceptions when it is possible for an error to occur and you want the user of your code to handle it. In such cases errors should be encoded explicitly, using `Option`, `Try`, `Future` or `Either`-like types.

All rules described in the section on using chained method calls apply to the `Try` values, of course.


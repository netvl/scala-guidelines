# Libraries

Scala ecosystem contains vast amount of libraries virtually for any purpose, and since Scala is a JVM language, it can seamlessly interact with native Java libraries, which increases the pool of libraries even further. However, we must be discreet in which libraries we choose. There are basically the following points which should be considered here:

* Some libraries simply do not have high enough quality to be useful and reliable.
* There are libraries which rely heavily on the most obscure features of the language; while these libraries may solve the corresponding problems in a very succinct way, very often they make the code which uses them very hard to read, especially for people who do not know that library.
* There are libraries which expose complex concepts, which (regardless of the language features they rely on) require considerable background knowledge to be used and understood quickly.
* Java-only libraries require certain precautions for them to be used from Scala correctly. One of the most important and common concerns for using Java libraries in idiomatic Scala code is null safety.

One of the declared goals of this document is to keep the code base cleaner, approachable and maintainable. Virtually any relatively complex program uses tens of libraries directly and even more transitively. Therefore, we must choose which libraries we use and how we use them with utmost care, because their implementation and their API affect our own code greatly.


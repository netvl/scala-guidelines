# Imports

## Imports order

Use the IDEA imports optimizer to sort imports. **TODO: add the snippet with the imports configuration** Source code files should not contain unused imports.

## Relative imports

Always use absolute imports; IDEA code style configuration enforces this. Relative imports almost always decrease the readability.

## Imports location

Always put imports at the top of the file instead of nested scopes. In other words, imports must always be grouped together in one place. 

## Wildcard imports

Avoid using wildcard imports, unless you're importing more than 6 items from the same package. This behavior is also enforced by IDEA.

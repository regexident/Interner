# Interner

Fast general-purpose interners for every use case

Interners take complex values and map them to [trivially-comparable stand-ins](https://en.wikipedia.org/wiki/Flyweight_pattern) that can later be resolved back to their source values. 
Interners are often found in software like parsers, language interpreters, and compilers; they can be used whenever a given algorithm compares its inputs by identity only.

## Examples

```swift
import Interner

let interner = Interner<String>()

let string = "Hello"
let symbol = interner.interned(string)
let resolved = interner.lookup(symbol)

XCTAssert(resolved == string)
```

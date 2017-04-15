## 1.0.2

### Bug fixed

- Fix that it crashed if unclosed quoted is exist.

## 1.0.1

### Bug fixes

- Fix that default transformer did not correspond to unsigned int.

## 1.0.0

### Major changes

- Some method name changed. Please fix your code according to compile error.
- MAESeparatedString has been reborn.
 - It become subclass of NSString.
 - Return value of `description` and `isEqual:` has been changed.

### Additional functions

- Support Carthage.
- Support some primitive types and NSNumber with default transformer.
- The validation of formatByPropertyKey has been enhanced.

### Bug fixes

- Improved accuracy of numberTransformer.
- Fixed an overflow that was happened if last character is backslash.
- Fixed a bug when it used escaped single-quote in single-quote.
- Fixed the type validation (e.g. Enum and Quoted) of `variadicArrayTransformerWithModelClass:`.
- Fixed that return value is nil and error information is also nil, when transformer returns nil.

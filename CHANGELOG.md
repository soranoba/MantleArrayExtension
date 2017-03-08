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

### Minor changes


### Bug fixes

- Improved accuracy of numberTransformer.
- Fixed an overflow that was happened if last character is backslash.
- Fixed a bug when it used escaped single-quote in single-quote.
- Fixed the type validation (e.g. Enum and Quoted) of `variadicArrayTransformerWithModelClass:`.

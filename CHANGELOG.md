## 2.0.3

### IMPORTANT

It does not support Mantle 2.1.6.  
If you can update Mantle 2.1.6 or later, please use the next version.

- Carthage
  - Please lock the Mantle version to 2.1.5 or lower in your Cartfile.
- CocoaPods
  - You don't need to do anything, because the dependency has been updated in the podspec.

### Others

- (Carthage) Xcode12 compatible
- (Carthage) No longer create pre-build frameworks. (ref: https://github.com/Carthage/Carthage/issues/3130)

## 2.0.2

- Fix to prevent warnings of analyze

## 2.0.1

### Bug fixes

- In the case of 32 bit OS, properties of BOOL choose numberTransformer by default. It fix to choose boolTransformer.

## 2.0.0

### Additional functions

- It possible to easily specify expecting that it equals to specified characters.
  - Please refer to a class that name is `MAERawFragment`.
- Add a protocol named `MAEFragment`. You can create `MAEFragment` by yourself.

### Major changes

The following affects some users.

- The I/F of `MAEFragment` has been greatly changed.
  - Syntax sugars creating a `MAEFragment` has changed only the type of return value.
- `MAEFragment # isEqual:` and `MAEFragment # hash` become to return the same result as that of `NSObject`.
- All unavailable methods deleted.

## 1.1.1

### Bug fixes

- Fix that it can not parse correctly if it returning a class with different quotedOption in classForParsingArray.

## 1.1.0

### Additional functions

- It became to be able to select quoted string to use

## 1.0.2

### Bug fixes

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

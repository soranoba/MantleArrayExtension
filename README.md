# MantleArrayExtension
[![Build Status](https://travis-ci.org/soranoba/MantleArrayExtension.svg?branch=master)](https://travis-ci.org/soranoba/MantleArrayExtension)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/MantleArrayExtension.svg?style=flat)](http://cocoapods.org/pods/MantleArrayExtension)
[![License](https://img.shields.io/cocoapods/l/MantleArrayExtension.svg?style=flat)](http://cocoapods.org/pods/MantleArrayExtension)
[![Platform](https://img.shields.io/cocoapods/p/MantleArrayExtension.svg?style=flat)](http://cocoapods.org/pods/MantleArrayExtension)

MantleArrayExtension support mutual conversion between Model object and character-delimited String with Mantle.

## Overview

Mantle only support Json and Dictionary.

This library is an extension that convert between array and model with Mantle.

- Support these
  - Split a string with the specified character and convert it to model
  - Convert between array and model
  - Customizable transformer

### What is Mantle ?
Model framework for Cocoa and Cocoa Touch

- [Mantle](https://github.com/Mantle/Mantle)

## Installation

MantleArrayExtension is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MantleArrayExtension'
```

## How to use functions of MantleArrayExtension

### Conversion between Model and String (or Array)

```objc
// String to Model
id<MAESerializing> model = [MAEArrayAdapter modelOfClass:model.class
                                              fromString:@"2017-01-29, 'Alice Brown', 1, 2, 3"
                                                   error:&error];

// Model to String
NSString* string = [MAEArrayAdapter stringFromModel:model
                                              error:&error];
```

### Model definition

Model MUST inherit [MTLModel](https://github.com/Mantle/Mantle#mtlmodel) and conforms MAEArraySerializing.

```objc
#pragma mark - MAEArraySerializing

+ (NSArray* _Nonnull)formatByPropertyKey
{
    return @[ @"date", MAESingleQuoted(@"name"), MAEVariadic(@"scores") ];
}

+ (unichar)separator
{
    return ',';
}

+ (BOOL)ignoreEdgeBlank
{
    return YES;
}
```

### Kind of format

- `@"propetyName"`
  - Double quoted-string, single quoted-string or enumerate-string
- `MAEQuoted(@"propertyName")`
  - Double quoted-string
- `MAESingleQuoted(@"propertyName")`
  - Single quoted-string
- `MAEOptional(@"propertyName")`
  - Optional
- `MAEVariadic(@"propertyName")`
  - Group from this position as one array.
- `MAERaw(@"rawString")`, `MAERawEither(@[@"value1", @"value2"])`
  - The string expect one of specified strings
- `MAERawEither(@[@"value1", @"value2"]).withProperty(@"propertyName")`
  - `MAERaw` or `MAERawEither` associate with property.

### Transformer
You can use serializer for MAEArraySerializing object.

- `MAEArrayAdapter # stringTransformerWithArrayModelClass:`
- `MAEArrayAdapter # variadicTransformerWithArrayModelClass:`

For MAEArraySerializing property, it is used by default, so you do not need to specify it.

### Other information

Please refer to [documentation](http://cocoadocs.org/docsets/MantleArrayExtension), [unit tests](MantleArrayExtensionTests) and [Mantle](https://github.com/Mantle/Mantle).

## Contribute

Pull request is welcome =D

## License

[MIT License](LICENSE)

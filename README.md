# Titlecaser

This package is a quick and dirty port of John Gruber's [Title Case](https://daringfireball.net/2008/05/title_case) to Swift. David Gouch's [To Title Case](https://github.com/gouch/to-title-case) was used as a starting point, but the project became substantially different due to API differences.

Test cases are a mix of those [from the original project](https://github.com/ap/titlecase/blob/master/test.pl) and those of [To Title Case](https://github.com/gouch/to-title-case/blob/master/test/tests.json).

## Requirements
Due to the newness of some of the Swift APIs being used, macOS 13.x, iOS/iPadOS 16.x, watchOS 9.x, or tvOS 16.x is required.

## Usage
```Swift
let titleCased = "this is a string that needs title case".toTitleCase()
> "This Is a String That Needs Title Case"
```


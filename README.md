# Titlecaser

This package is a port of John Gruber's [Title Case](https://daringfireball.net/2008/05/title_case) to Swift. David Gouch's [To Title Case](https://github.com/gouch/to-title-case) was used as a starting point, but the project has quickly evolved into its own.

Test cases are a mix of those [from the original project](https://github.com/ap/titlecase/blob/master/test.pl) and those of [To Title Case](https://github.com/gouch/to-title-case/blob/master/test/tests.json).

## Requirements
Should work with any platform supported by Swift 5.7. In my own testing, it works across all current Apple platforms as well as Fedora Linux.

## Usage
```Swift
let titleCased = "this is a string that needs title case".toTitleCase()
> "This Is a String That Needs Title Case"
```


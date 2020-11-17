# ProcessPretty

Commandline tool that is platform endepended. Its main features are

- captures the output for evaluation before writing to console
- outputs in colors with optional progress bar
- offers generic way to run asynchronous processes

This code works on windows, linux and macos.

## Getting Started

You will have to install swift standard library.  Follow the [Swift getting started guide](https://swift.org/getting-started/#installing-swift) for the platform of your choosing.

## Integrate

You will need to know about [using swift package manager](https://swift.org/getting-started/#using-the-package-manager).

Integrate in application using SPM, in `Package.swift`

```swift
.package(name: "ProcessPretty", url: "https://github.com/dooZdev/ProcessPretty.gitt", <#wanted version#>)
```
more info on https://swift.org/package-manager/

## Usage

In a main.swilf or type with `@main`

Add `import ProcessPretty` to the beginning of every file.

### Synchronous
```swift

let echoSync = try ProcessPretty(executable: "echo", arguments: ["something to output in sync"])
func sync() {
    do {
        try echoSync.run(in: #function, at: #filePath)
    } catch {
        exit(EXIT_FAILURE)
    }
}

sync()
```

This looks up task in the `PATH` accessible executables. If the executable for the process to run is not found make update the `PATH` value.

---
## Inspiration

Inspiration for this is taken from [jakeheis/SwiftCLI](https://github.com/jakeheis/SwiftCLI). SwiftCLI does more than just run a system process. 
It also makes Commands, a structured way to add arguments and options to a process you run on the commandline. As for commands we use [Apple's swift-argument-parser](https://github.com/apple/swift-argument-parser) SwiftCLI was too big to use. But the way to run a task is taken from that project and used here.

# Allocated Unfair Lock Shim

Shims [OSAllocatedUnfairLock](https://developer.apple.com/documentation/os/osallocatedunfairlock) in a 
`struct AllocatedUnfairLock` for the following platforms:
 
* .macOS 10.15+
* .iOS 13+
* .tvOS 13+
* .watchOS 6+

This package might also be of use when Swift 6's [Mutex](https://developer.apple.com/documentation/synchronization/mutex) is unavailable.

## Usage example

1. Add the following dependency to your `Package.swift` file:

```
    .package(url: "https://github.com/Akazm/allocated-unfair-lock", from: "1.0.1")
```

2. Add `AllocatedUnfairLockShim` to the target dependencies.

From then on, you're ready to go.

Code says more than a thousand words, so here's a simple usage example:

```swift
import AllocatedUnfairLockShim

let myLock: AllocatedUnfairLock<Int> = AllocatedUnfairLock(initialState: 20)

/*
Happy locking on older platforms! 

For API reference, see https://developer.apple.com/documentation/os/osallocatedunfairlock
*/
```
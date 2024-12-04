import os

/// A struct that allocates an unfair lock by using either
/// -  ``AllocatedUnfairLockShim`` (before macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *),
/// - [OSAllocatedUnfairLock](https://developer.apple.com/documentation/os/osallocatedunfairlock) otherwise
///
/// For API reference, see [OSAllocatedUnfairLock](https://developer.apple.com/documentation/os/osallocatedunfairlock)
public struct AllocatedUnfairLock<State>: AllocatedUnfairLockConformance, @unchecked Sendable {
    public typealias Ownership = ShimmedOwnership
    public typealias State = State
    private let actualLock: Any

    public init(uncheckedState initialState: State) {
        actualLock = if #available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *) {
            OSAllocatedUnfairLock(uncheckedState: initialState)
        } else {
            AllocatedUnfairLockShim(uncheckedState: initialState)
        }
    }

    public func precondition(_ condition: ShimmedOwnership) {
        if #available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *),
           let actualLock = actualLock as? OSAllocatedUnfairLock<State>
        {
            switch condition {
            case .owner:
                actualLock.precondition(OSAllocatedUnfairLock<State>.Ownership.owner)
            case .notOwner:
                actualLock.precondition(OSAllocatedUnfairLock<State>.Ownership.notOwner)
            }
        } else if let actualLock = actualLock as? AllocatedUnfairLockShim<State> {
            actualLock.precondition(condition)
            return
        }
        fatalError("#available evaluation failed")
    }

    public func withLock<R>(_ body: @Sendable (inout State) throws -> R) rethrows -> R where R: Sendable {
        if #available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *) {
            if let actualLock = actualLock as? OSAllocatedUnfairLock<State> {
                return try actualLock.withLock(body)
            }
        } else if let actualLock = actualLock as? AllocatedUnfairLockShim<State> {
            return try actualLock.withLock(body)
        }
        fatalError("#available evaluation failed")
    }

    public func withLockIfAvailableUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R? {
        if #available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *) {
            if let actualLock = actualLock as? OSAllocatedUnfairLock<State> {
                return try actualLock.withLockIfAvailableUnchecked(body)
            }
        } else if let actualLock = actualLock as? AllocatedUnfairLockShim<State> {
            return try actualLock.withLockIfAvailableUnchecked(body)
        }
        fatalError("#available evaluation failed")
    }

    public func withLockIfAvailable<R>(_ body: @Sendable (inout State) throws -> R) rethrows -> R? where R: Sendable {
        if #available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *) {
            if let actualLock = actualLock as? OSAllocatedUnfairLock<State> {
                return try actualLock.withLockIfAvailable(body)
            }
        } else if let actualLock = actualLock as? AllocatedUnfairLockShim<State> {
            return try actualLock.withLockIfAvailable(body)
        }
        fatalError("#available evaluation failed")
    }

    public func withLockUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R {
        if #available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *) {
            if let actualLock = actualLock as? OSAllocatedUnfairLock<State> {
                return try actualLock.withLockUnchecked(body)
            }
        } else if let actualLock = actualLock as? AllocatedUnfairLockShim<State> {
            return try actualLock.withLockUnchecked(body)
        }
        fatalError("#available evaluation failed")
    }
}

extension AllocatedUnfairLock where Self.State == Void {
    
    public init() {
        self.init(uncheckedState: ())
    }

    public func lock() {
        if #available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *) {
            if let actualLock = actualLock as? OSAllocatedUnfairLock<State> {
                actualLock.lock()
                return
            }
        } else if let actualLock = actualLock as? AllocatedUnfairLockShim<State> {
            actualLock.lock()
            return
        }
        fatalError("#available evaluation failed")
    }

    public func unlock() {
        if #available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *) {
            if let actualLock = actualLock as? OSAllocatedUnfairLock<State> {
                actualLock.unlock()
                return
            }
        } else if let actualLock = actualLock as? AllocatedUnfairLockShim<State> {
            actualLock.unlock()
            return
        }
        fatalError("#available evaluation failed")
    }

    public func lockIfAvailable() -> Bool {
        if #available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *) {
            if let actualLock = actualLock as? OSAllocatedUnfairLock<State> {
                return actualLock.lockIfAvailable()
            }
        } else if let actualLock = actualLock as? AllocatedUnfairLockShim<State> {
            return actualLock.lockIfAvailable()
        }
        fatalError("#available evaluation failed")
    }

    public func withLock<R: Sendable>(_ body: @Sendable () throws -> R) rethrows -> R {
        if #available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *) {
            if let actualLock = actualLock as? OSAllocatedUnfairLock<State> {
                return try actualLock.withLock(body)
            }
        } else if let actualLock = actualLock as? AllocatedUnfairLockShim<State> {
            return try actualLock.withLock(body)
        }
        fatalError("#available evaluation failed")
    }

    public func withLockIfAvailableUnchecked<R>(_ body: () throws -> R) rethrows -> R? {
        if #available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *) {
            if let actualLock = actualLock as? OSAllocatedUnfairLock<State> {
                return try actualLock.withLockIfAvailableUnchecked(body)
            }
        } else if let actualLock = actualLock as? AllocatedUnfairLockShim<State> {
            return try actualLock.withLockIfAvailableUnchecked(body)
        }
        fatalError("#available evaluation failed")
    }

    public func withLockIfAvailable<R: Sendable>(_ body: @Sendable () throws -> R) rethrows -> R? {
        if #available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *) {
            if let actualLock = actualLock as? OSAllocatedUnfairLock<State> {
                return try actualLock.withLockIfAvailable(body)
            }
        } else if let actualLock = actualLock as? AllocatedUnfairLockShim<State> {
            return try actualLock.withLockIfAvailable(body)
        }
        fatalError("#available evaluation failed")
    }

    public func withLockUnchecked<R>(_ body: () throws -> R) rethrows -> R {
        if #available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *) {
            if let actualLock = actualLock as? OSAllocatedUnfairLock<State> {
                return try actualLock.withLockUnchecked(body)
            }
        } else if let actualLock = actualLock as? AllocatedUnfairLockShim<State> {
            return try actualLock.withLockUnchecked(body)
        }
        fatalError("#available evaluation failed")
    }
    
}

extension AllocatedUnfairLock: StatefulAllocatedUnfairLockConformance {
    public typealias InitialState = State
}

extension AllocatedUnfairLock: AllocatedUnfairLockVoidConformance where Self.State == Void {

}

public extension AllocatedUnfairLock where Self.State: Sendable {
    init(initialState: State) {
        self.init(uncheckedState: initialState)
    }
}

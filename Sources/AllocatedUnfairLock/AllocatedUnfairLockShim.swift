import os

///Shims [OSAllocatedUnfairLock](https://developer.apple.com/documentation/os/osallocatedunfairlock)
///by using [os_unfair_lock_lock](https://developer.apple.com/documentation/os/1646466-os_unfair_lock_lock) et al.
///with a [ManagedBuffer](https://developer.apple.com/documentation/swift/managedbuffer).
///
/// For API reference, see [OSAllocatedUnfairLock](https://developer.apple.com/documentation/os/osallocatedunfairlock)
///
///(Inspired by https://github.com/jeudesprits/pied-piper-iOS/blob/10b064f5d73974c3dcf0cb40e0665ead70e69b70/Packages/osUtilities/Sources/osUtilities/OSAllocatedRecursiveLock.swift)
public struct AllocatedUnfairLockShim<State>: AllocatedUnfairLockConformance, @unchecked Sendable {
    public typealias InitialState = State

    @usableFromInline
    let __lock: ManagedLock

    public init(uncheckedState initialState: State) {
        __lock = .create(with: initialState)
    }

    @inlinable
    public func withLockUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R {
        return try __lock.withUnsafeMutablePointers { header, lock in
            os_unfair_lock_lock(lock); defer { os_unfair_lock_unlock(lock) }
            return try body(&header.pointee)
        }
    }

    @inlinable
    public func withLock<R: Sendable>(_ body: @Sendable (inout State) throws -> R) rethrows -> R {
        return try withLockUnchecked(body)
    }

    @inlinable
    public func withLockIfAvailableUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R? {
        return try __lock.withUnsafeMutablePointers { header, lock in
            guard os_unfair_lock_trylock(lock) else {
                return nil
            }
            defer {
                os_unfair_lock_unlock(lock)
            }
            return try body(&header.pointee)
        }
    }

    @inlinable
    public func withLockIfAvailable<R: Sendable>(_ body: @Sendable (inout State) throws -> R) rethrows -> R? {
        return try withLockIfAvailableUnchecked(body)
    }

    @usableFromInline
    func _preconditionTest(_ condition: ShimmedOwnership) -> Bool {
        __lock.withUnsafeMutablePointerToElements { lock in
            switch condition {
            case .owner:
                os_unfair_lock_assert_owner(lock)
            case .notOwner:
                os_unfair_lock_assert_not_owner(lock)
            }
        }
        return true
    }

    @_transparent
    public func precondition(_ condition: ShimmedOwnership) {
        Swift.precondition(_preconditionTest(condition), "lockPrecondition failure")
    }
}

extension AllocatedUnfairLockShim: AllocatedUnfairLockVoidConformance where State == Void {
    @inlinable
    public init() {
        self.init(uncheckedState: ())
    }

    @inlinable
    public func withLockUnchecked<R>(_ body: () throws -> R) rethrows -> R {
        return try withLockUnchecked { _ in try body() }
    }

    @inlinable
    public func withLock<R: Sendable>(_ body: @Sendable () throws -> R) rethrows -> R {
        return try withLock { _ in try body() }
    }

    @inlinable
    public func withLockIfAvailableUnchecked<R>(_ body: () throws -> R) rethrows -> R? {
        return try withLockIfAvailableUnchecked { _ in try body() }
    }

    @inlinable
    public func withLockIfAvailable<R: Sendable>(_ body: @Sendable () throws -> R) rethrows -> R? {
        return try withLockIfAvailable { _ in try body() }
    }

    @available(*, noasync, message: "Use 'withLock' for scoped locking")
    @inlinable
    public func lock() {
        __lock.withUnsafeMutablePointerToElements { lock in
            os_unfair_lock_lock(lock)
        }
    }

    @available(*, noasync, message: "Use 'withLock' for scoped locking")
    @inlinable
    public func unlock() {
        __lock.withUnsafeMutablePointerToElements { lock in
            os_unfair_lock_unlock(lock)
        }
    }

    @available(*, noasync, message: "Use 'withLockIfAvailable' for scoped locking")
    @inlinable
    public func lockIfAvailable() -> Bool {
        return __lock.withUnsafeMutablePointerToElements { lock in
            os_unfair_lock_trylock(lock)
        }
    }
}

extension AllocatedUnfairLockShim: StatefulAllocatedUnfairLockConformance {
    
}

public extension AllocatedUnfairLockShim where State: Sendable {
    @inlinable
    init(initialState: State) {
        self.init(uncheckedState: initialState)
    }
}

extension AllocatedUnfairLockShim {

    @usableFromInline
    final class ManagedLock: ManagedBuffer<State, os_unfair_lock_s> {
        @inlinable
        class func create(with initialState: State) -> Self {
            let `self` = create(minimumCapacity: 1) { buffer in
                buffer.withUnsafeMutablePointerToElements { lock in
                    lock.initialize(to: .init())
                }
                return initialState
            }
            return unsafeDowncast(`self`, to: Self.self)
        }

        @inlinable
        deinit {
            let _ = withUnsafeMutablePointerToElements { lock in
                lock.deinitialize(count: 1)
            }
        }
    }
}

public enum ShimmedOwnership: Hashable, Sendable {
    case owner
    case notOwner
}

public protocol AllocatedUnfairLockConformance<State>: Sendable, ~Copyable {
    associatedtype State
    associatedtype Ownership

    init(uncheckedState initialState: State)

    func withLock<R: Sendable>(_ body: @Sendable (inout State) throws -> R) rethrows -> R

    func withLockIfAvailableUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R?

    func withLockIfAvailable<R: Sendable>(_ body: @Sendable (inout State) throws -> R) rethrows -> R?

    func withLockUnchecked<R>(_ body: (inout State) throws -> R) rethrows -> R

    func precondition(_ condition: Ownership)
}

public protocol AllocatedUnfairLockVoidConformance: AllocatedUnfairLockConformance<Void> {
    init()

    @available(*, noasync, message: "Use 'withLock' for scoped locking")
    func lock()

    @available(*, noasync, message: "Use 'withLock' for scoped locking")
    func unlock()

    @available(*, noasync, message: "Use 'withLockIfAvailable' for scoped locking")
    func lockIfAvailable() -> Bool

    func withLock<R: Sendable>(_ body: @Sendable () throws -> R) rethrows -> R

    func withLockIfAvailableUnchecked<R>(_ body: () throws -> R) rethrows -> R?

    func withLockIfAvailable<R: Sendable>(_ body: @Sendable () throws -> R) rethrows -> R?

    func withLockUnchecked<R>(_ body: () throws -> R) rethrows -> R
}

public protocol StatefulAllocatedUnfairLockConformance {
    associatedtype InitialState
    init(initialState: InitialState)
}

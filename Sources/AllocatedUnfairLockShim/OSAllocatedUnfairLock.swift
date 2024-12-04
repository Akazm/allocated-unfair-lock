import os

@available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *)
extension OSAllocatedUnfairLock: AllocatedUnfairLockConformance {
    public typealias ShimmedOwnership = Self.Ownership
}

@available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *)
extension OSAllocatedUnfairLock: AllocatedUnfairLockVoidConformance where State == Void {}

@available(macOS 13.0, watchOS 9.0, tvOS 16.0, iOS 16.0, *)
extension OSAllocatedUnfairLock: StatefulAllocatedUnfairLockConformance {
    public typealias InitialState = Self.State
}

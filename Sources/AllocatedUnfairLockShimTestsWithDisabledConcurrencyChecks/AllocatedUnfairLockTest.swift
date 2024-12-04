import AllocatedUnfairLock
import Foundation
import XCTest
import os

struct Something<Lock: AllocatedUnfairLockVoidConformance> {
    var lock = Lock(uncheckedState: ())
    var value: UInt16 = 0
}

@Sendable func incrementCounter<Lock: AllocatedUnfairLockVoidConformance>(value: inout Something<Lock>) {
    var localCopy = value
    while !localCopy.lock.lockIfAvailable() {
        continue
    }
    localCopy.value += 1
    localCopy.lock.unlock()
    value = localCopy
}

final class AllocatedUnfairLockShimTests: XCTestCase {
    
    /// Determine if the behaviour of `OSAllocatedUnfairLock` and `AllocatedUnfairLock` is non-deterministic when deliberately used incorrectly
    func testUnstableMemoryAddress() async throws {
        var resource = Something<OSAllocatedUnfairLock>()
        var shimmedResource = Something<AllocatedUnfairLockShim>()
        
        DispatchQueue.concurrentPerform(iterations: Int(UInt16.max)) { @Sendable _ in
            incrementCounter(value: &resource)
        }
        XCTAssertNotEqual(resource.value, UInt16.max)
        
        DispatchQueue.concurrentPerform(iterations: Int(UInt16.max)) { @Sendable _ in
            incrementCounter(value: &shimmedResource)
        }
        XCTAssertNotEqual(shimmedResource.value, UInt16.max)
    }

}

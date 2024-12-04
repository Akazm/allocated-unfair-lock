import AllocatedUnfairLockShim
import Carbon
import Foundation
import XCTest

final class AllocatedUnfairLockShimTests: XCTestCase {
    
    func testMultipleLockAttemptsFromSameThreadFail() async throws {
        let process = Process()
        process.currentDirectoryURL = URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        process.executableURL = .init(filePath: "/usr/bin/swift")
        process.arguments = ["run", "CmdLineAllocatedUnfairLockTests"]
        do {
            try process.run()
            process.waitUntilExit()
        } catch let error as NSError {
            XCTFail("Unexpected Error occurred: NSError.code = \(error.code), NSError.domain = \(error.domain)")
        }
        XCTAssertTrue(process.terminationStatus == Carbon.dsChkErr)
    }

    func testMultiThreadLockingDoesNotFail() async throws {
        let lockedThing = AllocatedUnfairLockShim(initialState: Set<Int>())
        for i in 0 ..< 20 {
            Thread {
                lockedThing.withLock {
                    $0 = $0.union([i])
                }
            }.start()
        }
        var attempts = 0
        while lockedThing.withLockUnchecked({ $0.count }) < 20 {
            attempts += 1
            if attempts == UInt32.max {
                throw XCTestError(.timeoutWhileWaiting)
            }
        }
        XCTAssertTrue(lockedThing.withLockUnchecked { $0.count } == 20)
    }
    
}

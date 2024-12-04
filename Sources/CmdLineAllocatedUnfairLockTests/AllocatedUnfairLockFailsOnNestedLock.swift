import AllocatedUnfairLockShim
import XCTest

@main
struct AllocatedUnfairLockShimTests {
    static func main() {
        let lock = AllocatedUnfairLockShim()
        lock.withLock { _ in
            lock.withLock { _ in
                print("We should have crashed by now")
            }
        }
    }
}

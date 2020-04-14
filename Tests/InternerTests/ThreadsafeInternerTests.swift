import XCTest
@testable import Interner

final class ThreadsafeInternerTests: XCTestCase {
    func testIntern() {
        typealias Object = Int
        typealias ObjectInterner = ThreadsafeInterner<Interner<Object>>

        let interner = ObjectInterner(interner: .init(cachingLookup: true))

        let numberOfObjects: Int = 100
        let objects: [Object] = (0..<numberOfObjects).map { _ in
            Object.random(in: Object.min..<Object.max)
        }

        let numberOfThreads: Int = 100
        DispatchQueue.concurrentPerform(iterations: numberOfThreads) { index in
            for object in objects {
                interner.intern(object)
            }
        }

        XCTAssertEqual(interner.count, objects.count)
    }

    static var allTests = [
        ("testIntern", testIntern),
    ]
}

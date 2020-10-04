import XCTest
@testable import Interner

final class ThreadsafeInternerTests: XCTestCase {
    func testIntern() {
        typealias Extern = Int
        typealias Intern = UInt8
        typealias ObjectInterner = ThreadsafeInterner<Extern, Intern>

        let interner = ObjectInterner(efficientFor: .time)

        let numberOfObjects: Int = 100
        let objects: [Extern] = (0..<numberOfObjects).map { _ in
            .random(in: (.min)...(.max))
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

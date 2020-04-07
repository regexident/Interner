import XCTest
@testable import Interner

final class ConcurrentInternerTests: XCTestCase {
    func testIntern() {
        typealias Key = Int
        typealias KeyInterner = ConcurrentInterner<Interner<Key>>

        let interner = KeyInterner(interner: .init(cachingLookup: true))

        let numberOfKeys: Int = 100
        let duplicatesPerKey: Int = 100

        let keys: [Key] = (0..<numberOfKeys).map { _ in
            Key.random(in: Key.min..<Key.max)
        }

        DispatchQueue.concurrentPerform(iterations: keys.count * duplicatesPerKey) { index in
            let key = keys[index % keys.count]
            let _ = interner.interned(key)
        }

        XCTAssertEqual(interner.count, keys.count)
    }

    static var allTests = [
        ("testIntern", testIntern),
    ]
}

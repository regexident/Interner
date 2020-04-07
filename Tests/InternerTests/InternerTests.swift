import XCTest
@testable import Interner

final class InternerTests: XCTestCase {
    func testIntern() {
        typealias Object = Int
        typealias ObjectInterner = Interner<Object>
        typealias Symbol = ObjectInterner.Symbol

        let uncachedInterner = ObjectInterner(cachingLookup: false)
        let cachedInterner = ObjectInterner(cachingLookup: true)

        XCTAssertEqual(uncachedInterner.count, 0)
        XCTAssertEqual(cachedInterner.count, 0)

        XCTAssertTrue(uncachedInterner.isEmpty)
        XCTAssertTrue(cachedInterner.isEmpty)

        let numberOfObjects: Int = 100

        let objects: [Object] = (0..<numberOfObjects).map { _ in
            Object.random(in: Object.min..<Object.max)
        }

        let symbols: [Symbol] = objects.enumerated().map { index, _ in
            Symbol(index)
        }

        assert(objects.count == symbols.count)

        // Add objects to interner:
        for (object, expected) in zip(objects, symbols) {
            XCTAssertEqual(uncachedInterner.interned(object), expected)
            XCTAssertEqual(cachedInterner.interned(object), expected)
        }

        XCTAssertEqual(uncachedInterner.count, objects.count)
        XCTAssertEqual(cachedInterner.count, objects.count)

        // Add objects a second time and check for idempotence:
        for (symbol, expected) in zip(symbols, objects) {
            XCTAssertEqual(uncachedInterner.lookup(symbol), expected)
            XCTAssertEqual(cachedInterner.lookup(symbol), expected)
        }

        XCTAssertEqual(uncachedInterner.count, objects.count)
        XCTAssertEqual(cachedInterner.count, objects.count)
    }

    static var allTests = [
        ("testIntern", testIntern),
    ]
}

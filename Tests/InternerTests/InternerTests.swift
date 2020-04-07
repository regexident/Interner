import XCTest
@testable import Interner

final class InternerTests: XCTestCase {
    func testIntern() {
        typealias Key = Int
        typealias KeyInterner = Interner<Key>
        typealias Symbol = KeyInterner.Symbol

        let uncachedInterner = KeyInterner(cachingLookup: false)
        let cachedInterner = KeyInterner(cachingLookup: true)

        XCTAssertEqual(uncachedInterner.count, 0)
        XCTAssertEqual(cachedInterner.count, 0)

        XCTAssertTrue(uncachedInterner.isEmpty)
        XCTAssertTrue(cachedInterner.isEmpty)

        let numberOfKeys: Int = 100

        let keys: [Key] = (0..<numberOfKeys).map { _ in
            Key.random(in: Key.min..<Key.max)
        }

        let symbols: [Symbol] = keys.enumerated().map { index, _ in
            Symbol(index)
        }

        assert(keys.count == symbols.count)

        // Add keys to interner:
        for (key, expected) in zip(keys, symbols) {
            XCTAssertEqual(uncachedInterner.interned(key), expected)
            XCTAssertEqual(cachedInterner.interned(key), expected)
        }

        XCTAssertEqual(uncachedInterner.count, keys.count)
        XCTAssertEqual(cachedInterner.count, keys.count)

        // Add keys a second time and check for idempotence:
        for (symbol, expected) in zip(symbols, keys) {
            XCTAssertEqual(uncachedInterner.lookup(symbol), expected)
            XCTAssertEqual(cachedInterner.lookup(symbol), expected)
        }

        XCTAssertEqual(uncachedInterner.count, keys.count)
        XCTAssertEqual(cachedInterner.count, keys.count)
    }

    static var allTests = [
        ("testIntern", testIntern),
    ]
}

import XCTest
@testable import Interner

final class InternerTests: XCTestCase {
    func testIntern() {
        typealias Extern = Int
        typealias Intern = UInt8
        typealias ObjectInterner = Interner<Extern, Intern>
        typealias Symbol = ObjectInterner.Symbol

        let internerEfficientForSpace = ObjectInterner(efficientFor: .space)
        let internerEfficientForTime = ObjectInterner(efficientFor: .time)

        XCTAssertEqual(internerEfficientForSpace.count, 0)
        XCTAssertEqual(internerEfficientForTime.count, 0)

        XCTAssertTrue(internerEfficientForSpace.isEmpty)
        XCTAssertTrue(internerEfficientForTime.isEmpty)

        let numberOfObjects: Int = 100

        let objects: [Extern] = (0..<numberOfObjects).map { _ in
            .random(in: (.min)...(.max))
        }

        let symbols: [Symbol] = objects.enumerated().map { index, _ in
            Symbol(UInt8(index))
        }

        assert(objects.count == symbols.count)

        // Add objects to interner:
        for (object, expected) in zip(objects, symbols) {
            XCTAssertEqual(internerEfficientForSpace.interned(object), expected)
            XCTAssertEqual(internerEfficientForTime.interned(object), expected)
        }

        XCTAssertEqual(internerEfficientForSpace.count, objects.count)
        XCTAssertEqual(internerEfficientForTime.count, objects.count)

        // Add objects a second time and check for idempotence:
        for (symbol, expected) in zip(symbols, objects) {
            XCTAssertEqual(internerEfficientForSpace.lookup(symbol), expected)
            XCTAssertEqual(internerEfficientForTime.lookup(symbol), expected)
        }

        XCTAssertEqual(internerEfficientForSpace.count, objects.count)
        XCTAssertEqual(internerEfficientForTime.count, objects.count)
    }

    static var allTests = [
        ("testIntern", testIntern),
    ]
}

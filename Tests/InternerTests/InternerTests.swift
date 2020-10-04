import XCTest
@testable import Interner

final class InternerTests: XCTestCase {
    typealias Intern = UInt8
    typealias Symbol = GenericSymbol<Intern>

    typealias TypedExtern = Int
    typealias UntypedExtern = AnyHashable

    typealias TypedInterner = Interner<TypedExtern, Intern>
    typealias UntypedInterner = Interner<AnyHashable, Intern>

    func testTyped() {
        let internerEfficientForSpace = TypedInterner(efficientFor: .space)
        let internerEfficientForTime = TypedInterner(efficientFor: .time)

        XCTAssertEqual(internerEfficientForSpace.count, 0)
        XCTAssertEqual(internerEfficientForTime.count, 0)

        XCTAssertTrue(internerEfficientForSpace.isEmpty)
        XCTAssertTrue(internerEfficientForTime.isEmpty)

        let numberOfObjects: Int = 100

        let objects: [TypedExtern] = (0..<numberOfObjects).map { _ in
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

    func testUntyped() {
        let internerEfficientForSpace = UntypedInterner(efficientFor: .space)
        let internerEfficientForTime = UntypedInterner(efficientFor: .time)

        XCTAssertEqual(internerEfficientForSpace.count, 0)
        XCTAssertEqual(internerEfficientForTime.count, 0)

        XCTAssertTrue(internerEfficientForSpace.isEmpty)
        XCTAssertTrue(internerEfficientForTime.isEmpty)

        let numberOfObjects: Int = 100

        let objects: [UntypedExtern] = (0..<numberOfObjects).map { index in
            let intValue = Int.random(in: (.min)...(.max))

            if index % 2 == 0 {
                return AnyHashable(intValue)
            } else {
                return AnyHashable("\(intValue)")
            }
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

    func testDebugDescription() {
        let interner = TypedInterner()

        interner.intern(42)

        XCTAssertEqual(
            String(reflecting: interner),
            """
            Interner.Interner<Swift.Int, Swift.UInt8>(dictionary: [42: 0], array: Optional([42]))
            """
        )
    }

    func testDescription() {
        let interner = TypedInterner()

        interner.intern(42)

        XCTAssertEqual(
            String(describing: interner),
            """
            Interner<Int, UInt8>(dictionary: [42: 0], array: Optional([42]))
            """
        )
    }

    static var allTests = [
        ("testTyped", testTyped),
        ("testUntyped", testUntyped),
        ("testDebugDescription", testDebugDescription),
        ("testDescription", testDescription),
    ]
}

import XCTest

import Interner

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
final class InternerBenchmarks: XCTestCase {
    let numberOfObjectsForInterning: Int = 100_000
    let numberOfObjectsForLookup: Int = 10_000

    struct Element: Hashable {
        let id: Int
        let data: Data

        init(id: Int) {
            self.id = id
            self.data = Data(capacity: 100)
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            self.id.hash(into: &hasher)
        }
    }

    func testBenchmarkInterningEfficientForSpace() {
        typealias Extern = Element
        typealias Intern = UInt32
        typealias ObjectInterner = Interner<Extern, Intern>
        typealias Symbol = ObjectInterner.Symbol

        let numberOfObjects = self.numberOfObjectsForInterning

        let interner = ObjectInterner(efficientFor: .space)

        let objects: [Extern] = (0..<numberOfObjects).map { _ in
            Element(id: .random(in: (.min)...(.max)))
        }

        self.measure(metrics: [XCTMemoryMetric(), XCTClockMetric(), XCTCPUMetric()]) {
            for object in objects {
                interner.intern(object)
            }
        }
    }

    func testBenchmarkInterningEfficientForTime() {
        typealias Extern = Element
        typealias Intern = UInt32
        typealias ObjectInterner = Interner<Extern, Intern>
        typealias Symbol = ObjectInterner.Symbol

        let numberOfObjects = self.numberOfObjectsForInterning

        let interner = ObjectInterner(efficientFor: .time)

        let objects: [Extern] = (0..<numberOfObjects).map { _ in
            Element(id: .random(in: (.min)...(.max)))
        }

        self.measure(metrics: [XCTMemoryMetric(), XCTClockMetric(), XCTCPUMetric()]) {
            for object in objects {
                interner.intern(object)
            }
        }
    }

    func testBenchmarkLookupInterningEfficientForSpace() {
        typealias Extern = Element
        typealias Intern = UInt32
        typealias ObjectInterner = Interner<Extern, Intern>
        typealias Symbol = ObjectInterner.Symbol

        let numberOfObjects = self.numberOfObjectsForLookup

        let interner = ObjectInterner(efficientFor: .space)

        let objects: [Extern] = (0..<numberOfObjects).map { _ in
            Element(id: .random(in: (.min)...(.max)))
        }

        var symbols: [Symbol] = []
        symbols.reserveCapacity(numberOfObjects)

        for object in objects {
            symbols.append(interner.interned(object))
        }

        self.measure(metrics: [XCTMemoryMetric(), XCTClockMetric(), XCTCPUMetric()]) {
            for symbol in symbols {
                let _ = interner.lookup(symbol)
            }
        }
    }

    func testBenchmarkLookupInterningEfficientForTime() {
        typealias Extern = Element
        typealias Intern = UInt32
        typealias ObjectInterner = Interner<Extern, Intern>
        typealias Symbol = ObjectInterner.Symbol

        let numberOfObjects = self.numberOfObjectsForLookup

        let interner = ObjectInterner(efficientFor: .time)

        let objects: [Extern] = (0..<numberOfObjects).map { _ in
            Element(id: .random(in: (.min)...(.max)))
        }

        var symbols: [Symbol] = []
        symbols.reserveCapacity(numberOfObjects)

        for object in objects {
            symbols.append(interner.interned(object))
        }

        self.measure(metrics: [XCTMemoryMetric(), XCTClockMetric(), XCTCPUMetric()]) {
            for symbol in symbols {
                let _ = interner.lookup(symbol)
            }
        }
    }

    static var allTests: [(String, (InternerBenchmarks) -> () -> ())] {
        return [
            ("testBenchmarkInterningEfficientForSpace", testBenchmarkInterningEfficientForSpace),
            ("testBenchmarkInterningEfficientForTime", testBenchmarkInterningEfficientForTime),
            ("testBenchmarkLookupInterningEfficientForSpace", testBenchmarkLookupInterningEfficientForSpace),
            ("testBenchmarkLookupInterningEfficientForTime", testBenchmarkLookupInterningEfficientForTime),
        ]
    }
}

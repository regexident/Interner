import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(InternerTests.allTests),
        testCase(ThreadsafeInternerTests.allTests),
    ]
}
#endif

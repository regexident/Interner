import Foundation

public protocol InternerErrorProtocol: Swift.Error {
    static var notFound: Self { get }
    static var invalidType: Self { get }
}

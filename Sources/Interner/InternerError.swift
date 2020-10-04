import Foundation

public protocol InternerErrorProtocol: Swift.Error {
    static var invalidType: Self { get }
}

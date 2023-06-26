import Foundation

open
class IACClient {

    public let scheme: String

    public weak var manager: IACManager?

    public
    init(scheme: String) {
        self.scheme = scheme
    }

    open
    func NSErrorCodeForXCUErrorCode(_ code: String?) -> Int {
        code.flatMap { Int($0) } ?? 0
    }

    var canOpenURL = canOpen
}

public
extension IACClient {
    func isAppInstalled() -> Bool {
        guard let url = URL(string: "\(scheme)://test") else { return false }
        return canOpenURL(url)
    }

    func performAction(_ action: String, parameters: IACParameters? = nil, handler: IACResultHandler? = nil) throws {
        let request = IACRequest(client: self, action: action, parametrs: parameters, handler: handler)

        if let manager = manager {
            try manager.sendRequest(request)
        } else {
            try IACManager.shared.sendRequest(request)
        }
    }

    @discardableResult
    func performAction(_ action: String, parameters: IACParameters? = nil) async throws -> IACAsyncResult {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try performAction(action, parameters: parameters) {
                    switch $0 {
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    case .cancelled:
                        continuation.resume(returning: .cancelled)
                    case .success(let result):
                        continuation.resume(returning: .success(result))
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

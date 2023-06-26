import Foundation
import IACCore

public
class GoogleChromeIACClient: IACClient {

    public
    init() {
        super.init(scheme: "googlechrome-x-callback")
    }
}

public
extension GoogleChromeIACClient {
    typealias ResultHandler = (Result<Bool, Error>) -> Void

    func openURL(_ url: URL, inNewTab: Bool = false, callback: ResultHandler? = nil) {
        var params: IACParameters = ["url": url.absoluteString]
        if inNewTab {
            params["create-new-tab"] = ""
        }

        do {
            if let callback = callback {
                try performAction("open", parameters: params) {
                    switch $0 {
                    case .success:
                        callback(.success(true))
                    case .cancelled:
                        callback(.success(false))
                    case .failure(let error):
                        callback(.failure(error))
                    }
                }
            } else {
                try performAction("open", parameters: params)
            }
        } catch {
            callback?(.failure(error))
        }
    }

    func openURL(_ url: URL, inNewTab: Bool = false) async throws -> Bool {
        var params: IACParameters = ["url": url.absoluteString]
        if inNewTab {
            params["create-new-tab"] = ""
        }

        let result = try await performAction("open", parameters: params)
        if case .cancelled = result {
            return false
        } else {
            return true
        }

    }
}

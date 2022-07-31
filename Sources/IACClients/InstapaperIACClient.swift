import Foundation
import IACCore

public
class InstapaperIACClient: IACClient {
    
    public
    init() {
        super.init(scheme: "x-callback-instapaper")
    }
}

public
extension InstapaperIACClient {
    typealias ResultHandler = (Result<Bool, Error>) -> Void

    func addUrl(_ url: URL, callback: ResultHandler? = nil) {
        do {
            if let callback = callback {
                try performAction("add", parameters: ["url": url.absoluteString]) {
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
                try performAction("add", parameters: ["url": url.absoluteString])
            }
        } catch {
            callback?(.failure(error))
        }
    }
}

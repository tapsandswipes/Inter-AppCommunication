import Foundation
import IACCore

public
class FunboxIACClient: IACClient {

    public
    enum Error: Int, Swift.Error {
        case soundNotFound = -1
    }

    public
    init() {
        super.init(scheme: "funbox")
    }

}

public
extension FunboxIACClient {
    typealias ResultHandler = (Result<Bool, Swift.Error>) -> Void

    func playSound(_ sound: String, callback: ResultHandler? = nil) {
        do {
            if let callback = callback {
                try performAction("play", parameters: ["sound": sound]) {
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
                try performAction("play", parameters: ["sound": sound])
            }
        } catch {
            callback?(.failure(error))
        }
    }

    func downloadSoundFromUrl(_ url: URL) {
        try? performAction("dounload", parameters: ["url": url.absoluteString])
    }
}

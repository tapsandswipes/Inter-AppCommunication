import Foundation

public
class IACManager {

    public static let shared = IACManager()

    public weak var delegate: IACDelegate?

    public var callbackURLScheme: String?

    public
    init(callbackURLScheme: String? = nil) {
        self.callbackURLScheme = callbackURLScheme
    }

    private var sessions: [String: IACRequest] = [:]
    private var actions: [String: IACActionHandler] = [:]

    // Useful for testing
    var openURL = open(_:)
}

public
extension IACManager {
    func handleOpenURL(_ url: URL) -> Bool {
        guard
            url.scheme == callbackURLScheme,
            url.host == kXCUHost
        else { return false }

        let action = String(url.path.dropFirst())
        let parameters = url.query?.toIACParameters

        if action == kIACResponse {
            return handleResponse(for: parameters)
        }

        if let actionHandler = actions[action] {
            actionHandler(parameters?.removingProtocolParams()) {
                self.handleResult($0, parameters: parameters)
            }
            return true
        }

        if delegate?.supportIACAction(action) == true {
            delegate?.performIACAction(action, parameters: parameters?.removingProtocolParams()) {
                self.handleResult($0, parameters: parameters)
            }
            return true
        }

        let data: IACResultData = [
            kXCUErrorCode: "\(IACError.actionNotSupported.rawValue)",
            kXCUErrorMessage: String.localizedStringWithFormat(NSLocalizedString("'%@' is not an x-callback-url action supported by %@", comment: ""), action, appName()),
            kIACErrorDomain: IACErrorDomain
        ]

        if let url = self.url(from: parameters, key: kXCUError, appendingPrameters: data) {
            openURL(url)
            return true
        }

        return false
    }

    func handleAction(_ action: String, with handler: @escaping IACActionHandler) {
        actions[action] = handler
    }

    func sendRequest(_ request: IACRequest) throws {
        guard request.client.isAppInstalled() else {
            let message = String.localizedStringWithFormat(NSLocalizedString("App with scheme '%@' is not installed in this device", comment: ""), request.client.scheme)
            let error = NSError(domain: IACErrorDomain,
                                code: IACError.appNotIntalled.rawValue,
                                userInfo: [NSLocalizedDescriptionKey: message])
            if let handler = request.handler {
                handler(.failure(error))
                return
            } else {
                throw IACError.appNotIntalled
            }
        }

        var requestComponents = try request.urlComponents()

        if let scheme = callbackURLScheme {
            guard var callbackComponents = URLComponents(string: "\(scheme)://\(kXCUHost)/\(kIACResponse)?") else { throw IACError.invalidURL }

            callbackComponents.queryItems = [URLQueryItem(name: kIACRequest, value: request.id)]

            if request.handler != nil {
                var extraParameters: [URLQueryItem] = []

                var s = callbackComponents
                s.queryItems?.append(URLQueryItem(name: kIACResponseType, value: String(IACResponseType.success.rawValue)))
                extraParameters.append(URLQueryItem(name: kXCUSuccess, value: s.url?.absoluteString))

                s = callbackComponents
                s.queryItems?.append(URLQueryItem(name: kIACResponseType, value: String(IACResponseType.cancel.rawValue)))
                extraParameters.append(URLQueryItem(name: kXCUCancel, value: s.url?.absoluteString))

                s = callbackComponents
                s.queryItems?.append(URLQueryItem(name: kIACResponseType, value: String(IACResponseType.failure.rawValue)))
                extraParameters.append(URLQueryItem(name: kXCUError, value: s.url?.absoluteString))

                requestComponents.queryItems?.append(contentsOf: extraParameters)
            }
        } else if request.handler != nil {
            throw IACError.invalidScheme
        }

        guard let url = requestComponents.url else { throw IACError.invalidURL }

        sessions[request.id] = request

        openURL(url)
    }
}

private
extension IACManager {
    func handleResponse(for parameters: IACParameters?) -> Bool {
        guard
            let parameters = parameters,
            let id = parameters[kIACRequest],
            let request = sessions[id]
        else { return false }

        guard
            let responseValue = parameters[kIACResponseType].flatMap(Int.init),
            let responsetype = IACResponseType(rawValue: responseValue)
        else {
            sessions.removeValue(forKey: id)
            return false
        }

        switch responsetype {
        case .success:
            request.handler?(.success(parameters.removingProtocolParams()))
        case .failure:
            let code = request.client.NSErrorCodeForXCUErrorCode(parameters[kXCUErrorCode])
            let domain = parameters[kIACErrorDomain] ?? IACClientErrorDomain
            let error = NSError(domain: domain, code: code)
            request.handler?(.failure(error))
        case .cancel:
            request.handler?(.cancelled)
        }

        sessions.removeValue(forKey: id)
        return true
    }

    func handleResult(_ result: IACResult, parameters: IACParameters?) {
        switch result {
        case .cancelled:
            if let url = self.url(from: parameters, key: kXCUCancel, appendingPrameters: nil) {
                openURL(url)
            }
        case .success(let data):
            if let url = self.url(from: parameters, key: kXCUSuccess, appendingPrameters: data) {
                openURL(url)
            }
        case .failure(let error):
            let data: IACResultData = [
                kXCUErrorCode: "\(error.code)",
                kXCUErrorMessage: error.localizedDescription,
                kIACErrorDomain: error.domain
            ]
            if let url = self.url(from: parameters, key: kXCUError, appendingPrameters: data) {
                openURL(url)
            }
        }
    }

    func url(from parameters: IACParameters?, key: String, appendingPrameters: IACResultData?) -> URL? {
        guard var components = parameters?[key].flatMap(URLComponents.init(string:)) else { return nil }

        if let itemsToAdd = appendingPrameters {
            var items = components.queryItems ?? []
            items.append(contentsOf: itemsToAdd.map(URLQueryItem.init))
            components.queryItems = items
        }

        return components.url
    }
}

import Foundation

public
struct IACRequest: Identifiable {
    public var id: String
    public var client: IACClient
    public var action: String
    public var parameters: IACParameters?
    public var handler: IACResultHandler?

    public init(id: String = UUID().uuidString,
                client: IACClient,
                action: String,
                parametrs: IACParameters? = nil,
                handler: IACResultHandler? = nil) {
        self.id = id
        self.client = client
        self.action = action
        self.parameters = parametrs
        self.handler = handler
    }
}

extension IACRequest {
    func urlComponents() throws -> URLComponents {
        guard var components = URLComponents(string: "\(client.scheme)://\(kXCUHost)/\(action)?") else { throw IACError.invalidURL }

        var params: [URLQueryItem] = [URLQueryItem(name: kXCUSource, value: appName())]
        parameters.map { params.append(contentsOf: $0.map(URLQueryItem.init)) }
        components.queryItems = params

        return components
    }
}

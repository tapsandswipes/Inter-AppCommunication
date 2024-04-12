import XCTest
@testable import IACCore

final class InterAppCommunicationTests: XCTestCase {

    let client: IACClient = IACClient(scheme: "testScheme")
    let opener = URLOpener()
    let appName: String = IACCore.appName()

    override func setUp() {
        client.canOpenURL = { _ in true }
    }

    func testRequest() throws {
        let sut = IACRequest(client: client, action: "testRequest")

        let url = try XCTUnwrap(sut.urlComponents().url)

        XCTAssertEqual(url.absoluteString, "testScheme://x-callback-url/testRequest?x-source=\(appName)")
    }

    func testRequestWithParams() throws {
        let params: IACParameters = ["p1": "v1", "p2": "v2"]
        let sut = IACRequest(client: client, action: "testRequest", parametrs: params)

        let url = try XCTUnwrap(sut.urlComponents().url)

        let c = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))

        XCTAssertEqual(c.scheme, "testScheme")
        XCTAssertEqual(c.host, "x-callback-url")
        XCTAssertEqual(c.path.dropFirst(), "testRequest")
        XCTAssertEqual(c.queryItems?.count, 3)
        try XCTAssertEqual(XCTUnwrap(c.queryItems?.first(where: { $0.name == "x-source"})).value, appName)
        try XCTAssertEqual(XCTUnwrap(c.queryItems?.first(where: { $0.name == "p1"})).value, "v1")
        try XCTAssertEqual(XCTUnwrap(c.queryItems?.first(where: { $0.name == "p2"})).value, "v2")
    }

    func testManagerHandling() throws {
        let sut = IACManager(callbackURLScheme: "testScheme")

        let expectation = XCTestExpectation()

        sut.handleAction("action") { p, cb in
            XCTAssertEqual(p?["x-source"], self.appName)
            expectation.fulfill()
        }

        let url = try XCTUnwrap(URL(string: "testScheme://x-callback-url/action?x-source=\(appName)"))

        let r = sut.handleOpenURL(url)

        XCTAssertTrue(r)

        wait(for: [expectation], timeout: 1)
    }

    func testManagerHandlingParameters() throws {
        let sut = IACManager(callbackURLScheme: "testScheme")

        let expectation = XCTestExpectation()

        sut.handleAction("action") { p, cb in
            expectation.fulfill()
            XCTAssertEqual(p?["x-source"], self.appName)
            XCTAssertEqual(p?["p1"], "v1")
            XCTAssertEqual(p?["p2"], "v2")
        }

        let url = try XCTUnwrap(URL(string: "testScheme://x-callback-url/action?x-source=\(appName)&p1=v1&p2=v2"))

        let r = sut.handleOpenURL(url)

        XCTAssertTrue(r)

        wait(for: [expectation], timeout: 1)
    }

    func testManagerSendSimpleRequest() throws {
        let sut = IACManager()
        sut.openURL = opener.openURL

        let request = IACRequest(client: client, action: "testRequest")

        try sut.sendRequest(request)

        XCTAssertEqual(opener.lastOpenedURL?.absoluteString, "testScheme://x-callback-url/testRequest?x-source=\(appName)")
    }

    func testManagerCallbacks() throws {
        let m1 = IACManager(callbackURLScheme: "provider")
        let m2 = IACManager(callbackURLScheme: "consumer")

        m1.openURL = { [unowned m2] in
            XCTAssertTrue(m2.handleOpenURL($0))
        }

        m2.openURL = { [unowned m1] in
            XCTAssertTrue(m1.handleOpenURL($0))
        }

        m1.handleAction("testRequest") { p, cb in
            cb(.success(["r1":"v1"]))
        }

        let client1 = IACClient(scheme: "provider")
        client1.canOpenURL = { _ in true }
        client1.manager = m2

        let expectation = XCTestExpectation()
        let request = IACRequest(client: client1, action: "testRequest") {
            expectation.fulfill()
            switch $0 {
            case .success(let data):
                XCTAssertEqual(data["r1"], "v1")
            default:
                XCTFail()
            }
        }
        try m2.sendRequest(request)

        wait(for: [expectation], timeout: 1)
    }

}


class URLOpener {
    var lastOpenedURL: URL?

    func openURL(_ url: URL) {
        lastOpenedURL = url
    }
}

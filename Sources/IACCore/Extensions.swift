import Foundation
#if os(iOS) || os(tvOS)
import class UIKit.UIApplication
#elseif os(OSX)
import class AppKit.NSWorkspace
#endif


extension String {
    var toIACParameters: IACParameters {
        var result: IACParameters = [:]
        let pairs: [String] = self.components(separatedBy: "&")
        for pair in pairs {
            let comps: [String] = pair.components(separatedBy: "=")
            if comps.count >= 2 {
                let key = comps[0]
                let value = comps.dropFirst().joined(separator: "=")
                result[key.queryDecode] = value.queryDecode
            }
        }
        return result
    }

    var queryDecode: String {
        return self.removingPercentEncoding ?? self
    }
}

extension IACParameters {
    func removingProtocolParams() -> IACResultData {
        return self.filter { $0.key == kXCUSource ||  (!$0.key.hasPrefix(kXCUPrefix) && !$0.key.hasPrefix(kIACPrefix)) }
    }
}

func appName() -> String {
    if let appName = Bundle.main.localizedInfoDictionary?["CFBundleDisplayName"] as? String {
        return appName
    }
    return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "IAC"
}

func open(_ url: URL) {
#if os(iOS) || os(tvOS)
    UIApplication.shared.open(url)
#elseif os(OSX)
    NSWorkspace.shared.open(url)
#endif
}

func canOpen(_ url: URL) -> Bool {
#if os(iOS) || os(tvOS)
    return UIApplication.shared.canOpenURL(url)
#elseif os(OSX)
    return NSWorkspace.shared.urlForApplication(toOpen: url) != nil
#endif
}


public
func appURLSchemes() -> [String]? {
    guard let urlTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: AnyObject]] else {
        return nil
    }
    var result: [String] = []
    for urlType in urlTypes {
        if let schemes = urlType["CFBundleURLSchemes"] as? [String] {
            result += schemes
        }
    }
    return result.isEmpty ? nil : result
}

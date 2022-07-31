import Foundation

public typealias IACParameters = Dictionary<String, String>
public typealias IACResultData = Dictionary<String, String>

public
enum IACResult {
    case success(IACResultData)
    case failure(NSError)
    case cancelled
}

public typealias IACResultHandler = (IACResult) -> Void

public
enum IACError: Int, Error {
    case appNotIntalled      = 1
    case actionNotSupported
    case invalidScheme
    case invalidURL
}

public typealias IACActionHandler = (IACParameters?, IACResultHandler) -> Void

public let IACErrorDomain        = "com.iac.manager.error"
public let IACClientErrorDomain = "com.iac.client.error"

let kXCUPrefix        = "x-"
let kXCUHost          = "x-callback-url"
let kXCUSource        = "x-source"
let kXCUSuccess       = "x-success"
let kXCUError         = "x-error"
let kXCUCancel        = "x-cancel"
let kXCUErrorCode     = "error-Code"
let kXCUErrorMessage  = "errorMessage"

// IAC strings
let kIACPrefix        = "IAC"
let kIACResponse      = "IACRequestResponse"
let kIACRequest       = "IACRequestID"
let kIACResponseType = "IACResponseType"
let kIACErrorDomain  = "errorDomain"

enum IACResponseType: Int {
    case success
    case failure
    case cancel
}

import Foundation


public
protocol IACDelegate: AnyObject {
    func supportIACAction(_ action: String) -> Bool

    func performIACAction(_ action: String, parameters: IACParameters?, onCompletion: @escaping IACResultHandler)
}

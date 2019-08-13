import Foundation
import UIKit

public struct PIPWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public extension PIPUsable {
    var pip: PIPWrapper<Self> {
        return PIPWrapper(self)
    }
}

public extension PIPWrapper where Base: PIPKitViewController {
    func show() {
        PIPKit.show(with: base)
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        PIPKit.dismiss(animated: animated, completion: completion)
    }
}

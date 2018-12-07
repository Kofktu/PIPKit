import Foundation
import UIKit

public protocol PIPUsable {
    var initialState: PIPState { get }
    var pipSize: CGSize { get }
}

public extension PIPUsable {
    var initialState: PIPState { return .full }
}

public extension PIPUsable where Self: UIViewController {
    
    func setNeedUpdatePIPSize() {
        
    }
    
}

internal extension PIPUsable where Self: UIViewController {
    
    func setInitialFrame(with fullSize: CGSize) {
        switch initialState {
        case .full:
            view.bounds = CGRect(origin: .zero, size: fullSize)
        case .pip:
            view.bounds = CGRect(origin: .zero, size: pipSize)
        }
    }
    
    func dismiss(animated: Bool, completion: (() -> Void)?) {
        
    }
    
}

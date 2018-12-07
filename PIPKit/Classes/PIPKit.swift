import Foundation
import UIKit

public enum PIPState {
    case pip
    case full
}

enum _PIPState {
    case none
    case pip
    case full
    case exit
}

public typealias PIPKitViewController = (UIViewController & PIPUsable)

public final class PIPKit {
    
    static public var isPIP: Bool { return state == .pip }
    
    static private var state: _PIPState = .none
    static private var rootViewController: PIPKitViewController?
    
    public class func show(with viewController: PIPKitViewController, completion: (() -> Void)? = nil) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        guard !PIPKit.isPIP else {
            dismiss(animated: false) {
                PIPKit.show(with: viewController)
            }
            return
        }
        
        PIPKit.rootViewController = viewController
        viewController.view.alpha = 0.0
        viewController.setInitialFrame(with: window.frame.size)
        viewController.setupEventDispatcher()
        window.addSubview(viewController.view)
        
        UIView.animate(withDuration: 0.25, animations: {
            PIPKit.rootViewController?.view.alpha = 1.0
        }) { (_) in
            completion?()
        }
    }
    
    public class func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        PIPKit.state = .exit
        rootViewController?.dismiss(animated: animated, completion: {
            PIPKit.reset()
            completion?()
        })
    }
    
    // MARK: - Private
    private static func reset() {
        PIPKit.state = .none
        PIPKit.rootViewController = nil
    }
    
}

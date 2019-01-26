import Foundation
import UIKit

public protocol PIPUsable {
    var initialState: PIPState { get }
    var initialPosition: PIPPosition { get }
    var pipSize: CGSize { get }
    func didChangedState(_ state: PIPState)
}

public extension PIPUsable {
    var initialState: PIPState { return .pip }
    var initialPosition: PIPPosition { return .bottomRight }
    var pipSize: CGSize { return CGSize(width: 200.0, height: (200.0 * 9.0) / 16.0) }
    func didChangedState(_ state: PIPState) {}
}

public extension PIPUsable where Self: UIViewController {
    
    func setNeedUpdatePIPSize() {
        guard PIPKit.isPIP else {
            return
        }
        pipEventDispatcher?.updateFrame()
    }

    func startPIPMode() {
        PIPKit.startPIPMode()
    }
    
    func stopPIPMode() {
        PIPKit.stopPIPMode()
    }
    
}

internal extension PIPUsable where Self: UIViewController {
    
    func pipDismiss(animated: Bool, completion: (() -> Void)?) {
        if animated {
            UIView.animate(withDuration: 0.15, animations: { [weak self] in
                self?.view.alpha = 0.0
            }) { [weak self] (_) in
                self?.view.removeFromSuperview()
                completion?()
            }
        } else {
            view.removeFromSuperview()
            completion?()
        }
    }
    
}

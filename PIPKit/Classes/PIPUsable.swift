import Foundation
import UIKit

public protocol PIPUsable {
    var initialState: PIPState { get }
    var initialPosition: PIPPosition { get }
    var pipSize: CGSize { get }
    var pipShadow: PIPShadow? { get }
    var pipCorner: PIPCorner? { get }
    func didChangedState(_ state: PIPState)
}

public extension PIPUsable {
    var initialState: PIPState { return .pip }
    var initialPosition: PIPPosition { return .bottomRight }
    var pipSize: CGSize { return CGSize(width: 200.0, height: (200.0 * 9.0) / 16.0) }
    var pipShadow: PIPShadow? { return PIPShadow(color: .black, opacity: 0.3, offset: CGSize(width: 0, height: 8), radius: 10) }
    var pipCorner: PIPCorner? {
        if #available(iOS 13.0, *) {
            return PIPCorner(radius: 6, curve: .continuous)
        } else {
            return PIPCorner(radius: 6, curve: nil)
        }
    }
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

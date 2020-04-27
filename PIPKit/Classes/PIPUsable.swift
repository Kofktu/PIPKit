import Foundation
import UIKit

public protocol PIPUsable {
    var initialState: PIPState { get }
    var initialPosition: PIPPosition { get }
    var pipEdgeInsets: UIEdgeInsets { get }
    var pipSize: CGSize { get }
    var pipShadow: PIPShadow? { get }
    var pipCorner: PIPCorner? { get }
    func didChangedState(_ state: PIPState)
    func didChangePosition(_ position: PIPPosition)
}

public extension PIPUsable {
    var initialState: PIPState { return .pip }
    var initialPosition: PIPPosition { return .bottomRight }
    var pipEdgeInsets: UIEdgeInsets { return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15) }
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
    func didChangePosition(_ position: PIPPosition) {}
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
            UIView.animate(withDuration: 0.24, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.view.alpha = 0.0
                self?.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
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

import Foundation
import UIKit

public struct PIPShadow {
    public let color: UIColor
    public let opacity: Float
    public let offset: CGSize
    public let radius: CGFloat
    
    public init(color: UIColor,
                opacity: Float,
                offset: CGSize,
                radius: CGFloat) {
        self.color = color
        self.opacity = opacity
        self.offset = offset
        self.radius = radius
    }
}

public struct PIPCorner {
    public let radius: CGFloat
    public let curve: CALayerCornerCurve?
    
    public init(radius: CGFloat,
                curve: CALayerCornerCurve? = nil) {
        self.radius = radius
        self.curve = curve
    }
}

public enum PIPState {
    case pip
    case full
}

public enum PIPPosition {
    case topLeft
    case middleLeft
    case bottomLeft
    case topRight
    case middleRight
    case bottomRight
}

enum _PIPState {
    case none
    case pip
    case full
    case exit
}

public typealias PIPKitViewController = (UIViewController & PIPUsable)

public final class PIPKit {
    
    static public var isActive: Bool { return rootViewController != nil }
    static public var isPIP: Bool { return state == .pip }
    static public var visibleViewController: PIPKitViewController? { return rootViewController }
    
    static internal var state: _PIPState = .none
    static private var rootViewController: PIPKitViewController?
    static private var pipWindow: UIWindow?
    
    public class func show(with viewController: PIPKitViewController, completion: (() -> Void)? = nil) {
        guard !isActive else {
            dismiss(animated: false) {
                PIPKit.show(with: viewController)
            }
            return
        }
        
        let newWindow = PIPKitWindow()
        newWindow.backgroundColor = .clear
        newWindow.rootViewController = viewController
        newWindow.windowLevel = .alert
        newWindow.makeKeyAndVisible()
        
        pipWindow = newWindow
        rootViewController = viewController
        state = (viewController.initialState == .pip) ? .pip : .full
        
        viewController.view.alpha = 0.0
        viewController.setupEventDispatcher()
        
        UIView.animate(withDuration: 0.25, animations: {
            PIPKit.rootViewController?.view.alpha = 1.0
        }) { (_) in
            completion?()
        }
    }
    
    public class func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        state = .exit
        rootViewController?.pipDismiss(animated: animated, completion: {
            PIPKit.reset()
            completion?()
        })
    }
    
    // MARK: - Internal
    class func startPIPMode() {
        guard let rootViewController = rootViewController else {
            return
        }
        
        // PIP
        state = .pip
        rootViewController.pipEventDispatcher?.enterPIP()
    }
    
    class func stopPIPMode() {
        guard let rootViewController = rootViewController else {
            return
        }
        
        // fullScreen
        state = .full
        rootViewController.pipEventDispatcher?.enterFullScreen()
    }
    
    // MARK: - Private
    private static func reset() {
        PIPKit.state = .none
        PIPKit.pipWindow = nil
        PIPKit.rootViewController = nil
        UIApplication.shared._keyWindow?.makeKeyAndVisible()
    }
    
}

final private class PIPKitWindow: UIWindow {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let rootViewController = rootViewController else {
            return super.hitTest(point, with: event)
        }
        
        return rootViewController.view.frame.contains(point) ? super.hitTest(point, with: event) : nil
    }
    
}

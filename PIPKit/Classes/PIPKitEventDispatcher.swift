//
//  PIPKitEventDispatcher.swift
//  PIPKit
//
//  Created by Taeun Kim on 07/12/2018.
//

import Foundation
import UIKit

final class PIPKitEventDispatcher {
    
    private enum Consts {
        static let hangAroundPadding: CGFloat = 15.0
    }
    
    private weak var rootViewController: PIPKitViewController?
    private lazy var transitionGesture: UIPanGestureRecognizer = {
        UIPanGestureRecognizer(target: self, action: #selector(onTransition(_:)))
    }()
    private lazy var hangAroundGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(onTransition(_:)))
        gesture.isEnabled = false
        return gesture
    }()
    
    private var isValidPanning: Bool = false
    
    init(rootViewController: PIPKitViewController) {
        self.rootViewController = rootViewController
        setupGesture()
        
        switch rootViewController.initialState {
        case .full:
            willEnterFullScreen()
            didEnterFullScreen()
        case .pip:
            willEnterPIP()
            didEnterPIP()
        }
    }
    
    func willEnterFullScreen() {
        hangAroundGesture.isEnabled = false
    }
    
    func didEnterFullScreen() {
        transitionGesture.isEnabled = true
    }
    
    func willEnterPIP() {
        transitionGesture.isEnabled = false
    }
    
    func didEnterPIP() {
        hangAroundGesture.isEnabled = true
    }
    
    // MARK: - Private
    private func setupGesture() {
        rootViewController?.view.addGestureRecognizer(transitionGesture)
        rootViewController?.view.addGestureRecognizer(hangAroundGesture)
    }
    
    // MARK: - Action
    @objc
    private func onTransition(_ gesture: UIPanGestureRecognizer) {
        guard PIPKit.isPIP else {
            return
        }
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        let transition = gesture.translation(in: window)
        let ty = transition.y
        let targetTy = min(max(ty, 0.0), Consts.panningThreshold)
        let percent = min(1.0, targetTy / Consts.panningThreshold)
        
        switch gesture.state {
        case .changed:
            if percent > 0 && !isValidPanning {
                isValidPanning = true
                // startTransition
            }
            
        case .ended:
            isValidPanning = false
        default:
            break
        }
    }
    
    @objc
    private func onHangAround(_ gesture: UIPanGestureRecognizer) {
        
    }
    
}

extension UIViewController {
    
    struct AssociatedKeys {
        static var pipEventDispatcher = "pipEventDispatcher"
    }
    
    private(set) var pipEventDispatcher: PIPKitEventDispatcher? {
        get { return objc_getAssociatedObject(self, AssociatedKeys.pipEventDispatcher) as? PIPKitEventDispatcher }
        set { objc_setAssociatedObject(self, AssociatedKeys.pipEventDispatcher, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
    }
    
    func setupEventDispatcher() {
        guard let pipViewController = self as? PIPKitViewController else {
            return
        }
        pipEventDispatcher = PIPKitEventDispatcher(rootViewController: pipViewController)
    }
    
}

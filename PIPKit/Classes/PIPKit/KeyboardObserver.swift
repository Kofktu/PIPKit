//
//  KeyboardObserver.swift
//  PIPKit
//
//  Created by Kofktu on 2022/08/15.
//

import Foundation
import UIKit

protocol KeyboardObserverDelegate: AnyObject {
    
    func keyboard(_ observer: KeyboardObserver, changed visibleHeight: CGFloat)
    
}

final class KeyboardObserver: NSObject {
    
    var isVisible: Bool {
        visibleHeight > 0.0
    }
    var keyboardHeight: CGFloat {
        var height = keyboardFrame.height
        
        if isAdjustSafeAreaInset, #available(iOS 11.0, *) {
            if let window = UIApplication.shared._keyWindow, height > 0 {
                height -= window.safeAreaInsets.bottom
            }
        }
        
        return max(0, height)
    }
    
    private(set) var keyboardFrame = CGRect.zero {
        didSet {
            var height: CGFloat = max(0.0, screenHeight - keyboardFrame.minY)
            
            if isAdjustSafeAreaInset, #available(iOS 11.0, *) {
                if let window = UIApplication.shared._keyWindow, height > 0 {
                    height -= window.safeAreaInsets.bottom
                }
            }
            
            visibleHeight = height
        }
    }
    private(set) var visibleHeight: CGFloat = 0.0 {
        didSet {
            if oldValue != visibleHeight {
                delegate?.keyboard(self, changed: visibleHeight)
            }
        }
    }
    
    private weak var delegate: KeyboardObserverDelegate?
    private let isAdjustSafeAreaInset: Bool
    private var isObserving: Bool = false
    private var observations: [NSObjectProtocol] = []
    private var panGesture: UIPanGestureRecognizer?
    
    private let keyboardWillChangeFrame: Notification.Name = {
#if swift(>=4.2)
        return UIResponder.keyboardWillChangeFrameNotification
#else
        return NSNotification.Name.UIKeyboardWillChangeFrame
#endif
    }()
    
    private let keyboardWillHide: Notification.Name = {
#if swift(>=4.2)
        return UIResponder.keyboardWillHideNotification
#else
        return NSNotification.Name.UIKeyboardWillHide
#endif
    }()
    
    init(delegate: KeyboardObserverDelegate,
         adjustSafeAreaInset: Bool) {
        self.delegate = delegate
        self.isAdjustSafeAreaInset = adjustSafeAreaInset
        super.init()
    }
    
    func activate() {
        guard isObserving == false else {
            return
        }
        
        isObserving = true
        
        observations.append(
            NotificationCenter.default.addObserver(forName: keyboardWillChangeFrame,
                                                   object: nil,
                                                   queue: nil,
                                                   using: { [weak self] noti in
                                                       self?.onKeyboardHandler(noti)
                                                   })
        )
        
        observations.append(
            NotificationCenter.default.addObserver(forName: keyboardWillHide,
                                                   object: nil,
                                                   queue: nil,
                                                   using: { [weak self] noti in
                                                       self?.onKeyboardHandler(noti)
                                                   })
        )
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        panGesture?.delegate = self
        UIApplication.shared._keyWindow?.addGestureRecognizer(panGesture.unsafelyUnwrapped)
    }
    
    func deactivate() {
        guard isObserving else {
            return
        }
        
        isObserving = false
        observations.removeAll()
        
        panGesture.flatMap {
            panGesture?.view?.removeGestureRecognizer($0)
        }
        panGesture = nil
    }
    
    // MARK: - Action
    private func onKeyboardHandler(_ noti: Notification) {
#if swift(>=4.2)
        let keyboardFrameEndKey = UIResponder.keyboardFrameEndUserInfoKey
#else
        let keyboardFrameEndKey = UIKeyboardFrameEndUserInfoKey
#endif
        
        guard let rect = (noti.userInfo?[keyboardFrameEndKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        var isLocal: Bool = true
        
        if #available(iOS 9.0, *) {
#if swift(>=4.2)
            let isLocalKey = UIResponder.keyboardIsLocalUserInfoKey
#else
            let isLocalKey = UIKeyboardIsLocalUserInfoKey
#endif
            
            (noti.userInfo?[isLocalKey] as? Bool).flatMap {
                isLocal = $0
            }
        }
        
        guard isLocal else {
            return
        }
        
        var newFrame = rect
        
        switch noti.name {
        case keyboardWillChangeFrame:
            if rect.origin.y < 0 {
                newFrame.origin.y = screenHeight - newFrame.height
            }
        case keyboardWillHide:
            if rect.minY < 0.0 {
                newFrame.origin.y = screenHeight
            }
        default:
            break
        }
        
        keyboardFrame = newFrame
    }
    
    @objc
    private func onPan(_ gesture: UIPanGestureRecognizer) {
        guard let window = UIApplication.shared._keyWindow,
              gesture.state == .changed && isVisible else {
            return
        }
        
        let origin = gesture.location(in: window)
        var newFrame = keyboardFrame
        newFrame.origin.y = max(origin.y, screenHeight - keyboardFrame.height)
        keyboardFrame = newFrame
    }
    
}

extension KeyboardObserver: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: gestureRecognizer.view)
        var view = gestureRecognizer.view?.hitTest(point, with: nil)
        while let candidate = view {
            if let scrollView = candidate as? UIScrollView, scrollView.keyboardDismissMode == .interactive {
                return true
            }
            view = candidate.superview
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer == panGesture
    }
    
}

private extension KeyboardObserver {
    
    var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
}

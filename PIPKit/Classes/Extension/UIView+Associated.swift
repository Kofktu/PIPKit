//
//  UIView+Associated.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/03.
//

import Foundation
import UIKit

extension UIView {
    
    enum AssociatedKeys {
        static var avUIKitRenderer = "avUIKitRenderer"
        static var pipVideoController = "PIPVideoController"
    }
    
    @available(iOS 15.0, *)
    var avUIKitRenderer: AVPIPUIKitRenderer? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.avUIKitRenderer) as? AVPIPUIKitRenderer }
        set { objc_setAssociatedObject(self, &AssociatedKeys.avUIKitRenderer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    @available(iOS 15.0, *)
    var videoController: AVPIPKitVideoController? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.pipVideoController) as? AVPIPKitVideoController }
        set { objc_setAssociatedObject(self, &AssociatedKeys.pipVideoController, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
}

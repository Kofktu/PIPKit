//
//  UIWindow+Extension.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/03.
//

import UIKit

extension UIApplication {
    
    var _keyWindow: UIWindow? {
        var sceneWindows: [UIWindow]?
        
        if #available(iOS 13.0, *) {
            sceneWindows = connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first { $0 is UIWindowScene }
                .flatMap { $0 as? UIWindowScene }?.windows
        }
        
        let windows = sceneWindows ?? self.windows
        return windows.first(where: \.isKeyWindow) ?? windows.first
    }
    
}

//
//  AVPIPKitUsable.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/03.
//

import Foundation
import UIKit
import AVKit

public extension PIPKit {
 
    static var isAVPIPKitSupported: Bool {
        guard #available(iOS 15.0, *) else {
            return false
        }
        
        return AVPictureInPictureController.isPictureInPictureSupported()
    }
     
}

@available(iOS 15.0, *)
public enum AVPIPKitRenderPolicy {
    
    case once
    case preferredFramesPerSecond(Int)
    
}

@available(iOS 15.0, *)
extension AVPIPKitRenderPolicy {
    
    var preferredFramesPerSecond: Int {
        switch self {
        case .once:
            return 1
        case .preferredFramesPerSecond(let preferredFramesPerSecond):
            return preferredFramesPerSecond
        }
    }
    
}

@available(iOS 15.0, *)
public protocol AVPIPKitUsable {
    
    var renderer: AVPIPKitRenderer { get }
    
    func startPictureInPicture()
    func stopPictureInPicture()
    
}

@available(iOS 15.0, *)
public extension AVPIPKitUsable {
    
    var isAVKitPIPSupported: Bool {
        PIPKit.isAVPIPKitSupported
    }
    
}


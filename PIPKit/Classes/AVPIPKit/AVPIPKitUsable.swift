//
//  AVPIPKitUsable.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/03.
//

import Foundation
import UIKit
import AVKit

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
        AVPictureInPictureController.isPictureInPictureSupported()
    }
    
    var renderPolicy: AVPIPKitRenderPolicy {
        .preferredFramesPerSecond(UIScreen.main.maximumFramesPerSecond)
    }
    
}


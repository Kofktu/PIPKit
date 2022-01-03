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
public protocol AVPIPKitUsable {
    
    var pipTargetView: UIView { get }
    var renderPolicy: AVPIPKitRenderPolicy { get }
    
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

@available(iOS 15.0, *)
public extension AVPIPKitUsable where Self: UIViewController {
    
    func startPictureInPicture() {
        setupIfNeeded()
        videoController?.start()
    }
    
    func stopPictureInPicture() {
        assert(videoController != nil)
        videoController?.stop()
    }
    
    // MARK: - Private
    private func setupIfNeeded() {
        guard videoController == nil else {
            return
        }
        
        videoController = createVideoController()
    }
    
}

@available(iOS 15.0, *)
public extension AVPIPKitUsable where Self: UIView {
    
    var pipTargetView: UIView { self }
    
    func startPictureInPicture() {
        setupIfNeeded()
        videoController?.start()
    }
    
    func stopPictureInPicture() {
        assert(videoController != nil)
        videoController?.stop()
    }
    
    // MARK: - Private
    private func setupIfNeeded() {
        guard videoController == nil else {
            return
        }
        
        videoController = createVideoController()
    }
    
}

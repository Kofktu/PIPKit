//
//  AVPIPKitUsable+UIKit.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/08.
//

import Foundation
import UIKit

@available(iOS 15.0, *)
public protocol AVPIPUIKitUsable: AVPIPKitUsable {
    
    var pipTargetView: UIView { get }
    
}

@available(iOS 15.0, *)
public extension AVPIPUIKitUsable {
    
    var renderer: AVPIPKitRenderer {
        AVPIPUIKitRenderer(targetView: pipTargetView, policy: renderPolicy)
    }
    
}

@available(iOS 15.0, *)
public extension AVPIPUIKitUsable where Self: UIViewController {
    
    var pipTargetView: UIView { view }
    
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
public extension AVPIPUIKitUsable where Self: UIView {
    
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

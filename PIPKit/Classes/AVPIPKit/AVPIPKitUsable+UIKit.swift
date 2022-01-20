//
//  AVPIPKitUsable+UIKit.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/08.
//

import Foundation
import UIKit
import Combine

@available(iOS 15.0, *)
public protocol AVPIPUIKitUsable: AVPIPKitUsable {
    
    var pipTargetView: UIView { get }
    var renderPolicy: AVPIPKitRenderPolicy { get }
    var exitPublisher: AnyPublisher<Void, Never> { get }
    
}

@available(iOS 15.0, *)
public extension AVPIPUIKitUsable {
    
    var renderPolicy: AVPIPKitRenderPolicy {
        .preferredFramesPerSecond(UIScreen.main.maximumFramesPerSecond)
    }
    
}

@available(iOS 15.0, *)
public extension AVPIPUIKitUsable where Self: UIViewController {
    
    var pipTargetView: UIView { view }
    var renderer: AVPIPKitRenderer {
        setupRendererIfNeeded()
        return avUIKitRenderer.unsafelyUnwrapped
    }
    var exitPublisher: AnyPublisher<Void, Never> {
        setupRendererIfNeeded()
        return avUIKitRenderer.unsafelyUnwrapped.exitPublisher
    }
    
    func startPictureInPicture() {
        setupIfNeeded()
        videoController?.start()
    }
    
    func stopPictureInPicture() {
        assert(videoController != nil)
        videoController?.stop()
    }
    
    // If you want to update the screen, execute the following additional code.
    func renderPictureInPicture() {
        setupRendererIfNeeded()
        avUIKitRenderer?.render()
    }
    
    // MARK: - Private
    private func setupRendererIfNeeded() {
        guard avUIKitRenderer == nil else {
            return
        }
        
        avUIKitRenderer = AVPIPUIKitRenderer(targetView: pipTargetView, policy: renderPolicy)
    }
    
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
    var renderer: AVPIPKitRenderer {
        setupRendererIfNeeded()
        return avUIKitRenderer.unsafelyUnwrapped
    }
    var exitPublisher: AnyPublisher<Void, Never> {
        setupRendererIfNeeded()
        return avUIKitRenderer.unsafelyUnwrapped.exitPublisher
    }
    
    func startPictureInPicture() {
        setupIfNeeded()
        videoController?.start()
    }
    
    func stopPictureInPicture() {
        assert(videoController != nil)
        videoController?.stop()
    }
    
    // If you want to update the screen, execute the following additional code.
    func renderPictureInPicture() {
        setupRendererIfNeeded()
        avUIKitRenderer?.render()
    }
    
    // MARK: - Private
    private func setupRendererIfNeeded() {
        guard avUIKitRenderer == nil else {
            return
        }
        
        avUIKitRenderer = AVPIPUIKitRenderer(targetView: pipTargetView, policy: renderPolicy)
    }
    
    private func setupIfNeeded() {
        guard videoController == nil else {
            return
        }
        
        videoController = createVideoController()
    }
    
}

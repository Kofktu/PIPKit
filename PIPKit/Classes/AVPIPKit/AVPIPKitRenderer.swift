//
//  AVPIPKitRenderer.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/08.
//

import Foundation
import Combine
import UIKit

@available(iOS 15.0, *)
public protocol AVPIPKitRenderer {
    
    var policy: AVPIPKitRenderPolicy { get }
    var renderPublisher: AnyPublisher<UIImage, Never> { get }
    
    func start()
    func stop()
    
}

@available(iOS 15.0, *)
final class AVPIPUIKitRenderer: AVPIPKitRenderer {
    
    let policy: AVPIPKitRenderPolicy
    var renderPublisher: AnyPublisher<UIImage, Never> {
        render.eraseToAnyPublisher()
    }
    
    private var isRunning: Bool = false
    private weak var targetView: UIView?
    private var displayLink: CADisplayLink?
    private let render = PassthroughSubject<UIImage, Never>()
    
    deinit {
        stop()
    }
    
    init(targetView: UIView, policy: AVPIPKitRenderPolicy) {
        self.targetView = targetView
        self.policy = policy
    }
    
    func start() {
        if isRunning {
            return
        }
        
        isRunning = true
        onRender()
        
        guard case .preferredFramesPerSecond(let preferredFramesPerSecond) = policy else {
            return
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(onRender))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 1, maximum: Float(preferredFramesPerSecond), preferred: 0)
        displayLink?.add(to: .main, forMode: .default)
    }
    
    func stop() {
        guard isRunning else {
            return
        }
        
        displayLink?.invalidate()
        displayLink = nil
        isRunning = false
    }
    
    // MARK: - Private
    @objc private func onRender() {
        guard let targetView = targetView else {
            stop()
            return
        }
        
        render.send(targetView.uiImage)
    }
    
}

@available(iOS 15.0, *)
private extension UIView {
    
    var uiImage: UIImage {
        UIGraphicsImageRenderer(bounds: bounds).image { context in
            layer.render(in: context.cgContext)
        }
    }
    
}

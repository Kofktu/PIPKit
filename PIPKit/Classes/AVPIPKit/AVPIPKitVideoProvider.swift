//
//  AVPIPKitVideoProvider.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/03.
//

import Foundation
import QuartzCore
import UIKit
import AVKit

@available(iOS 15.0, *)
extension AVPIPKitUsable {

    func createVideoController() -> AVPIPKitVideoController {
        AVPIPKitVideoController(targetView: pipTargetView, renderPolicy: renderPolicy)
    }
    
}

@available(iOS 15.0, *)
final class PIPVideoProvider {
    
    private(set) var isRunning: Bool = false
    
    private(set) weak var targetView: UIView?
    private(set) var bufferDisplayLayer = AVSampleBufferDisplayLayer()
    
    private let pipContainerView = UIView()
    private let renderPolicy: AVPIPKitRenderPolicy
    private var preferredFramesPerSecond: Int {
        switch renderPolicy {
        case .once:
            return 1
        case .preferredFramesPerSecond(let preferredFramesPerSecond):
            return preferredFramesPerSecond
        }
    }
    private var displayLink: CADisplayLink?
    private var targetViewSizeObservation: NSKeyValueObservation?
    
    deinit {
        stop()
        targetViewSizeObservation?.invalidate()
    }
    
    init(targetView: UIView, renderPolicy: AVPIPKitRenderPolicy) {
        self.targetView = targetView
        self.renderPolicy = renderPolicy
        
        targetViewSizeObservation = targetView.observe(\.frame, options: [.initial, .new]) { [weak self] view, _ in
            self?.pipContainerView.frame = view.bounds
            self?.bufferDisplayLayer.frame = view.bounds
        }
    }
    
    func start() {
        if isRunning {
            return
        }
        
        isRunning = true
        
        if let window = UIApplication.shared._keyWindow, let targetView = targetView {
            pipContainerView.frame = targetView.bounds
            pipContainerView.alpha = 0.0
            window.addSubview(pipContainerView)
            window.sendSubviewToBack(pipContainerView)
            bufferDisplayLayer.frame = targetView.bounds
            bufferDisplayLayer.videoGravity = .resizeAspect
            pipContainerView.layer.addSublayer(bufferDisplayLayer)
        }
        
        onRender()
        
        guard case .preferredFramesPerSecond(let preferredFramesPerSecond) = renderPolicy else {
            return
        }
        
        displayLink = CADisplayLink(target: self, selector: #selector(onRender))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 1, maximum: Float(preferredFramesPerSecond), preferred: 0)
        displayLink?.add(to: .main, forMode: .default)
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        pipContainerView.removeFromSuperview()
        bufferDisplayLayer.removeFromSuperlayer()
        isRunning = false
    }
    
    // MARK: - Private
    @objc private func onRender() {
        if bufferDisplayLayer.status == .failed {
            bufferDisplayLayer.flush()
        }
        
        guard let buffer = targetView?.uiImage.cmSampleBuffer(preferredFramesPerSecond: preferredFramesPerSecond) else {
            return
        }

        bufferDisplayLayer.enqueue(buffer)
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

private extension UIImage {
    
    func cmSampleBuffer(preferredFramesPerSecond: Int) -> CMSampleBuffer? {
        guard let jpegData = jpegData(compressionQuality: 1.0),
              let cgImage = cgImage else {
                  return nil
              }
        
        let rawPixelSize = CGSize(width: cgImage.width, height: cgImage.height)
        var format: CMFormatDescription?
        
        CMVideoFormatDescriptionCreate(
            allocator: kCFAllocatorDefault,
            codecType: kCMVideoCodecType_JPEG,
            width: Int32(rawPixelSize.width),
            height: Int32(rawPixelSize.height),
            extensions: nil,
            formatDescriptionOut: &format
        )
        
        guard let cmBlockBuffer = jpegData.toCMBlockBuffer() else {
            return nil
        }
        
        var size = jpegData.count
        var sampleBuffer: CMSampleBuffer?
        let nowTime = CMTime(seconds: CACurrentMediaTime(), preferredTimescale: CMTimeScale(preferredFramesPerSecond))
        let _1_60_s = CMTime(value: 1, timescale: CMTimeScale(preferredFramesPerSecond))
        
        var timingInfo = CMSampleTimingInfo(
            duration: _1_60_s,
            presentationTimeStamp: nowTime,
            decodeTimeStamp: .invalid
        )
        
        CMSampleBufferCreateReady(
            allocator: kCFAllocatorDefault,
            dataBuffer: cmBlockBuffer,
            formatDescription: format,
            sampleCount: 1,
            sampleTimingEntryCount: 1,
            sampleTimingArray: &timingInfo,
            sampleSizeEntryCount: 1,
            sampleSizeArray: &size,
            sampleBufferOut: &sampleBuffer
        )
        
        if sampleBuffer == nil {
            assertionFailure("SampleBuffer is null")
        }
        
        return sampleBuffer
    }
    
}

private func freeBlock(_ refCon: UnsafeMutableRawPointer?, doomedMemoryBlock: UnsafeMutableRawPointer, sizeInBytes: Int) -> Void {
    let unmanagedData = Unmanaged<NSData>.fromOpaque(refCon!)
    unmanagedData.release()
}

private extension Data {
    
    func toCMBlockBuffer() -> CMBlockBuffer? {
        let data = NSMutableData(data: self)
        var source = CMBlockBufferCustomBlockSource()
        source.refCon = Unmanaged.passRetained(data).toOpaque()
        source.FreeBlock = freeBlock
        
        var blockBuffer: CMBlockBuffer?
        let result = CMBlockBufferCreateWithMemoryBlock(
            allocator: kCFAllocatorDefault,
            memoryBlock: data.mutableBytes,
            blockLength: data.length,
            blockAllocator: kCFAllocatorNull,
            customBlockSource: &source,
            offsetToData: 0,
            dataLength: data.length,
            flags: 0,
            blockBufferOut: &blockBuffer
        )
        
        if OSStatus(result) != kCMBlockBufferNoErr {
            return nil
        }
        
        guard let buffer = blockBuffer else {
            return nil
        }
        
        assert(CMBlockBufferGetDataLength(buffer) == data.length)
        return buffer
    }
    
}


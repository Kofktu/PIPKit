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
import Combine

@available(iOS 15.0, *)
extension AVPIPKitUsable {

    func createVideoController() -> AVPIPKitVideoController {
        AVPIPKitVideoController(renderer: renderer)
    }
    
}

@available(iOS 15.0, *)
final class PIPVideoProvider {
    
    private(set) var isRunning: Bool = false
    private(set) var bufferDisplayLayer = AVSampleBufferDisplayLayer()
    private(set) var renderer: AVPIPKitRenderer
    
    private let pipContainerView = UIView()
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        stop()
    }
    
    init(renderer: AVPIPKitRenderer) {
        self.renderer = renderer
    }
        
    func start() {
        if isRunning {
            return
        }
        
        isRunning = true
        
        if let window = UIApplication.shared._keyWindow {
            pipContainerView.backgroundColor = .clear
            pipContainerView.alpha = 0.0
            window.addSubview(pipContainerView)
            window.sendSubviewToBack(pipContainerView)
            bufferDisplayLayer.backgroundColor = UIColor.clear.cgColor
            bufferDisplayLayer.videoGravity = .resizeAspect
            pipContainerView.layer.addSublayer(bufferDisplayLayer)
        }
        
        let preferredFramesPerSecond = renderer.policy.preferredFramesPerSecond
        let renderPublisher = renderer.renderPublisher
            .receive(on: DispatchQueue.main)
            .share()
        
        renderPublisher
            .map { $0.size }
            .removeDuplicates()
            .map { CGRect(origin: .zero, size: $0) }
            .sink(receiveValue: { [weak self] bounds in
                self?.pipContainerView.frame = bounds
                self?.bufferDisplayLayer.frame = bounds
            })
            .store(in: &cancellables)
        
        renderPublisher
            .map { $0.cmSampleBuffer(preferredFramesPerSecond: preferredFramesPerSecond) }
            .filter { $0 != nil }
            .map { $0.unsafelyUnwrapped }
            .sink(receiveValue: { [weak self] buffer in
                if self?.bufferDisplayLayer.status == .failed {
                    self?.bufferDisplayLayer.flush()
                }
                
                self?.bufferDisplayLayer.enqueue(buffer)
            })
            .store(in: &cancellables)
        
        renderer.start()
    }
    
    func stop() {
        guard isRunning else {
            return
        }
        
        pipContainerView.removeFromSuperview()
        bufferDisplayLayer.removeFromSuperlayer()
        renderer.stop()
        isRunning = false
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
        let presentationTimeStamp = CMTime(seconds: CACurrentMediaTime(), preferredTimescale: CMTimeScale(preferredFramesPerSecond))
        let duration = CMTime(value: 1, timescale: CMTimeScale(preferredFramesPerSecond))
        
        var timingInfo = CMSampleTimingInfo(
            duration: duration,
            presentationTimeStamp: presentationTimeStamp,
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


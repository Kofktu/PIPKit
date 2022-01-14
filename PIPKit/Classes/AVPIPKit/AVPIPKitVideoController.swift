//
//  AVPIPKitVideoController.swift
//  PIPKit
//
//  Created by Kofktu on 2022/01/03.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import Combine

@available(iOS 15.0, *)
final class AVPIPKitVideoController: NSObject {
    
    var isPIPSupported: Bool {
        AVPictureInPictureController.isPictureInPictureSupported()
    }
    
    private let videoProvider: PIPVideoProvider
    private var pipController: AVPictureInPictureController?
    private var pipPossibleObservation: NSKeyValueObservation?
    
    private var audioSessionCategory: AVAudioSession.Category?
    private var audioSessionMode: AVAudioSession.Mode?
    private var audioSessionCategoryOptions: AVAudioSession.CategoryOptions?
    
    deinit {
        pipPossibleObservation?.invalidate()
    }
    
    init(renderer: AVPIPKitRenderer) {
        videoProvider = PIPVideoProvider(renderer: renderer)
        super.init()
    }
    
    func start() {
        dispatchPrecondition(condition: .onQueue(.main))
        
        if audioSessionCategory == nil {
            cachedAndPrepareAudioSession()
        }
        
        if pipController == nil {
            prepareToPIPController()
        }
        
        if videoProvider.isRunning == false {
            videoProvider.start()
        }
        
        guard let pipController = pipController, pipController.isPictureInPicturePossible,
              pipController.isPictureInPictureActive == false else {
            return
        }
        
        pipController.startPictureInPicture()
    }
    
    func stop() {
        dispatchPrecondition(condition: .onQueue(.main))
        
        defer {
            restoreAudioSession()
        }
        
        guard videoProvider.isRunning else {
            return
        }
        
        videoProvider.stop()
        pipController?.stopPictureInPicture()
    }
    
    // MARK: - Private
    private func cachedAndPrepareAudioSession() {
        guard AVAudioSession.sharedInstance().category != .playback else {
            return
        }
        
        audioSessionCategory = AVAudioSession.sharedInstance().category
        audioSessionMode = AVAudioSession.sharedInstance().mode
        audioSessionCategoryOptions = AVAudioSession.sharedInstance().categoryOptions
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
    }
    
    private func restoreAudioSession() {
        defer {
            self.audioSessionCategory = nil
            self.audioSessionMode = nil
            self.audioSessionCategoryOptions = nil
        }
        
        guard let category = audioSessionCategory,
              let mode = audioSessionMode,
              let categoryOptions = audioSessionCategoryOptions else {
                  return
              }

        do {
            try AVAudioSession.sharedInstance().setCategory(category, mode: mode, options: categoryOptions)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
    }
    
    private func prepareToPIPController() {
        guard isPIPSupported else {
            assertionFailure("not support PIP")
            return
        }
        
        pipController = AVPictureInPictureController(
            contentSource: .init(
                sampleBufferDisplayLayer: videoProvider.bufferDisplayLayer,
                playbackDelegate: self
            )
        )
        pipController?.delegate = self
        pipPossibleObservation = pipController?.observe(
            \AVPictureInPictureController.isPictureInPicturePossible,
             options: [.initial, .new],
             changeHandler: { [weak self] _, changed in
                 DispatchQueue.main.async {
                     if changed.newValue == true {
                         self?.start()
                     }
                 }
             })
    }
    
    private func exitPIPController() {
        pipPossibleObservation?.invalidate()
        pipController = nil
        videoProvider.renderer.exit()
    }
    
}

@available(iOS 15.0, *)
extension AVPIPKitVideoController: AVPictureInPictureControllerDelegate {
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        stop()
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        exitPIPController()
    }
    
}

@available(iOS 15.0, *)
extension AVPIPKitVideoController: AVPictureInPictureSampleBufferPlaybackDelegate {
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {}
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {}
    
    func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
        CMTimeRange(start: .negativeInfinity, duration: .positiveInfinity)
    }
    func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
        false
    }
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, skipByInterval skipInterval: CMTime, completion completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
}


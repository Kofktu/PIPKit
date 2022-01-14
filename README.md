# PIPKit

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
[![CocoaPods](http://img.shields.io/cocoapods/v/PIPKit.svg?style=flat)](http://cocoapods.org/?q=name%3APIPKit%20author%3AKofktu)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>

- Picture in Picture for iOS (iPhone, iPad)

![pip_default](/Screenshot/default.gif)
![pip_transition](/Screenshot/transition.gif)

## Requirements
- iOS 8.0+
- Swift 5.0
- Xcode 11

## Installation

#### CocoaPods
PIPKit is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PIPKit'
```

#### Carthage
For iOS 8+ projects with [Carthage](https://github.com/Carthage/Carthage)

```
github "Kofktu/PIPKit"
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but Alamofire does support its use on supported platforms.

Once you have your Swift package set up, adding `PIPKit` as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
  .package(url: "https://github.com/Kofktu/PIPKit.git", .upToNextMajor(from: "1.0.0"))
]
```

## Usage

#### PIPUsable

```swift
public protocol PIPUsable {
    var initialState: PIPState { get }
    var initialPosition: PIPPosition { get }
    var insetsPIPFromSafeArea: Bool { get }
    var pipEdgeInsets: UIEdgeInsets { get }
    var pipSize: CGSize { get }
    var pipShadow: PIPShadow? { get }
    var pipCorner: PIPCorner? { get }
    func didChangedState(_ state: PIPState)
    func didChangePosition(_ position: PIPPosition)
}

```

#### PIPKit

```swift
class PIPKit {
    var isPIP: Bool
    var isActive: Bool
    var visibleViewController: PIPKitViewController?

    class func show(with viewController: PIPKitViewController, completion: (() -> Void)? = nil)
    class func dismiss(animated: Bool, completion: (() -> Void)? = nil)
}
```

#### PIPKitViewController (UIViewController & PIPUsable)
```swift
func setNeedsUpdatePIPFrame()
func startPIPMode()
func stopPIPMode()
```

## At a Glance

#### Show & Dismiss
```swift
class PIPViewController: UIViewController, PIPUsable {}

let viewController = PIPViewController()
PIPKit.show(with: viewController)
PIPKit.dismiss(animated: true)
```

#### Update PIPSize

![pip_resize](/Screenshot/resize.gif)

```swift
class PIPViewController: UIViewController, PIPUsable {
    func updatePIPSize() {
        pipSize = CGSize()
        pipEdgeInsets = UIEdgeInsets()
        setNeedsUpdatePIPFrame()
    }
}
```

#### FullScreen <-> PIP Mode
```swift
class PIPViewController: UIViewController, PIPUsable {
    func fullScreenAndPIPMode() {
        if PIPKit.isPIP {
            stopPIPMode()    
        } else {
            startPIPMode()
        }
    }

    func didChangedState(_ state: PIPState) {}
}
```

## AVPIPKitUsable
UIView that is capable of Picture-in-Picture in iOS (AVKit.framework)

<img src=https://user-images.githubusercontent.com/1860205/147901957-8716f857-3f7b-4d76-927f-e218d36137b1.PNG width=300> <img src=https://user-images.githubusercontent.com/1860205/147901962-aa23c82f-aeeb-4e8e-b840-e70397465f6d.PNG width=300>

### Requirements
- iOS 15 or higher
- Info.plist - `Audio, AirPlay and Picture in Picture` in `Background Modes`. For more information, see [Apple Documentation](https://developer.apple.com/documentation/avfoundation/media_playback_and_selection/creating_a_basic_video_player_ios_and_tvos/enabling_background_audio)

### At a Glance

```swift
var PIPKit.isAVPIPKitSupported: Bool
```

#### AVPIPKitRenderer

```swift
protocol AVPIPKitRenderer {
    
    var policy: AVPIPKitRenderPolicy { get }
    var renderPublisher: AnyPublisher<UIImage, Never> { get }
    
    func start()
    func stop()
    
}
```

#### AVPIPUIKitUsable
```swift
class View: UIView, AVPIPUIKitUsable {

    var pipTargetView: UIView { self } // Return the subview that you want to show.
    var renderPolicy: AVPIPKitRenderPolicy {
        // .once - only once render
        // .preferredFramesPerSecond - render in frames-per-second
    }
}

view.startPictureInPicture()
view.stopPictureInPicture()

class ViewController: UIViewController, AVPIPUIKitUsable {
    var pipTargetView: UIView { view } // Return the subview that you want to show.

    func start() {
        startPictureInPicture()
    }

    func stop() {
        stopPictureInPicture()
    }
}
```

## References

- UIPiPDemo (https://github.com/uakihir0/UIPiPDemo)

## Authors

Taeun Kim (kofktu), <kofktu@gmail.com>

## License

PIPKit is available under the ```MIT``` license. See the ```LICENSE``` file for more info.

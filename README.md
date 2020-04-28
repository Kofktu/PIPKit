# PIPKit

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
[![CocoaPods](http://img.shields.io/cocoapods/v/PIPKit.svg?style=flat)](http://cocoapods.org/?q=name%3APIPKit%20author%3AKofktu)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

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

## Usage

#### PIPUsable

```swift
public protocol PIPUsable {
    var initialState: PIPState { get }
    var initialPosition: PIPPosition { get }
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
func setNeedUpdatePIPSize()
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
        setNeedUpdatePIPSize()
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

## Authors

Taeun Kim (kofktu), <kofktu@gmail.com>

## License

PIPKit is available under the ```MIT``` license. See the ```LICENSE``` file for more info.

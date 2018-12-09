# PIPKit

![Swift](https://img.shields.io/badge/Swift-4.2-orange.svg)
[![CocoaPods](http://img.shields.io/cocoapods/v/PIPKit.svg?style=flat)](http://cocoapods.org/?q=name%3APIPKit%20author%3AKofktu)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

- Picture in Picture for iOS (iPhone, iPad)

<img src="/Screenshot/default.gif" width="40%" alt="default">
<img src="/Screenshot/transition.gif" width="40%" alt="transition">

## Requirements
- iOS 8.0+
- Swift 4.2
- XCode 10

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
    var pipSize: CGSize { get }
}

```

#### PIPKit

```swift
class PIPKit {
    var isPIP: Bool
    var hasPIPViewController: Bool
    
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

![alt tag](Screenshot/resize.gif)

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
}
```

## Authors

Taeun Kim (kofktu), <kofktu@gmail.com>

## License

PIPKit is available under the ```MIT``` license. See the ```LICENSE``` file for more info.

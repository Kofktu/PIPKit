//
//  ViewController.swift
//  Example
//
//  Created by Kofktu on 2022/01/03.
//

import UIKit
import PIPKit

class ViewController: UIViewController {

    class func viewController() -> ViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController else {
            fatalError("ViewController is null")
        }
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "PIPKit"
    }
    
    // MARK: - Private
    private func setupDismissNavigationItem() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                           target: self,
                                                           action: #selector(onDismiss(_:)))
    }

    // MARK: - Action
    @objc
    private func onDismiss(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onPIPViewController(_ sender: UIButton) {
        PIPKit.show(with: PIPViewController())
    }
    
    @IBAction private func onPIPViewControllerWithXib(_ sender: UIButton) {
        PIPKit.show(with: PIPXibViewController.viewController())
    }
    
    @IBAction private func onPIPDismiss() {
        PIPKit.dismiss(animated: true)
    }
    
    @IBAction private func onPushViewController(_ sender: UIButton) {
        let viewController = ViewController.viewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction private func onPresentViewController(_ sender: UIButton) {
        let viewController = ViewController.viewController()
        let naviController = UINavigationController(rootViewController: viewController)
        present(naviController, animated: true) { [unowned viewController] in
            viewController.setupDismissNavigationItem()
        }
    }
    
    @IBAction private func onAVPIPKitStart() {
        guard #available(iOS 15.0, *), isAVKitPIPSupported else {
            print("AVPIPKit not supported")
            return
        }
        
        startPictureInPicture()
    }
    
    @IBAction private func onAVPIPKitStop() {
        guard #available(iOS 15.0, *), isAVKitPIPSupported else {
            print("AVPIPKit not supported")
            return
        }
        
        stopPictureInPicture()
    }
    
}

class PIPViewController: UIViewController, PIPUsable {
    
//    var initialState: PIPState { return .pip }
//    var pipSize: CGSize { return CGSize(width: 200.0, height: 200.0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 1.0
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if PIPKit.isPIP {
            stopPIPMode()
        } else {
            startPIPMode()
        }
    }
    
    func didChangedState(_ state: PIPState) {
        switch state {
        case .pip:
            print("PIPViewController.pip")
        case .full:
            print("PIPViewController.full")
        }
    }
    
}

class PIPXibViewController: UIViewController, PIPUsable {
    
    var initialState: PIPState { return .full }
    var initialPosition: PIPPosition { return .topRight }
    var pipEdgeInsets: UIEdgeInsets { return UIEdgeInsets(top: 30, left: 20, bottom: 30, right: 20) }
    var pipSize: CGSize = CGSize(width: 100.0, height: 100.0)
    var pipShadow: PIPShadow? = nil
    var pipCorner: PIPCorner? = nil
 
    class func viewController() -> PIPXibViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "PIPXibViewController") as? PIPXibViewController else {
            fatalError("PIPXibViewController is null")
        }
        return viewController
    }
    
    func didChangedState(_ state: PIPState) {
        switch state {
        case .pip:
            print("PIPXibViewController.pip")
        case .full:
            print("PIPXibViewController.full")
        }
    }
    
    func didChangePosition(_ position: PIPPosition) {
        switch position {
        case .topLeft:
            print("PIPXibViewController.topLeft")
        case .middleLeft:
            print("PIPXibViewController.middleLeft")
        case .bottomLeft:
            print("PIPXibViewController.bottomLeft")
        case .topRight:
            print("PIPXibViewController.topRight")
        case .middleRight:
            print("PIPXibViewController.middleRight")
        case .bottomRight:
            print("PIPXibViewController.bottomRight")
        }
    }
    
    // MARK: - Action
    @IBAction private func onFullAndPIP(_ sender: UIButton) {
        if PIPKit.isPIP {
            stopPIPMode()
        } else {
            startPIPMode()
        }
    }
    
    @IBAction private func onUpdatePIPSize(_ sender: UIButton) {
        pipSize = CGSize(width: 100 + Int(arc4random_uniform(100)),
                         height: 100 + Int(arc4random_uniform(100)))
        setNeedsUpdatePIPFrame()
    }
    
    @IBAction private func onDismiss(_ sender: UIButton) {
        PIPKit.dismiss(animated: true) {
            print("PIPXibViewController.dismiss")
        }
    }
}

@available(iOS 15.0, *)
extension ViewController: AVPIPUIKitUsable {
    
    var pipTargetView: UIView {
        view
    }
    
}

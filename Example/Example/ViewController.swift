//
//  ViewController.swift
//  Example
//
//  Created by Taeun Kim on 07/12/2018.
//  Copyright © 2018 Kofktu. All rights reserved.
//

import UIKit
import PIPKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        PIPKit.show(with: PIPViewController())
//        PIPKit.show(with: PIPXibViewController.viewController())
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
    
}

class PIPXibViewController: UIViewController, PIPUsable {
    
    var initialState: PIPState { return .full }
    var pipSize: CGSize = CGSize(width: 100.0, height: 100.0)
 
    class func viewController() -> PIPXibViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "PIPXibViewController") as? PIPXibViewController else {
            fatalError("PIPXibViewController is null")
        }
        return viewController
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
        setNeedUpdatePIPSize()
    }
    
    @IBAction private func onDismiss(_ sender: UIButton) {
        PIPKit.dismiss(animated: true) {
            print("PIPXibViewController.dismiss")
        }
    }
}

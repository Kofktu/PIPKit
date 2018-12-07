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
    }

}

class PIPViewController: UIViewController, PIPUsable {
    
    var initialState: PIPState { return .pip }
    var pipSize: CGSize { return CGSize(width: 200.0, height: 200.0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 1.0
    }
}

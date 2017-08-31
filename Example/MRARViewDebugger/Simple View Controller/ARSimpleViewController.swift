//
//  ARSimpleViewController.swift
//  ARStreamVisualizer
//
//  Created by Matt Robinson on 8/31/17.
//  Copyright © 2017 Robinson Bros. All rights reserved.
//

import UIKit

import MRARViewDebugger

class ARSimpleViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = UIImage(named: "IMG_0076.JPG")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Actions

    @IBAction func startDebugging() {
        let debugger = MRARViewDebuggerViewController.init(withViewController: self)
        self.present(debugger, animated: true, completion: nil)
    }
}

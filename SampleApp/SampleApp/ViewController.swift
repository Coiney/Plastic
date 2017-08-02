//
//  ViewController.swift
//  SampleApp
//
//  Created by Ken Myers on 2017/07/31.
//  Copyright © 2017 Coiney. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var cardEntryView: CYCardEntryView?

    override func viewDidLoad() {
        super.viewDidLoad()
        cardEntryView?.collapsesCardNumberField = true;
    }

}

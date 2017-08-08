//
//  ViewController.swift
//  SampleApp
//
//  Created by Ken Myers on 2017/07/31.
//  Copyright © 2017 Coiney. All rights reserved.
//

import UIKit
import Plastic

class ViewController: UIViewController, CYCardEntryViewDelegate {
    
    // Card number entry
    @IBOutlet var cardEntryView: CYCardEntryView?
    @IBOutlet var hintLabel: UILabel?
    
    // Horizontal list of card brands
    @IBOutlet var brandListView: CYCardBrandListView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        cardEntryView?.collapsesCardNumberField = true;
        cardEntryView?.hintLabel = hintLabel
        cardEntryView?.delegate = self
        brandListView?.brandMask = CYCardBrandMask.all
    }
    
    func cardEntryView(_ aView: CYCardEntryView!, validityDidChange aFlag: Bool) {
        self.navigationItem.rightBarButtonItem?.isEnabled = aFlag
    }

}

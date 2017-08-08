//
//  ViewController.swift
//  SampleApp
//
//  Created by Ken Myers on 2017/07/31.
//  Copyright © 2017 Coiney. All rights reserved.
//

import UIKit
import Plastic

class ViewController: UIViewController {
    
    // Card number entry
    @IBOutlet var cardEntryView: CYCardEntryView?
    @IBOutlet var hintLabel: UILabel?
    
    // Horizontal list of card brands
    @IBOutlet var brandListView: CYCardBrandListView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardEntryView?.collapsesCardNumberField = true;
        cardEntryView?.hintLabel = hintLabel
        brandListView?.brandMask = CYCardBrandMask.all
    }
    
}

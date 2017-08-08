//
//  ViewController.swift
//  SampleApp
//
//  Created by Ken Myers on 2017/07/31.
//  Copyright © 2017 Coiney. All rights reserved.
//

import UIKit
import Plastic

class ViewController: UIViewController, CYCardEntryViewDelegate, CYKeypadDelegate {
    
    // Horizontal list of card brands
    @IBOutlet var brandListView: CYCardBrandListView?
    
    // Card number entry
    @IBOutlet var cardEntryView: CYCardEntryView?
    @IBOutlet var hintLabel: UILabel?
    
    // Keypad
    @IBOutlet var keypad: CYKeypad?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        cardEntryView?.collapsesCardNumberField = true;
        cardEntryView?.hintLabel = hintLabel
        cardEntryView?.setUsesSystemKeyboard(false)
        cardEntryView?.delegate = self
        brandListView?.brandMask = CYCardBrandMask.all
        keypad?.delegate = self
    }
    
    func cardEntryView(_ aView: CYCardEntryView!, validityDidChange aFlag: Bool) {
        self.navigationItem.rightBarButtonItem?.isEnabled = aFlag
    }
    
    func keypadDidPressBackspace(_ aView: CYKeypad!) {
        cardEntryView?.backspace()
    }
    
    func keypad(_ aView: CYKeypad!, didPressNumericalKey aKey: UInt) {
        cardEntryView?.insertText(String(format: "%u", aKey))
    }

}

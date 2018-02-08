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
        
        // Set up accepted brands list
        brandListView?.brandMask = CYCardBrandMask.all
        
        // Set up card number field
        cardEntryView?.collapsesCardNumberField = true;
        cardEntryView?.hintLabel = hintLabel
        cardEntryView?.updateHintLabel()
        cardEntryView?.setUsesSystemKeyboard(false)
        cardEntryView?.delegate = self
        
        // Set up keypad
        keypad?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardEntryView?.becomeFirstResponder()
    }
    
    func cardEntryView(_ aView: CYCardEntryView!, validityDidChange aFlag: Bool) {
        self.navigationItem.rightBarButtonItem?.isEnabled = aFlag
        
        if (aFlag) {
            // Send aView.cardNumber, aView.expiryDate, and aView.cvc to your payment processor
        }
    }
    
    func keypadDidPressBackspace(_ aView: CYKeypad!) {
        cardEntryView?.backspace()
    }
    
    func keypad(_ aView: CYKeypad!, didPressNumericalKey aKey: UInt) {
        cardEntryView?.insertText(String(format: "%u", aKey))
    }

}

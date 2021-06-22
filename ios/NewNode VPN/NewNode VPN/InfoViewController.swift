//
//  InfoViewController.swift
//  NewNode VPN
//
//  Created by Mikhail Koroteev on 05/31/21.
//  Copyright © 2021 Clostra. All rights reserved.
//

import Foundation
import UIKit

class InfoViewController: UIViewController {
    @IBOutlet weak var infoHeader: UITextView!
    @IBOutlet weak var infoText: UITextView!
    
    @IBAction func tapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoText.text = NSLocalizedString("info_text", comment: "")
        infoHeader.text = NSLocalizedString("info_title", comment: "")
        infoHeader.adjustsFontForContentSizeCategory = true
        
        if UIScreen.main.nativeBounds.height < 1200 {
            infoText.font = UIFont.systemFont(ofSize: 14.0)
            infoHeader.font = UIFont.systemFont(ofSize: 22.0)
        }
    }
}

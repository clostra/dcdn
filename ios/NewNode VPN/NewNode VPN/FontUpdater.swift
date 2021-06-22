//
//  FontUpdater.swift
//  NewNode VPN
//
//  Created by Mikhail Koroteev on 06/02/21.
//  Copyright © 2021 Clostra. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    func with(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits).union(self.fontDescriptor.symbolicTraits)) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }

    func without(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = self.fontDescriptor.withSymbolicTraits(self.fontDescriptor.symbolicTraits.subtracting(UIFontDescriptor.SymbolicTraits(traits))) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
}

extension UIButton {
    func underline( bold: Bool ) {
        guard let text = self.titleLabel?.text else { return }
        guard let color = self.titleColor(for: .normal) else { return }
        guard var font = self.titleLabel?.font else { return }
        if bold {
            font = font.with(.traitBold)
        } else {
            font = font.without(.traitBold)
        }
        
        let attributedString = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: text.count)
        let attributes: [NSAttributedString.Key : Any] =
            [.font : font,
             .underlineColor : color,
             .foregroundColor : color,
             .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        attributedString.addAttributes(attributes, range: range)
        self.setAttributedTitle(attributedString, for: .normal)
    }
}



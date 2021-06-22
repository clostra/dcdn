//
//  GradientView.swift
//  NewNode VPN
//
//  Created by Mikhail Koroteev on 05/25/21.
//  Copyright © 2021 Clostra. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
final class GradientView: UIView {
    @IBInspectable var startColor: UIColor = UIColor.clear {
        didSet {
            updateGradient()
        }
    }
    @IBInspectable var endColor: UIColor = UIColor.clear {
        didSet {
            updateGradient()
        }
    }
    
    private var gradient = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(gradient)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.addSublayer(gradient)
    }
    
    private func updateGradient() {
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        if bounds.isEmpty {
            return
        }
        let ux = bounds.width / bounds.height
        let uy = bounds.height / bounds.width
        let coef = (ux + uy) / (ux * ux + uy * uy)
        
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: coef * ux, y: coef * uy)
        gradient.zPosition = -1
        gradient.frame = bounds
        setNeedsDisplay()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradient()
    }
}


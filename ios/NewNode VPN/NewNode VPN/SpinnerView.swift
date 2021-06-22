//
//  Spinner.swift
//  NewNode VPN
//
//  Created by Mikhail Koroteev on 06/02/21.
//  Copyright © 2021 Clostra. All rights reserved.
//

import Foundation
import UIKit


//
//  Spinner.swift
//  Search
//
//  Created by Vinay Jain on 7/19/15.
//  Copyright (c) 2015 Vinay Jain. All rights reserved.
//


@IBDesignable
class SpinnerView: UIView {
    @IBInspectable var outerAnimationDuration : CGFloat = 2
    @IBInspectable var innerAnimationDuration : CGFloat = 1
    
    var arcViews = [UIImageView(), UIImageView()]
    var innerView: UIImageView {arcViews[0]}
    var outerView: UIImageView {arcViews[1]}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit(){
        backgroundColor = UIColor.clear
        for view in arcViews {
            addSubview(view)
        }
        
        innerView.image = UIImage(named:"inner_arc")
        outerView.image = UIImage(named:"outer_arc")
    }
    
    override func draw(_ rect: CGRect) {
        for view in arcViews {
            view.frame = CGRect(x: 0 , y: 0, width: rect.size.width, height: rect.size.height)
            view.center = self.convert(center, from: superview!)
        }
        startAnimating()
    }
    
    func rotationAnimation(duration: CGFloat, clockwise: Bool) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = clockwise ? 0 : 2 * Double.pi
        animation.toValue = clockwise ? 2 * Double.pi : 0
        animation.duration = Double(duration)
        animation.repeatCount = HUGE
        return animation
    }
    
    func animateInnerRing() {
        let animation = rotationAnimation(duration: innerAnimationDuration, clockwise: true)
        innerView.layer.add(animation, forKey: "rotateInner")
    }
    
    func animateOuterRing() {
        let animation = rotationAnimation(duration: outerAnimationDuration, clockwise: false)
        outerView.layer.add(animation, forKey: "rotateOuter")
    }
    
    func startAnimating() {
        if !isHidden {
            return
        }
        
        isHidden = false
        animateOuterRing()
        animateInnerRing()
    }
    
    func stopAnimating() {
        isHidden = true
        for view in arcViews {
            view.layer.removeAllAnimations()
        }
    }
}

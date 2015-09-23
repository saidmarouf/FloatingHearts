//
//  HeartView.swift
//  FloatingHeart
//
//  Created by Said Marouf on 9/22/15.
//  Copyright © 2015 Said Marouf. All rights reserved.
//

import UIKit
import Foundation

//MARK :- Themes

struct HeartTheme {
    let fillColor: UIColor
    let strokeColor: UIColor
    //using white borders for this example. Set your colors.
    static let availableThemes = [
        (UIColor(hex: 0xe66f5e), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0x6a69a0), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0x81cc88), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0xfd3870), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0x6ecff6), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0xc0aaf7), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0xf7603b), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0x39d3d3), UIColor(white: 1.0, alpha: 0.8)),
        (UIColor(hex: 0xfed301), UIColor(white: 1.0, alpha: 0.8))
    ]
    ///return random theme from selection above
    static func randomTheme() -> HeartTheme {
        let r = Int(randomNumber(availableThemes.count))
        return HeartTheme(fillColor: availableThemes[r].0, strokeColor: availableThemes[r].1)
    }
}


//MARK :- HeartView

let PI = CGFloat(M_PI)

class HeartView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
        layer.anchorPoint = CGPointMake(0.5, 1) //mid-bottom
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Perform the floating heart animation.
    ///Many of the values were adjusted to feel as nice and as close as possible to Periscope's.
    ///You should play around with different values to suit your specific use-case.
    func animateInView(view: UIView) {
        
        let totalAnimationDuration: NSTimeInterval = 6
        let heartSize = CGRectGetWidth(self.bounds)
        let heartCenterX = self.center.x
        let viewHeight = CGRectGetHeight(view.bounds)
        
        //Pre-Animation setup
        self.transform = CGAffineTransformMakeScale(0, 0)
        self.alpha = 0
        
        //Bloom
        spring(0.5, delay: 0.0, damping: 0.6, velocity: 0.8) {
            self.transform = CGAffineTransformIdentity
            self.alpha = 0.9
        }

        //Slight rotation
        let rotationDirection: Int = (1 - Int(2*randomNumber(2))) // -1 OR 1
        let rotationFraction = randomNumber(10)
        animate(totalAnimationDuration, delay: 0) {
            self.transform = CGAffineTransformMakeRotation(CGFloat(rotationDirection) * PI/(16 + rotationFraction*0.2))
        }
        
        
        //Travel along path
        let heartTravelPath = UIBezierPath()
        heartTravelPath.moveToPoint(self.center)
        
        //random end point
        let endPoint = CGPointMake(heartCenterX + (CGFloat(rotationDirection) * randomNumber(2*heartSize)), viewHeight/6.0 + randomNumber(viewHeight/4.0))
        
        //random Control Points
        let travelDirection: Int = (1 - Int(2*randomNumber(2))) // -1 OR 1
        
        //randomize x and y for control points
        let xDelta = (heartSize/2.0 + randomNumber(2*heartSize)) * CGFloat(travelDirection)
        let yDelta = max(endPoint.y ,max(randomNumber(8*heartSize), heartSize))
        
        let controlPoint1 = CGPointMake(heartCenterX + xDelta, viewHeight - yDelta)
        let controlPoint2 = CGPointMake(heartCenterX - 2*xDelta, yDelta)
        
        heartTravelPath.addCurveToPoint(endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        let keyFrameAnimation = CAKeyframeAnimation(keyPath: "position")
        keyFrameAnimation.path = heartTravelPath.CGPath
        keyFrameAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        keyFrameAnimation.duration = totalAnimationDuration + NSTimeInterval(endPoint.y/viewHeight)
        self.layer.addAnimation(keyFrameAnimation, forKey: "positionOnPath")
        
        
        //Alpha
        animate(totalAnimationDuration, delay: 0,
            animations: {
                self.alpha = 0.0
            },
            completion: {
                self.removeFromSuperview()
            }
        )
    }
    
    
    override func drawRect(rect: CGRect) {

#if true

        let theme = HeartTheme.randomTheme()
    
        let heartImage = UIImage(named: "heart")
        let heartImageBorder = UIImage(named: "heartBorder")
    
        //Draw background image (mimics border)
        theme.strokeColor.setFill()
        heartImageBorder?.drawInRect(rect, blendMode: .Normal, alpha: 1.0)

        //Draw foreground heart image
        theme.fillColor.setFill()
        heartImage?.drawInRect(rect, blendMode: .Normal, alpha: 1.0)
#else
        //Just for fun. Draw heart using Bezier path
        drawHeartInRect(rect)
#endif
    }
    
    private func drawHeartInRect(rect: CGRect) {
        
        let theme = HeartTheme.randomTheme()

        theme.strokeColor.setStroke()
        theme.fillColor.setFill()
        
        let drawingPadding: CGFloat = 4.0
        let curveRadius = floor((CGRectGetWidth(rect) - 2*drawingPadding) / 4.0)
        
        //Creat path
        let heartPath = UIBezierPath()
        
        //Start at bottom heart tip
        let tipLocation = CGPointMake(floor(CGRectGetWidth(rect) / 2.0), CGRectGetHeight(rect) - drawingPadding)
        heartPath.moveToPoint(tipLocation)
        
        //Move to top left start of curve
        let topLeftCurveStart = CGPointMake(drawingPadding, floor(CGRectGetHeight(rect) / 2.4))
        heartPath.addQuadCurveToPoint(topLeftCurveStart, controlPoint: CGPointMake(topLeftCurveStart.x, topLeftCurveStart.y + curveRadius))
        
        //Create top left curve
        heartPath.addArcWithCenter(CGPointMake(topLeftCurveStart.x + curveRadius, topLeftCurveStart.y), radius: curveRadius, startAngle: PI, endAngle: 0, clockwise: true)
        
        //Create top right curve
        let topRightCurveStart = CGPointMake(topLeftCurveStart.x + 2*curveRadius, topLeftCurveStart.y)
        heartPath.addArcWithCenter(CGPointMake(topRightCurveStart.x + curveRadius, topRightCurveStart.y), radius: curveRadius, startAngle: PI, endAngle: 0, clockwise: true)
        
        //Final curve to bottom heart tip
        let topRightCurveEnd = CGPointMake(topLeftCurveStart.x + 4*curveRadius, topRightCurveStart.y)
        heartPath.addQuadCurveToPoint(tipLocation, controlPoint: CGPointMake(topRightCurveEnd.x, topRightCurveEnd.y + curveRadius))
        
        heartPath.fill()
        
        heartPath.lineWidth = 1
        heartPath.lineCapStyle = .Round
        heartPath.lineJoinStyle = .Round
        heartPath.stroke()
    }
}

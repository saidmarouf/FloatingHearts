//
//  TimerHelpers.swift
//  FloatingHeart
//
//  Created by Said Marouf on 9/23/15.
//  Copyright © 2015 Said Marouf. All rights reserved.
//

import Foundation
import UIKit

///Hoping to demonstrate how these helpers can be useful in any project.
///For the sake of this example, they can be seen as an overkill. But we're having fun.

// MARK: Color Helpers

public extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(red: ((hex >> 16) & 0xFF), green: ((hex >> 8) & 0xFF), blue: (hex & 0xFF))
    }
}


// MARK: Timer Helpers

//Stripped down extension - similar to SwiftTimer https://github.com/radex/SwiftyTimer
private class TimerActor {
    
    let fireBlock: (() -> Void)
    
    init(_ block: @escaping () -> Void) {
        fireBlock = block
    }
    
    @objc func fire() {
        fireBlock()
    }
}

extension Timer {
    
    public class func new(interval: TimeInterval, block: @escaping (() -> Void)) -> Timer {
        let timerActor = TimerActor(block)
        return self.init(timeInterval: interval, target: timerActor, selector: #selector(fire), userInfo: nil, repeats: false)
    }
    
    public static func after(interval: TimeInterval, block: @escaping (() -> Void)) -> Timer {
        let timer = Timer.new(interval: interval, block: block)
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        return timer
    }
}


// MARK: Animaition Helpers

public func spring(duration: TimeInterval, delay: TimeInterval, damping: CGFloat, velocity: CGFloat, animations: @escaping () -> Void) {
    
    UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [UIView.AnimationOptions.curveEaseOut], animations: {
            animations()
        }, completion: nil)
}

public func animate(duration: TimeInterval, delay: TimeInterval, animations: @escaping () -> Void, completion: @escaping () -> Void) {
    
    UIView.animate(withDuration: duration, delay: delay, options: [], animations: {
        animations()
        }, completion: { finished in
            completion()
    })
}

public func animate(duration: TimeInterval, delay: TimeInterval, animations: @escaping () -> Void) {
    
    UIView.animate(withDuration: duration, delay: delay, options: [], animations: {
        animations()
        }, completion: { finished in
    })
}

// MARK: Math Helpers

//Briefly investigated creating a generic function to accept various numeric types. 
//Seems too much work at this stage. For another time...

public func randomNumber(cap: Int) -> CGFloat {
    return CGFloat(arc4random_uniform(UInt32(cap)))
}

public func randomNumber(cap: CGFloat) -> CGFloat {
    return randomNumber(cap: Int(cap))
}


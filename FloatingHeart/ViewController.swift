//
//  ViewController.swift
//  FloatingHeart
//
//  Created by Said Marouf on 9/22/15.
//  Copyright © 2015 Said Marouf. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {

    let heartSize: CGFloat = 36
    var burstTimer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0xf2f4f6)

        let tapGesture = UITapGestureRecognizer(target: self, action: "showTheLove:")
        view.addGestureRecognizer(tapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "didLongPress:")
        longPressGesture.minimumPressDuration = 0.2
        view.addGestureRecognizer(longPressGesture)
    }
    
    func didLongPress(longPressGesture: UILongPressGestureRecognizer) {

        switch longPressGesture.state {
        case .Began:
            burstTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "showTheLove:", userInfo: nil, repeats: true)
        case .Ended, .Cancelled:
            burstTimer?.invalidate()
        default:
            break
        }
    }

    func showTheLove(gesture: UITapGestureRecognizer?) {
        let heart = HeartView(frame: CGRectMake(0, 0, heartSize, heartSize))
        view.addSubview(heart)
        let fountainSource = CGPointMake(20 + heartSize/2.0, self.view.bounds.height - heartSize/2.0 - 10)
        heart.center = fountainSource
        heart.animateInView(self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

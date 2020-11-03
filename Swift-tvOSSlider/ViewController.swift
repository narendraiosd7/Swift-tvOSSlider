//
//  ViewController.swift
//  Swift-tvOSSlider
//
//  Created by narendra. vadde on 03/11/20.
//

import UIKit
import GameController

class ViewController: UIViewController {

    @IBOutlet weak var maxTrackView: UIView!
    @IBOutlet weak var minTrackView: UIView!
    @IBOutlet weak var thumbView: UIView!
    @IBOutlet weak var minTrackWidth: NSLayoutConstraint!
    
    let animationDuration: TimeInterval = 0.3
    let defaultValue:Float =  0
    let defaultMinValue: Float = 0
    let defaultMaxValue: Float = 1
    let defaultIsContinuous: Bool = true
    let thumbColor: UIColor = .white
    let defaultTrackColor: UIColor = .gray
    let minTrackColor: UIColor = .yellow
    let focusScaleFactor: CGFloat = 1.1
    let defaultStepValue: Float = 0.1
    let decelerationRate: Float = 0.92
    let decelerationMaxValue : Float = 1000
    let fineTunningVelocityThreshold: Float = 600
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}



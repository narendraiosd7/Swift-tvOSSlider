//
//  SlderView.swift
//  Swift-tvOSSlider
//
//  Created by narendra. vadde on 03/11/20.
//

import UIKit

protocol SliderViewDelegate: class {
    func slider(_ slider: SliderView, textWithValue value: Double) -> String
    func sliderDidTap(_ slide: SliderView)
    func slider(_ slider: SliderView, didChangeValue value: Double)
    func Slider(_ slider: SliderView, didUpdateFocusInContext context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator)
}

extension SliderViewDelegate {
    func slider(_ slider: SliderView, textWithValue value: Double) -> String {
        return "\(Int(value))"
    }
    
    func sliderDidTap(_ slide: SliderView) {
        
    }
    
    func slider(_ slider: SliderView, didChangeValue value: Double) {
        
    }
    
    func Slider(_ slider: SliderView, didUpdateFocusInContext context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        
    }
}

class SliderView: UIView {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var seekThumbView: UIView!
    @IBOutlet weak var seekerLabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    @IBOutlet weak var seekerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var seekBarView: UIView!
    
    var value: Double = 0 {
        didSet {
            updateViews()
            delegate?.slider(self, didChangeValue: value)
        }
    }
    
    var max: Double = 100{
        didSet {
            updateViews()
        }
    }
    
    var min: Double = 0 {
        didSet {
            updateViews()
        }
    }
    
    var delegate: SliderViewDelegate?
    var animationSpeed: Double = 1.0
    var decelerationRate: CGFloat = 0.92
    var decelerationMaxVelocity: CGFloat = 1000
    
    override var canBecomeFocused: Bool {
        return true
    }
    
    var seekerViewLeadingConstraintConstant: CGFloat = 0
    var decelerationTimer: Timer?
    var decelerationVelocity: CGFloat = 0
    var distance: Double {
        return 100
    }
    
    func updateViews() {
        if distance == 0 {
            return
        }
        
        leftLabel.text = "\(min)"
        rightLabel.text = "\(max)"
        seekerViewLeadingConstraint.constant = (barView.frame.width * CGFloat((value - min)/distance))
        seekerLabel.text = delegate?.slider(self, textWithValue: value) ?? "\(Int(value))"
    }
    
    func stopDecelerationTimer() {
        decelerationTimer?.invalidate()
        decelerationTimer = nil
        decelerationVelocity = 0
    }
    
    func set(value: Double, animated: Bool) {
        stopDecelerationTimer()
        if distance == 0 {
            self.value = value
            return
        }
        
        let duration = fabs(self.value - value) / self.distance * animationSpeed
        self.value = value
        
        if animated {
            UIView.animate(withDuration: duration) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        } else {
            self.value = value
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        updateViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        xibSetup()
        updateViews()
    }
    
    func xibSetup() {
        backgroundView = loadXibFromNib()
        backgroundView.frame = bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(backgroundView)
    }
    
    private func loadXibFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "SliderView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        updateViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        barView.layer.cornerRadius = barView.frame.size.height/2
        barView.backgroundColor = .gray
        seekThumbView.layer.cornerRadius = 15
        seekBarView.layer.cornerRadius = seekBarView.frame.size.height/2
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(panGestureRecognizer:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(tapGestureRecognizer:)))
        addGestureRecognizer(tapGesture)
    }
    
    public override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        if context.nextFocusedView == self {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.seekerLabel.textColor = .black
            }, completion: nil)
            
        } else if context.previouslyFocusedView == self {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.seekerLabel.textColor = .white
            }, completion: nil)
        }
    }
    
    @objc func handlePanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: self)
        let velocity = panGestureRecognizer.velocity(in: self)
        switch panGestureRecognizer.state {
        case .began:
            stopDecelerationTimer()
            seekerViewLeadingConstraintConstant = seekerViewLeadingConstraint.constant
        case .changed:
            let leading = seekerViewLeadingConstraintConstant + translation.x / 5
            set(percentage: Double(leading / barView.frame.width))
        case .ended, .cancelled:
            seekerViewLeadingConstraintConstant = seekerViewLeadingConstraint.constant
            
            let direction: CGFloat = velocity.x > 0 ? 1 : -1
            decelerationVelocity = abs(velocity.x) > decelerationMaxVelocity ? decelerationMaxVelocity * direction : velocity.x
            decelerationTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(handleDeceleratingTimer(timer:)), userInfo: nil, repeats: true)
        default:
            break
        }
    }
    
    @objc func handleTapGesture(tapGestureRecognizer: UITapGestureRecognizer) {
        stopDecelerationTimer()
        delegate?.sliderDidTap(self)
    }
    
    @objc func handleDeceleratingTimer(timer: Timer) {
        let leading = seekerViewLeadingConstraintConstant + decelerationVelocity * 0.01
        set(percentage: Double(leading / barView.frame.width))
        seekerViewLeadingConstraintConstant = seekerViewLeadingConstraint.constant
        
        decelerationVelocity *= decelerationRate
        if !isFocused || abs(decelerationVelocity) < 1 {
            stopDecelerationTimer()
        }
    }
    
    private func set(percentage: Double) {
        self.value = distance * Double(percentage > 1 ? 1 : (percentage < 0 ? 0 : percentage)) + min
    }
}

extension SliderView: UIGestureRecognizerDelegate {
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: self)
            if abs(translation.x) > abs(translation.y) {
                return isFocused
            }
        }
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

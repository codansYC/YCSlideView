//
//  SlideView.swift
//  YCSlideView
//
//  Created by yuanchao on 2018/3/22.
//  Copyright © 2018年 yuanchao. All rights reserved.
//

import UIKit

import UIKit

class SlideView: UIView {
    
    enum Direction {
        case left, right
    }
    
    public var bgViewOpcity: CGFloat = 0.3
    public let defaultWidth: CGFloat = 220
    public var isShow = false
    public var width: CGFloat {
        get {
            return bounds.width
        }
        set {
            frame.size.width = newValue
        }
    }
    
    private let SCREENWIDTH = UIScreen.main.bounds.width
    private let SCREENHEIGHT = UIScreen.main.bounds.height
    
    private var screenPan: UIScreenEdgePanGestureRecognizer!
    private let bgView = UIView()
    private var direction = Direction.left
    
    private var minX: CGFloat {
        return direction == .left ? -width : SCREENWIDTH - width }
    private var maxX: CGFloat {
        return direction == .left ? 0 : SCREENWIDTH }
    private var midX: CGFloat {
        return (maxX + minX) / 2 }
    private var currentX: CGFloat { return frame.origin.x }
    private var bgViewCurrentColor: UIColor {
        let offset = direction == .left ? currentX - minX : maxX - currentX
        let alphaComponent = bgViewOpcity * offset / (maxX - minX)
        return UIColor.black.withAlphaComponent(alphaComponent)
    }
    
    init(direction: Direction = .left, width: CGFloat? = nil) {
        super.init(frame: .zero)
        self.direction = direction
        let w = width ?? defaultWidth
        let x = direction == .left ? -w : SCREENWIDTH
        frame = CGRect.init(x: x, y: 0, width: w, height: SCREENHEIGHT - 64)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.white
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
        
        let bgVPan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        bgView.addGestureRecognizer(bgVPan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        bgView.addGestureRecognizer(tap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let superview = superview else { return }
        
        if screenPan == nil {
            screenPan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            screenPan.edges = direction == .left ? .left : .right
            superview.addGestureRecognizer(screenPan)
        }
        frame.size.height = superview.bounds.height
        bgView.frame = superview.bounds
    }
    
    @objc private func handlePan(_ pan:UIPanGestureRecognizer) {
        
        let pt = pan.translation(in: superview)
        let tempX = currentX + pt.x
        if tempX > maxX {
            frame.origin.x = maxX
        } else if tempX < minX {
            frame.origin.x = minX
        } else {
            frame.origin.x = tempX
        }
        
        changeBgViewColor()
        
        switch pan.state {
        case .cancelled, .ended:
            if pan.velocity(in: superview).x < -1500 {
                direction == .left ? dismiss() : show()
            } else if pan.velocity(in: superview).x > 1500 {
                direction == .left ? show() : dismiss()
            } else {
                if direction == .left {
                    currentX > midX ? show() : dismiss()
                } else {
                    currentX > midX ? dismiss() : show()
                }
            }
            
        default:
            break
        }
        
        pan.setTranslation(CGPoint.zero, in: superview)
        
    }
    
    @objc public func show(in view: UIView? = nil) {
        if let v = view {
            removeFromSuperview()
            v.addSubview(self)
        }
        if superview == nil {
            return
        }
        showBgView()
        isShow = true
        UIView.animate(withDuration: 0.3, animations: {
            if self.direction == .left {
                self.frame.origin.x = self.maxX
            } else {
                self.frame.origin.x = self.minX
            }
            self.bgView.backgroundColor = UIColor.black.withAlphaComponent(self.bgViewOpcity)
        })
    }
    
    @objc public func dismiss() {
        
        isShow = false
        
        UIView.animate(withDuration: 0.3, animations: {
            if self.direction == .left {
                self.frame.origin.x = self.minX
            } else {
                self.frame.origin.x = self.maxX
            }
            self.bgView.backgroundColor = UIColor.black.withAlphaComponent(0)
        }, completion: { (flag) in
            self.bgView.removeFromSuperview()
        })
    }
    
    @objc public func toggleShowState() {
        isShow ? dismiss() : show()
    }
    
    private func showBgView() {
        if bgView.superview == nil {
            superview?.insertSubview(bgView, belowSubview: self)
            bgView.backgroundColor = UIColor.black.withAlphaComponent(0)
        }
    }
    
    private func changeBgViewColor() {
        showBgView()
        bgView.backgroundColor = bgViewCurrentColor
    }
    
    override func removeFromSuperview() {
        superview?.removeGestureRecognizer(screenPan)
        screenPan = nil
        super.removeFromSuperview()
    }
    
}


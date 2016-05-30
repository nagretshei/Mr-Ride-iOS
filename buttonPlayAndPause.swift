//
//  buttonPlayAndPause.swift
//  
//
//  Created by Lin Yi-Cheng on 2016/5/30.
//
//

import Cocoa

class buttonPlayAndPause: UIButton {
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        UIColor.redColor().setFill()
        path.fill()
    }
}

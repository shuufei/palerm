//
//  CircleCustomButton.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/11/17.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import UIKit

enum CircleCustomButtonType {
    case Hour
    case Minute
    case Week
}

class CircleCustomButton: UIButton {
    var active = false
    var color: UIColor
    var type: CircleCustomButtonType = .Hour
    var label: String
    
    init(size: CGFloat, color: UIColor, label: String, type: CircleCustomButtonType = .Hour) {
        self.active = false
        self.color = color
        self.type = type
        self.label = label
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        
        self.layer.cornerRadius = size / 2
        self.backgroundColor = color
        self.setTitle(label, for: .normal)
        self.setTitleColor(PalermColor.Dark50.UIColor, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.addTarget(self, action: #selector(self.toggle(_:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func toggle(_ sender: UIButton) {
        self.active = !self.active
        self.setOn(self.active)
        self.occureImpact(style: .light)
    }
    
    func setOn(_ on: Bool) {
        self.active = on
        if self.active {
            self.backgroundColor = PalermColor.Blue.UIColor
            self.setTitleColor(.white, for: .normal)
        } else {
            self.backgroundColor = color
            self.setTitleColor(PalermColor.Dark50.UIColor, for: .normal)
        }
    }
    
    func occureImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactGenerator = UIImpactFeedbackGenerator(style: style)
        impactGenerator.impactOccurred()
    }
}

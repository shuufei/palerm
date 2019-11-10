//
//  AlermCard.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/11/10.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import Foundation
import UIKit

struct AlermCardHead {
    let selfView: UIStackView
    var switcher: UISwitch? = nil
    
    mutating func setSwitcher(_ switcher: UISwitch) {
        self.switcher = switcher
    }
}

struct AlermCardTimeCellList {
    let selfView: UIStackView
    var height: CGFloat? = nil
    var heightConstraints: NSLayoutConstraint? = nil
    
    mutating func setHeight(_ height: CGFloat) {
        self.height = height
    }
    
    mutating func setHeightConstraints(_ constraints: NSLayoutConstraint) {
        self.heightConstraints = constraints
    }
}

struct AlermCardFoot {
    let selfView: UIStackView
    var pullIcon: UIImageView? = nil
    
    mutating func setPullIcon(_ pullIcon: UIImageView) {
        self.pullIcon = pullIcon
    }
}

class AlermCard {
    let selfView: UIStackView
    
    var head: AlermCardHead? = nil
    var alermTimeCellList: AlermCardTimeCellList? = nil
    var foot: AlermCardFoot? = nil
    var topAnchor: NSLayoutConstraint? = nil
    var topAnchorInitValue: CGFloat? = nil

    var isExpand: Bool = false
    
    init(view: UIStackView) {
        self.selfView = view
    }
    
    init(view: UIStackView, head: AlermCardHead?, alermTimeCellList: AlermCardTimeCellList?, foot: AlermCardFoot?, isExpand: Bool) {
        self.selfView = view
        self.head = head
        self.alermTimeCellList = alermTimeCellList
        self.foot = foot
        self.isExpand = isExpand
    }
    
    func setTopAnchor(_ topAnchor: NSLayoutConstraint) {
        self.topAnchor = topAnchor
        self.topAnchorInitValue = topAnchor.constant
    }
}

class AlermCardGenerator {
    func generate(time: String) -> AlermCard {
        let timeLabel = self.generateTimeLabelForSingleSetting(time: time)
        let switcher = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        switcher.sizeToFit()
        
        let labelAndSwitcherWrapper = UIStackView()
        let topPadding = CGFloat(12)
        let bottomPadding = CGFloat(12)
        let leadingPadding = CGFloat(16)
        let trailingPadding = CGFloat(16)

        labelAndSwitcherWrapper.translatesAutoresizingMaskIntoConstraints = false
        labelAndSwitcherWrapper.heightAnchor.constraint(equalToConstant: switcher.frame.height + topPadding + bottomPadding)
        labelAndSwitcherWrapper.axis = .horizontal
        labelAndSwitcherWrapper.distribution = .equalSpacing
        labelAndSwitcherWrapper.alignment = .center
        labelAndSwitcherWrapper.isLayoutMarginsRelativeArrangement = true
        labelAndSwitcherWrapper.directionalLayoutMargins = NSDirectionalEdgeInsets(top: topPadding, leading: leadingPadding, bottom: bottomPadding, trailing: trailingPadding)
        labelAndSwitcherWrapper.addBackground(PalermColor.Dark500.UIColor, 5, false, true)

        labelAndSwitcherWrapper.addArrangedSubview(timeLabel)
        labelAndSwitcherWrapper.addArrangedSubview(switcher)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.tapped(_:)))
        gesture.minimumPressDuration = 0

        labelAndSwitcherWrapper.addGestureRecognizer(gesture)
        
        let alermCardHead = AlermCardHead(selfView: labelAndSwitcherWrapper, switcher: switcher)
        
        return AlermCard(view: labelAndSwitcherWrapper, head: alermCardHead, alermTimeCellList: nil, foot: nil, isExpand: false)
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer) {
        print("--- tapped alerm card")
    }
    
    private func generateTimeLabelForSingleSetting(time: String) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.text = time
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }
}


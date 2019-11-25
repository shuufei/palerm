//
//  AlermCard.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/11/10.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa

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
    let alermStateList: [AlermState]
    
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

struct AlermState {
    let time: String
    let switcher: UISwitch
}

class AlermCard {
    let selfView: UIStackView
    
    var uuid: String = NSUUID().uuidString
    var head: AlermCardHead? = nil
    var alermTimeCellList: AlermCardTimeCellList? = nil
    var foot: AlermCardFoot? = nil
    var topAnchor: NSLayoutConstraint? = nil
    var topAnchorInitValue: CGFloat? = nil
    var alermTimes: [AlermTime] = []

    var isExpand: Bool = false
    
    init(view: UIStackView) {
        self.selfView = view
    }
    
    init(view: UIStackView, uuid: String, head: AlermCardHead?, alermTimeCellList: AlermCardTimeCellList?, foot: AlermCardFoot?, isExpand: Bool) {
        self.selfView = view
        
        self.uuid = uuid
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

protocol AlermCardDelegate {
    func tapped(_ sender: UILongPressGestureRecognizer)
    func tappedExpandTrigger(_ sender: UITapGestureRecognizer)
    func switchedAlermEnableOfCell(_ sender: UISwitch)
}

class AlermCardGenerator {
    let TIME_LABEL_MAX_COUNT_IN_ROW: Int = 4
    let TIME_LABEL_SPACE: Int = 6
    
    var delegate: AlermCardDelegate?

    func generate(time: String, uuid: String, isEnable: Bool) -> AlermCard {
        let alermCardHead = self.generateAlermCardHead(time: time, isEnable: isEnable)
        return AlermCard(view: alermCardHead.selfView, uuid: uuid, head: alermCardHead, alermTimeCellList: nil, foot: nil, isExpand: false)
    }
    
    func generate(alermTime: AlermTime, uuid: String, isEnable: Bool) -> AlermCard {
        let time = alermTime.time
        let alermCard = self.generate(time: time, uuid: uuid, isEnable: isEnable)
        alermCard.alermTimes = [alermTime]
        return alermCard
    }

    func generate(times: [String], uuid: String, enableTimes: [String]) -> AlermCard {
        let alermCardHead = self.generateAlermCardHead(times: times, enableTimes: enableTimes)
        let alermTimeCellList = self.generateAlermCardExpandView(times: times, width: alermCardHead.selfView.frame.width, enableTimes: enableTimes)
        let alermCardFoot = self.generateAlermCardExpandViewTrigger(width: alermCardHead.selfView.frame.width)
        
        let alermCard = UIStackView()
        alermCard.translatesAutoresizingMaskIntoConstraints = false
//        alermCard.heightAnchor.constraint(equalToConstant: alermCardHead.selfView.frame.height + alermCardFoot.selfView.frame.height).isActive = true
        alermCard.axis = .vertical
        alermCard.distribution = .fill
        alermCard.alignment = .fill
        alermCard.clipsToBounds = false
        alermCard.addArrangedSubview(alermCardHead.selfView)
        alermCard.addArrangedSubview(alermTimeCellList.selfView)
        alermCard.addArrangedSubview(alermCardFoot.selfView)
        alermCard.addBackground(PalermColor.Dark500.UIColor, 5, false, true)
        
        return AlermCard(
            view: alermCard,
            uuid: uuid,
            head: alermCardHead,
            alermTimeCellList: alermTimeCellList,
            foot: alermCardFoot,
            isExpand: false
        )
    }
    
    func generate(alermTimes: [AlermTime], uuid: String, enableTimes: [String]) -> AlermCard {
        var times: [String] = []
        for alermTime in alermTimes {
            times.append(alermTime.time)
        }
        let alermCard = self.generate(times: times, uuid: uuid, enableTimes: enableTimes)
        alermCard.alermTimes = alermTimes
        return alermCard
    }
}

// 時間が一つだけ設定されているAlermCard生成処理
extension AlermCardGenerator {
    private func generateAlermCardHead(time: String, isEnable: Bool = false) -> AlermCardHead {
        let timeLabel = self.generateTimeLabelForSingleSetting(time: time)
        let switcher = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        switcher.sizeToFit()
        switcher.setOn(isEnable, animated: false)
        
        let labelAndSwitcherWrapper = UIStackView()
        let topPadding = CGFloat(12)
        let bottomPadding = CGFloat(12)
        let leadingPadding = CGFloat(16)
        let trailingPadding = CGFloat(16)
        
        labelAndSwitcherWrapper.translatesAutoresizingMaskIntoConstraints = false
        let heightAnchor = labelAndSwitcherWrapper.heightAnchor.constraint(equalToConstant: switcher.frame.height + topPadding + bottomPadding)
        heightAnchor.isActive = true
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
        
        return alermCardHead
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

// 時間が複数設定されているAlermCard生成処理
extension AlermCardGenerator {
    // 時間ラベルのStackViewとSwitcherのStackを生成
    private func generateAlermCardHead(times: [String], enableTimes: [String]) -> AlermCardHead {
        let timeLabelStacksView = self.generateTimeLabelsList(times: times)
        let switcher = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        switcher.sizeToFit()
        let isEnable = enableTimes.count > 0
        switcher.setOn(isEnable, animated: false)
        
        let labelsAndSwitcherWrapper = UIStackView()
        let headPaddingTop: CGFloat = 12
        let headPaddingBottom: CGFloat = 12
        let labelsAndSwitcherWrapperHeight = timeLabelStacksView.frame.height < switcher.frame.height ? switcher.frame.height : timeLabelStacksView.frame.height
        labelsAndSwitcherWrapper.translatesAutoresizingMaskIntoConstraints = false
        labelsAndSwitcherWrapper.heightAnchor.constraint(equalToConstant: labelsAndSwitcherWrapperHeight + headPaddingTop + headPaddingBottom).isActive = true
        labelsAndSwitcherWrapper.axis = .horizontal
        labelsAndSwitcherWrapper.distribution = .equalSpacing
        labelsAndSwitcherWrapper.alignment = .top
        labelsAndSwitcherWrapper.isLayoutMarginsRelativeArrangement = true
        labelsAndSwitcherWrapper.directionalLayoutMargins = NSDirectionalEdgeInsets(top: headPaddingTop, leading: 16, bottom: headPaddingBottom, trailing: 16)
        labelsAndSwitcherWrapper.addBackground(PalermColor.Dark500.UIColor, 5, true)
        labelsAndSwitcherWrapper.addArrangedSubview(timeLabelStacksView)
        labelsAndSwitcherWrapper.addArrangedSubview(switcher)
        let gesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(self.tapped(_:))
        )
        gesture.minimumPressDuration = 0
        labelsAndSwitcherWrapper.addGestureRecognizer(gesture)
        let alermCardHead = AlermCardHead(selfView: labelsAndSwitcherWrapper, switcher: switcher)
        return alermCardHead
    }
    
    // 拡縮可能な領域を生成。時間ごとにアラームのON／OFFを指定できるViewが含まれる。
    private func generateAlermCardExpandView(times: [String], width: CGFloat, enableTimes: [String]) -> AlermCardTimeCellList {
        var cells: [UIStackView] = []
        var cellHeight: CGFloat = 0
        var alermStateList: [AlermState] = []
        
        for time in times {
            let isEnable = enableTimes.first(where: { $0 == time }) != nil ? true : false
            let (cell, alermState) = self.generateTimeCell(time: time, width: width, isEnable: isEnable)
            cells.append(cell)
            cellHeight += cell.frame.height
            alermStateList.append(alermState)
        }
        
        let timeCellsWrapper = UIStackView(frame: CGRect(x: 0, y: 0, width: 0, height: cellHeight))
        timeCellsWrapper.axis = .vertical
        timeCellsWrapper.distribution = .fillEqually
        timeCellsWrapper.alpha = 0
        
        for cell in cells {
            timeCellsWrapper.addArrangedSubview(cell)
        }
        
        let timeCellsWrapperHeightConstraints = timeCellsWrapper.heightAnchor.constraint(equalToConstant: 0)
        timeCellsWrapperHeightConstraints.isActive = true
        
        return AlermCardTimeCellList(selfView: timeCellsWrapper, height: cellHeight, heightConstraints: timeCellsWrapperHeightConstraints, alermStateList: alermStateList)
    }

    // 時間ごとにアラームのON／OFFを指定できるViewを生成
    private func generateTimeCell(time: String, width: CGFloat, isEnable: Bool) -> (cell: UIStackView, alermState: AlermState) {
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: width, height: 54))
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.heightAnchor.constraint(lessThanOrEqualToConstant: 54).isActive = true
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.addBackground(PalermColor.Dark400.UIColor)
        
        let timeLabel = UILabel()
        timeLabel.text = time
        timeLabel.font = UIFont.systemFont(ofSize: 18)
        timeLabel.textColor = .white
        timeLabel.sizeToFit()
        timeLabel.textAlignment = .left
        
        let switcher = UISwitch()
        switcher.sizeToFit()
        switcher.setOn(isEnable, animated: false)
        switcher.addTarget(self, action: #selector(self.switchedAlermEnableOfCell(_:)), for: .valueChanged)

        stackView.addArrangedSubview(timeLabel)
        stackView.addArrangedSubview(switcher)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.heightAnchor.constraint(lessThanOrEqualToConstant: 0.5).isActive = true
        border.backgroundColor = PalermColor.Dark100.UIColor
        
        let cell = UIStackView(frame: CGRect(x: 0, y: 0, width: 0, height: 54.5))
        cell.translatesAutoresizingMaskIntoConstraints = false
        cell.heightAnchor.constraint(lessThanOrEqualToConstant: 54.5).isActive = true
        cell.axis = .vertical
        cell.distribution = .fill
        cell.addArrangedSubview(border)
        cell.addArrangedSubview(stackView)
        
        return (cell: cell, alermState: AlermState(time: time, switcher: switcher))
    }

    // 拡縮を制御するためのViewを生成
    private func generateAlermCardExpandViewTrigger(width: CGFloat) -> AlermCardFoot {
        let borderHeight: CGFloat = 0.5
        let triggerViewHeight: CGFloat = 30
        
        let triggerView = UIView()
        triggerView.backgroundColor = PalermColor.Dark500.UIColor
        triggerView.layer.cornerRadius = 5
        triggerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMaxYCorner]
        
        triggerView.translatesAutoresizingMaskIntoConstraints = false
        triggerView.heightAnchor.constraint(equalToConstant: triggerViewHeight).isActive = true
        
        let pullIcon = UIImage(named: "pull")
        let pullIconView = UIImageView(image: pullIcon)
        pullIconView.frame = CGRect(x: 0, y: 0, width: 23, height: 9)
        pullIconView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        triggerView.addSubview(pullIconView)
        
        let border = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: borderHeight))
        border.backgroundColor = PalermColor.Dark100.UIColor
        
        let triggerViewWrapper = UIStackView()
        triggerViewWrapper.axis = .vertical
        triggerViewWrapper.distribution = .fill
        triggerViewWrapper.translatesAutoresizingMaskIntoConstraints = false
        triggerViewWrapper.heightAnchor.constraint(equalToConstant: triggerViewHeight + borderHeight).isActive = true
        triggerViewWrapper.addArrangedSubview(border)
        triggerViewWrapper.addArrangedSubview(triggerView)
        
        triggerViewWrapper.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(self.tappedExpandTrigger(_:))
        ))
        
        return AlermCardFoot(selfView: triggerViewWrapper, pullIcon: pullIconView)
    }
    
    // 時間ラベルのStackリストを生成
    private func generateTimeLabelsList(times: [String]) -> UIStackView {
        var timeLabelStacks: [UIStackView] = []
        var timeLabelStacksHeight: CGFloat = 0
        var timeLabelStacksWidth: CGFloat = 0
        let timeLabelStackCount = Int(ceil(Double(times.count) / Double(TIME_LABEL_MAX_COUNT_IN_ROW)))
        for i in 0..<timeLabelStackCount {
            let offset = i*TIME_LABEL_MAX_COUNT_IN_ROW
            let tmpTimes = times.dropFirst(offset).prefix(TIME_LABEL_MAX_COUNT_IN_ROW)
            let stackView = self.generateTimeLabelStack(times: tmpTimes.map{$0})
            timeLabelStacks.append(stackView)
            timeLabelStacksHeight += stackView.frame.height
            if timeLabelStacksWidth < stackView.frame.width {
                timeLabelStacksWidth = stackView.frame.width
            }
        }
        let timeLabelStacksViewHeight = timeLabelStacksHeight+(CGFloat(timeLabelStacks.count-1)*CGFloat(TIME_LABEL_SPACE))
        let timeLabelStacksView = UIStackView(frame: CGRect(x: 0, y: 200, width: timeLabelStacksWidth, height: timeLabelStacksViewHeight))
        timeLabelStacksView.axis = .vertical
        timeLabelStacksView.distribution = .fillEqually
        timeLabelStacksView.spacing = CGFloat(TIME_LABEL_SPACE)
        timeLabelStacksView.alignment = .leading
        for stack in timeLabelStacks {
            timeLabelStacksView.addArrangedSubview(stack)
        }
        return timeLabelStacksView
    }
    
    // 時間ラベルの1行分のStackViewを生成
    private func generateTimeLabelStack(times: [String]) -> UIStackView {
        let rect = CGRect(x: 0, y: 0, width: 0, height: 0)
        let stackView = UIStackView(frame: rect)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = CGFloat(TIME_LABEL_SPACE)
        var timeLabelsWidth: CGFloat = 0
        var timeHeight: CGFloat = 0
        times.forEach { time in
            let timeLabel = self.generateTimeLabel(time: time)
            timeLabelsWidth += timeLabel.frame.width
            timeHeight = timeLabel.frame.height
            stackView.addArrangedSubview(timeLabel)
        }
        let stackViewWidth = timeLabelsWidth+(CGFloat(TIME_LABEL_SPACE)*CGFloat(times.count-1))
        stackView.frame.size = CGSize(width: stackViewWidth, height: timeHeight)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalToConstant: stackViewWidth).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: timeHeight).isActive = true
        return stackView
    }
    
    // 時間ラベルを生成
    private func generateTimeLabel(time: String) -> UIView {
        let label = TimeLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        label.backgroundColor = PalermColor.Dark200.UIColor
        label.text = time
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.sizeToFit()
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        return label
    }
}

// タッチイベント処理
extension AlermCardGenerator {
    @objc func tapped(_ sender: UILongPressGestureRecognizer) {
        guard let delegate = self.delegate else { return }
        delegate.tapped(sender)
    }
    
    @objc func tappedExpandTrigger(_ sender: UITapGestureRecognizer) {
        guard let delegate = self.delegate else { return }
        delegate.tappedExpandTrigger(sender)
    }
    
    @objc func switchedAlermEnableOfCell(_ sender: UISwitch) {
        guard let delegate = self.delegate else { return }
        delegate.switchedAlermEnableOfCell(sender)
    }
}


class TimeLabel: UILabel {
    
    @IBInspectable var padding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    
    override func drawText(in rect: CGRect) {
        rect.inset(by: padding)
        super.drawText(in: rect)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        return contentSize
    }
}

//
//  AlermSettingViewController.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/11/17.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import UIKit

struct AlermTime: Codable {
    let hour: String
    let min: String
    
    init(hour: String, min: String) {
        self.hour = hour
        self.min = min
    }
    
    init(time: String) {
        let timeArr = time.components(separatedBy: ":")
        self.hour = timeArr[0] 
        self.min = timeArr[1]
    }
    
    var time: String {
        get {
            return "\(self.hour):\(self.min)"
        }
    }
    
    var priority: Int {
        get {
            return Int("\(self.hour)\(self.min)")!
        }
    }
}

class AlermSettingViewController: UIViewController {
    public let uuid: String
    public var alermTimeList: [AlermTime]
    public var weekList: [String] = []
    
    private var navBar: UINavigationBar
    private var scrollView: UIScrollView
    private var hoursView: UIScrollView
    private var minutesView: UIView
    private var labelsView: UIStackView
    private var labelsViewHeightConstraint: NSLayoutConstraint
    private var loopView: UIScrollView

    private var hourButtonList: [CircleCustomButton] = []
    private var minutesButtonList: [CircleCustomButton] = []
    private var weekButtonList: [CircleCustomButton] = []
    
    private var scrollViewContentsHeight: CGFloat = 0
    private var currentHour: String = "00"
    private var selectingHour: String? = nil
    private var alermTimeLabelStackList: [UIStackView] = []
    
    private let alermListModel: AlermListModel = .shared
    
    init(uuid: String?, alermTimeList: [AlermTime]) {
        self.uuid = uuid ?? NSUUID().uuidString
        self.alermTimeList = alermTimeList

        self.navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 0, height: 56))
        self.scrollView = UIScrollView()
        self.hoursView = UIScrollView()
        self.minutesView = UIView()
        self.labelsView = UIStackView()
        self.labelsViewHeightConstraint = NSLayoutConstraint()
        self.loopView = UIScrollView()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    private func setup() {
        self.view.backgroundColor = PalermColor.Dark500.UIColor
        self.setNavBar()
        self.setScrollView()
        self.setHoursView()
        self.setMinutesView()
        self.setLabelsView()
        self.setAlermTimeLabels(isInit: true)
        self.setLoopView()
        self.setSettingCells()

        self.scrollViewContentsHeight += 48
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.scrollViewContentsHeight)
    }
    
    private func setNavBar() {
        if let navigationBar = self.navigationController?.navigationBar {
            self.navBar = navigationBar
        }
        self.navBar.barStyle = .default
        self.navBar.barTintColor = PalermColor.Dark500.UIColor
        self.navBar.isTranslucent = false

        let doneItem = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(self.done(_:)))
        doneItem.tintColor = .white
        let cancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(self.cancel(_:)))
        cancelItem.action = #selector(self.cancel(_:))
        cancelItem.tintColor = .white
        self.navigationItem.rightBarButtonItem = doneItem
        self.navigationItem.leftBarButtonItem = cancelItem
    }
    
    private func setScrollView() {
        self.view.addSubview(self.scrollView)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.scrollView.showsVerticalScrollIndicator = false
    }
    
    private func generateViewCategoryLabel(category: String) -> UILabel {
        let label = UILabel()
        label.text = category
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = PalermColor.Dark50.UIColor
        label.sizeToFit()
        return label
    }

    private func appendAlermTime(alermTime: AlermTime) -> Bool {
        self.alermTimeList.append(alermTime)
        self.alermTimeList.sort { $0.priority < $1.priority }
        return true
    }

    private func removeAlermTime(hour: String, min: String) -> Bool {
        for (index, alermTime) in self.alermTimeList.enumerated() {
            if alermTime.hour == hour, alermTime.min == min {
                self.alermTimeList.remove(at: index)
                return true
            }
        }
        return false
    }
    
    private func turnOnMinuteButtons() {
        for minButton in self.minutesButtonList {
            guard let label = minButton.titleLabel?.text else { continue }
            var isOn = false
            for alermTime in self.alermTimeList {
                if self.selectingHour == alermTime.hour, alermTime.min == label {
                    isOn = true
                }
            }
            minButton.setOn(isOn)
        }
    }
    
    private func deleteAlerm() {
        self.alermListModel.deleteAlerm(uuid: self.uuid, isCommit: true)
        self.cancel(nil)
    }

}

// 時間選択Viewの表示処理
extension AlermSettingViewController {
    private func setHoursView() {
        self.setSelectingHour()
        
        let hoursViewTopMargin: CGFloat = 12
        let stackSpacing: CGFloat = 6
        let hourButtonSize: CGFloat = 48
        let sidePadding: CGFloat = 12

        let label = self.setAndGetHourTitle()

        self.hoursView.contentOffset = CGPoint(x: 0, y: 0)
        self.hoursView.showsHorizontalScrollIndicator = false
        self.scrollView.addSubview(self.hoursView)
        self.setHourViewsConstraints(topAnchorTarget: label.bottomAnchor, topMargin: hoursViewTopMargin)
        
        let hourStack = self.generateHourStack(buttonSize: hourButtonSize, stackSpacing: stackSpacing, sidePadding: sidePadding)
        self.hoursView.contentSize = CGSize(
            width: hourStack.frame.width + (sidePadding * CGFloat(2)),
            height: hourButtonSize
        )
        self.hoursView.addSubview(hourStack)
        self.view.layoutIfNeeded()
        self.scrollViewContentsHeight += self.hoursView.frame.height + hoursViewTopMargin
    }
    
    private func setAndGetHourTitle() -> UILabel {
        let label = self.generateViewCategoryLabel(category: "時")
        self.scrollView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        let topMargin: CGFloat = 24
        label.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: topMargin).isActive = true
        label.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        self.scrollViewContentsHeight += topMargin + label.frame.height
        return label
    }
    
    private func setHourViewsConstraints(topAnchorTarget: NSLayoutYAxisAnchor, topMargin: CGFloat) {
        self.hoursView.translatesAutoresizingMaskIntoConstraints = false
        self.hoursView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        self.hoursView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.hoursView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.hoursView.topAnchor.constraint(equalTo: topAnchorTarget, constant: topMargin).isActive = true
    }
    
    private func generateHourButtonList(buttonSize: CGFloat) -> [CircleCustomButton] {
        var hourButtonList: [CircleCustomButton] = []
        for hour in 0...23 {
            let label = String(format: "%02d", hour)
            let hourButton = CircleCustomButton(size: buttonSize, color: PalermColor.Dark100.UIColor, label: label, type: .Hour)
            if label == self.selectingHour {
                hourButton.setOn(true)
            }
            hourButton.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(self.tappedHourButton(_:)))
            )
            hourButtonList.append(hourButton)
        }
        return hourButtonList
    }
    
    private func setSelectingHour() {
        if self.alermTimeList.count >= 1 {
            let alermTime = self.alermTimeList[0]
            self.selectingHour = alermTime.hour
        } else {
            let format = DateFormatter()
            format.dateFormat = DateFormatter.dateFormat(fromTemplate: "H", options: 0, locale: .current)
            self.selectingHour = format.string(from: Date())
        }
    }
    
    private func setHourOffset(buttonSize: CGFloat, buttonSpacing: CGFloat, sidePadding: CGFloat) {
        for (index, button) in self.hourButtonList.enumerated() {
            if !button.active { continue }
            let scrollOffsetX = (
                ((buttonSize + buttonSpacing) * CGFloat(index))
                - self.view.center.x
                + (buttonSize / CGFloat(2))
                + sidePadding
            )
            self.hoursView.setContentOffset(CGPoint(x: scrollOffsetX, y: 0), animated: true)
            return
        }
    }
    
    private func generateHourStack(buttonSize: CGFloat, stackSpacing: CGFloat, sidePadding: CGFloat) -> UIStackView {
        let hourStack = UIStackView()
        hourStack.axis = .horizontal
        hourStack.addBackground(PalermColor.Dark500.UIColor)
        hourStack.distribution = .fillEqually
        hourStack.spacing = stackSpacing
        
        self.hourButtonList = self.generateHourButtonList(buttonSize: buttonSize)
        self.setHourOffset(buttonSize: buttonSize, buttonSpacing: stackSpacing, sidePadding: sidePadding)
        
        for button in self.hourButtonList {
            hourStack.addArrangedSubview(button)
        }

        let hourStackWidth = (
            CGFloat(self.hourButtonList.count) * buttonSize
            + CGFloat(self.hourButtonList.count - 1) * stackSpacing
        )
        hourStack.frame = CGRect(x: sidePadding, y: 0, width: hourStackWidth, height: buttonSize)
        
        return hourStack
    }

}

// 分選択Viewの表示処理
extension AlermSettingViewController {
    private func setMinutesView() {
        self.setMinutesTitle()

        let blockSize: CGFloat = 337
        let holeSize: CGFloat = 197
        self.minutesView = self.setAndGetMinutesBlock(blockSize: blockSize, holeSize: holeSize)
        
        let blockSizeHalf = blockSize / CGFloat(2)
        let holeSizeHalf = holeSize / CGFloat(2)
        
        let r: CGFloat = (
            ((blockSizeHalf - holeSizeHalf) / CGFloat(2))
            + holeSizeHalf
        )
        // 中心からの座標
        let points: [CGPoint] = [
            CGPoint(x: 0, y: -r),
            CGPoint(x: r/2, y: -CGFloat(sqrt(3)/2)*r),
            CGPoint(x: CGFloat(sqrt(3)/2)*r, y: -r/2),
            CGPoint(x: r, y: 0),
            CGPoint(x: CGFloat(sqrt(3)/2)*r, y: r/2),
            CGPoint(x: r/2, y: CGFloat(sqrt(3)/2)*r),
            CGPoint(x: 0, y: r),
            CGPoint(x: -r/2, y: CGFloat(sqrt(3)/2)*r),
            CGPoint(x: -CGFloat(sqrt(3)/2)*r, y: r/2),
            CGPoint(x: -r, y: 0),
            CGPoint(x: -CGFloat(sqrt(3)/2)*r, y: -r/2),
            CGPoint(x: -r/2, y: -CGFloat(sqrt(3)/2)*r)
        ]
        
        for (index, point) in points.enumerated() {
            let minuteButton = CircleCustomButton(
                size: 50,
                color: PalermColor.Dark500.UIColor,
                label: String(format: "%02d", index * 5),
                type: .Minute
            )
            self.minutesButtonList.append(minuteButton)
            let cPoint = self.minutesView.convert(point, from: self.scrollView)
            minuteButton.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(self.tappedMinuteButton(_:)))
            )
            minuteButton.center = cPoint
            self.minutesView.addSubview(minuteButton)
        }
        self.scrollViewContentsHeight += self.minutesView.frame.height + 32
        self.turnOnMinuteButtons()
    }
    
    private func setMinutesTitle() {
        let label = self.generateViewCategoryLabel(category: "分")
        self.scrollView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: self.hoursView.bottomAnchor, constant: 32).isActive = true
        label.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
    }
    
    private func setAndGetMinutesBlock(blockSize: CGFloat, holeSize: CGFloat) -> UIView {
        let minutesSelectBlock = UIView()
        minutesSelectBlock.translatesAutoresizingMaskIntoConstraints = false
        minutesSelectBlock.widthAnchor.constraint(equalToConstant: blockSize).isActive = true
        minutesSelectBlock.heightAnchor.constraint(equalToConstant: blockSize).isActive = true
        minutesSelectBlock.backgroundColor = PalermColor.Dark100.UIColor
        minutesSelectBlock.layer.cornerRadius = CGFloat(blockSize / 2)
        self.scrollView.addSubview(minutesSelectBlock)
        minutesSelectBlock.topAnchor.constraint(equalTo: self.hoursView.bottomAnchor, constant: 32).isActive = true
        minutesSelectBlock.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        let minutesSelectBlockHole = UIView()
        minutesSelectBlockHole.translatesAutoresizingMaskIntoConstraints = false
        minutesSelectBlockHole.widthAnchor.constraint(equalToConstant: holeSize).isActive = true
        minutesSelectBlockHole.heightAnchor.constraint(equalToConstant: holeSize).isActive = true
        minutesSelectBlockHole.backgroundColor = PalermColor.Dark500.UIColor
        minutesSelectBlockHole.layer.cornerRadius = CGFloat(holeSize / 2)
        minutesSelectBlock.addSubview(minutesSelectBlockHole)
        minutesSelectBlockHole.centerXAnchor.constraint(equalTo: minutesSelectBlock.centerXAnchor).isActive = true
        minutesSelectBlockHole.centerYAnchor.constraint(equalTo: minutesSelectBlock.centerYAnchor).isActive = true
        minutesSelectBlock.layoutIfNeeded()
        
        return minutesSelectBlock
    }
}

// 設定されている時間のラベルViewの表示処理
extension AlermSettingViewController {
    private func setLabelsView() {
        self.labelsView.axis = .vertical
        self.labelsView.distribution = .fillEqually
        self.labelsView.alignment = .leading
        self.labelsView.spacing = 8
        
        self.scrollView.addSubview(self.labelsView)
        self.labelsView.translatesAutoresizingMaskIntoConstraints = false
        self.labelsView.topAnchor.constraint(equalTo: self.minutesView.bottomAnchor, constant: 16).isActive = true
        self.labelsView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 24).isActive = true
        self.labelsView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -24).isActive = true
        self.labelsViewHeightConstraint = self.labelsView.heightAnchor.constraint(equalToConstant: 0)
        self.labelsViewHeightConstraint.isActive = true
        
        self.scrollViewContentsHeight += self.labelsView.frame.height
    }
    
    private func setAlermTimeLabels(isInit: Bool = false) {
        for stack in self.alermTimeLabelStackList { stack.removeFromSuperview() }
        let maxLabelsInStackCount = 3
        let safeAreaWidth = self.view.frame.width - self.view.safeAreaInsets.left - self.view.safeAreaInsets.right
        let alermTimeLabelStackCount = Int(ceil(
            Double(self.alermTimeList.count) / Double(maxLabelsInStackCount)
        ))
        let alermTimeLabelHeight: CGFloat = 36
        let labelsViewHeight = (
            (alermTimeLabelHeight * CGFloat(alermTimeLabelStackCount))
            + (self.labelsView.spacing * CGFloat(alermTimeLabelStackCount - 1))
        )
        self.labelsViewHeightConstraint.constant = labelsViewHeight >= 0 ? labelsViewHeight : 0
        for i in 0..<alermTimeLabelStackCount {
            let offset = i * maxLabelsInStackCount
            let alermTimeListInStack = self.alermTimeList.dropFirst(offset).prefix(maxLabelsInStackCount)
            let sidePadding: CGFloat = 24
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.distribution = .equalSpacing
            stack.spacing = 8
            let alermTimeLabelWidth = (
                safeAreaWidth
                - CGFloat(sidePadding * 2)
                - CGFloat(stack.spacing * CGFloat(maxLabelsInStackCount - 1))
            ) / 3
            for (index, alermTime) in alermTimeListInStack.enumerated() {
                let labelText = UILabel(frame: CGRect(x: 12, y: 9, width: 0, height: 0))
                labelText.text = alermTime.time
                labelText.font = UIFont.systemFont(ofSize: 16)
                labelText.textColor = UIColor(hexString: "efefef")
                labelText.sizeToFit()
                
                let alermTimeLabel = UIView()
//                alermTimeLabel.backgroundColor = UIColor(hexString: "3f3f3f")
                alermTimeLabel.backgroundColor = PalermColor.Blue.UIColor
                alermTimeLabel.heightAnchor.constraint(equalToConstant: alermTimeLabelHeight).isActive = true
                alermTimeLabel.widthAnchor.constraint(equalToConstant: alermTimeLabelWidth).isActive = true
                
                let clearButton = self.generateAlermTimeLabelClearButton()
                clearButton.frame.origin = CGPoint(x: alermTimeLabelWidth - clearButton.frame.width, y: 0)
                clearButton.tag = offset + index
                
                alermTimeLabel.layer.cornerRadius = 18
                alermTimeLabel.addSubview(labelText)
                alermTimeLabel.addSubview(clearButton)
                
                stack.addArrangedSubview(alermTimeLabel)
            }
            self.labelsView.addArrangedSubview(stack)
            self.alermTimeLabelStackList.append(stack)
        }
        self.view.layoutIfNeeded()
        
        self.scrollView.contentSize = CGSize(
            width: self.view.frame.width,
            height: self.scrollViewContentsHeight + self.labelsView.frame.height
        )
        if isInit { // 初期化処理時の呼出の場合は、contents heightに高さを加える
            self.scrollViewContentsHeight += self.labelsView.frame.height
        }
    }
    
    private func generateAlermTimeLabelClearButton() -> UIView {
        let clearIcon = UIImage(named: "clear")
        let clearView = UIImageView(image: clearIcon)
        clearView.frame = CGRect(x: 12, y: 12, width: 12, height: 12)
        let clearWrapper = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        clearWrapper.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.clearAlermTime(_:))))
        clearWrapper.addSubview(clearView)
        return clearWrapper
    }
}

// くり返し選択Viewの表示処理
extension AlermSettingViewController {
    private func setLoopView() {
//        let label = self.setAndGetLoopTitle()
        self.loopView.contentOffset = CGPoint(x: 0, y: 0)
        self.loopView.showsHorizontalScrollIndicator = false
        
        self.scrollView.addSubview(self.loopView)
        self.loopView.translatesAutoresizingMaskIntoConstraints = false
//        self.loopView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        self.loopView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        self.loopView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.loopView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
//        self.loopView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 12).isActive = true
        self.loopView.topAnchor.constraint(equalTo: self.labelsView.bottomAnchor, constant: 0).isActive = true
        
        let loopStack = self.generateLoopStack()
//        self.loopView.contentSize = CGSize(width: loopStack.frame.width + 24, height: loopStack.frame.height)
        self.loopView.contentSize = CGSize(width: loopStack.frame.width + 24, height: 1)
//        self.loopView.addSubview(loopStack)
        self.view.layoutIfNeeded()
        self.scrollViewContentsHeight += self.loopView.frame.height + 12
    }
    
    private func setAndGetLoopTitle() -> UILabel {
        let verticalMargin: CGFloat = 16
        let label = self.generateViewCategoryLabel(category: "繰り返し")
        self.scrollView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: self.labelsView.bottomAnchor, constant: verticalMargin).isActive = true
        label.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        self.scrollViewContentsHeight += label.frame.height + (verticalMargin * 2)
        return label
    }
    
    private func generateLoopStack() -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.addBackground(PalermColor.Dark500.UIColor)
        stack.distribution = .fillEqually
        stack.spacing = 8

        let weekStrings = [
            "日", "月", "火", "水", "木", "金", "土"
        ]
        let weekButtonSize: CGFloat = 48
        for week in weekStrings {
            let button = CircleCustomButton(
                size: weekButtonSize,
                color: PalermColor.Dark100.UIColor,
                label: week,
                type: .Week
            )
            button.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(self.tappedWeekButton(_:)))
            )
            self.weekButtonList.append(button)
            stack.addArrangedSubview(button)
        }
        
        let stackWidth = (
            CGFloat(self.weekButtonList.count) * weekButtonSize
            + (CGFloat(self.weekButtonList.count - 1) * stack.spacing)
        )
        stack.frame = CGRect(x: 12, y: 0, width: stackWidth, height: weekButtonSize)
        return stack
    }
}

// その他設定Viewの表示処理
extension AlermSettingViewController {
    private func setSettingCells() {
        let borderHeight: CGFloat = 0.5
        
        let topBorder = self.generateSeparateBorder()
        self.setSettignCellConstraints(target: topBorder, topAnchorTarget: self.loopView.bottomAnchor, topMargin: 32, height: borderHeight)
        
        let soundSettingCell = self.generateSoundSettingCell()
        self.setSettignCellConstraints(target: soundSettingCell, topAnchorTarget: topBorder.bottomAnchor, topMargin: 0, height: 44)

//        let cellSeparateBorder = self.setAndGetCellSeparateBorder(topAnchorTarget: soundSettingCell.bottomAnchor, topMargin: 0, height: borderHeight)
//
//        let snoozeSettingCell = self.generateSnoozeSettingCell()
//        self.setSettignCellConstraints(target: snoozeSettingCell, topAnchorTarget: cellSeparateBorder.bottomAnchor, topMargin: 0, height: 48)
        
        let bottomBorder = self.generateSeparateBorder()
        self.setSettignCellConstraints(target: bottomBorder, topAnchorTarget: soundSettingCell.bottomAnchor, topMargin: 0, height: borderHeight)
//        self.setSettignCellConstraints(target: bottomBorder, topAnchorTarget: snoozeSettingCell.bottomAnchor, topMargin: 0, height: borderHeight)
        
        let deleteCellTopBorder = self.generateSeparateBorder()
        self.setSettignCellConstraints(target: deleteCellTopBorder, topAnchorTarget: bottomBorder.bottomAnchor, topMargin: 32, height: borderHeight)
        
        let deleteCell = self.generateDeleteCell()
        self.setSettignCellConstraints(target: deleteCell, topAnchorTarget: deleteCellTopBorder.bottomAnchor, topMargin: 0, height: 44)
        
        let deleteCellBottomBorder = self.generateSeparateBorder()
        self.setSettignCellConstraints(target: deleteCellBottomBorder, topAnchorTarget: deleteCell.bottomAnchor, topMargin: 0, height: borderHeight)
    }
    
    private func setSettignCellConstraints(target: UIView, topAnchorTarget: NSLayoutYAxisAnchor, topMargin: CGFloat, height: CGFloat) {
        self.scrollView.addSubview(target)
        target.translatesAutoresizingMaskIntoConstraints = false
        target.topAnchor.constraint(equalTo: topAnchorTarget, constant: topMargin).isActive = true
        target.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        target.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        let heightConstraint = target.heightAnchor.constraint(equalToConstant: height)
        heightConstraint.isActive = true
        // tableViewCellだとUIView-Encapsulated-Layout-Heightが優先されるので、それよりも優先度を上げる
        heightConstraint.priority = UILayoutPriority.init(rawValue: 999)
        self.scrollViewContentsHeight += height + topMargin
    }
    
    private func generateSeparateBorder() -> UIView {
        let border = UIView()
        border.backgroundColor = UIColor(hexString: "404040")
        return border
    }
    
    private func setAndGetCellSeparateBorder(topAnchorTarget: NSLayoutYAxisAnchor, topMargin: CGFloat, height: CGFloat) -> UIView {
        let border = self.generateSeparateBorder()
        border.backgroundColor = PalermColor.Dark300.UIColor
        self.setSettignCellConstraints(target: border, topAnchorTarget: topAnchorTarget, topMargin: topMargin, height: height)
        let innerBorder = self.generateSeparateBorder()
        border.addSubview(innerBorder)
        innerBorder.translatesAutoresizingMaskIntoConstraints = false
        innerBorder.topAnchor.constraint(equalTo: border.topAnchor).isActive = true
        innerBorder.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        innerBorder.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        innerBorder.heightAnchor.constraint(equalToConstant: height).isActive = true
        return border
    }
    
    private func generateSoundSettingCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "sound")
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = PalermColor.Dark300.UIColor
        cell.textLabel?.text = "サウンド"
        cell.textLabel?.textColor = UIColor(hexString: "efefef")
        cell.detailTextLabel?.text = "alerm"
        cell.detailTextLabel?.textColor = UIColor(hexString: "8E8E93")
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.navigateSoundSetting(_:))))
        return cell
    }
    
    private func generateSnoozeSettingCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "snooze")
        cell.backgroundColor = PalermColor.Dark300.UIColor
        cell.accessoryView = UISwitch()
        cell.selectionStyle = .none
        cell.textLabel?.text = "スヌーズ"
        cell.textLabel?.textColor = UIColor(hexString: "efefef")
        return cell
    }
    
    private func generateDeleteCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "delete")
        cell.backgroundColor = PalermColor.Dark300.UIColor
        cell.textLabel?.text = "アラームを削除"
        cell.textLabel?.textColor = .red
        cell.textLabel?.textAlignment = .center
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.confirmDeleteAlerm(_:))))
        return cell
    }
}

@objc
extension AlermSettingViewController {
    func cancel(_ sender: UIButton?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func done(_ sender: UIButton) {
        var alermTimes: [String] = []
        for time in self.alermTimeList {
            alermTimes.append(time.time)
        }
        let isNewAlerm = self.alermListModel.alerms.first(where: { $0.id == self.uuid }) != nil ? false : true
        if (isNewAlerm) {
            self.alermListModel.addAlerm(alerm: Alerm(times: alermTimes))
        } else {
            self.alermListModel.updateAlerm(alerm: Alerm(id: self.uuid, times: alermTimes))
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func tappedHourButton(_ sender: UITapGestureRecognizer) {
        guard let button = sender.view as? CircleCustomButton else { return }
        self.selectingHour = button.titleLabel?.text ?? ""
        for hourButton in self.hourButtonList {
            guard let label = hourButton.titleLabel?.text, label != self.selectingHour else {
                hourButton.setOn(true)
                hourButton.occureImpact(style: .light)
                continue
            }
            hourButton.setOn(false)
        }
        self.turnOnMinuteButtons()
    }
    
    private func tappedMinuteButton(_ sender: UITapGestureRecognizer) {
        guard let button = sender.view as? CircleCustomButton else { return }
        guard self.selectingHour != nil, let min = button.titleLabel?.text else { return }
        if button.active {
            let removed = self.removeAlermTime(hour: self.selectingHour!, min: min)
            if removed { button.toggle(button) }
        } else {
            let appended = self.appendAlermTime(alermTime: AlermTime(hour: self.selectingHour!, min: min))
            if appended { button.toggle(button) }
        }
        self.setAlermTimeLabels()
    }
    
    private func tappedWeekButton(_ sender: UITapGestureRecognizer) {
        guard let button = sender.view as? CircleCustomButton else { return }
        guard let tappedWeek = button.titleLabel?.text else { return }
        if button.active {
            for (index, week) in self.weekList.enumerated() {
                if week == tappedWeek {
                    self.weekList.remove(at: index)
                    break
                }
            }
        } else {
            self.weekList.append(tappedWeek)
        }
        button.toggle(button)
    }
    
    private func clearAlermTime(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        let target = self.alermTimeList[view.tag]
        let _ = self.removeAlermTime(hour: target.hour, min: target.min)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        self.turnOffMinButtonOfTappedClearLabel(hour: target.hour, min: target.min)
        self.setAlermTimeLabels()
    }
    
    private func turnOffMinButtonOfTappedClearLabel(hour: String, min: String) {
        guard hour == self.selectingHour else { return }
        for minButton in self.minutesButtonList {
            if minButton.label != min { continue }
            minButton.toggle(minButton)
            break
        }
    }
    
    private func navigateSoundSetting(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UITableViewCell else { return }
        view.setHighlighted(true, animated: false)
        let alermSoundSettingViewController = AlermSoundSettingViewController()
        self.navigationController?.pushViewController(alermSoundSettingViewController, animated: true)
        view.setHighlighted(false, animated: true)
    }
    
    private func confirmDeleteAlerm(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view as? UITableViewCell else { return }
        view.setHighlighted(true, animated: false)
        let alert = UIAlertController(title: "アラームを削除しますか？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(
            title: "キャンセル",
            style: .cancel,
            handler: {(action) -> Void in
                view.setHighlighted(false, animated: false)
            }
        ))
        alert.addAction(UIAlertAction(
            title: "削除",
            style: .destructive,
            handler: {(action) -> Void in
                view.setHighlighted(false, animated: false)
                self.deleteAlerm()
            }
        ))
        
        self.present(alert, animated: true, completion: nil)
    }
}

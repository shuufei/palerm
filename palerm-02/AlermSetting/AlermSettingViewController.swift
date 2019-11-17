//
//  AlermSettingViewController.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/11/17.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import UIKit

class AlermSettingViewController: UIViewController {
    var navBar: UINavigationBar
    var scrollView: UIScrollView
    var hoursView: UIScrollView
    var minutesView: UIView
    
    private var hourButtonList: [CircleCustomButton] = []
    private var minutesButtonList: [CircleCustomButton] = []
    
    private var scrollViewContentsHeight: CGFloat = 0
    private var currentHour: String = "00"
    
    init() {
        self.navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 0, height: 56))
        self.scrollView = UIScrollView()
        self.hoursView = UIScrollView()
        self.minutesView = UIView()
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
        self.setLoopView()
        
        self.scrollViewContentsHeight += 48
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.scrollViewContentsHeight)
    }
    
    private func setNavBar() {
        self.navBar.barStyle = .default
        self.navBar.barTintColor = PalermColor.Dark500.UIColor
        self.navBar.isTranslucent = false

        let navItem = UINavigationItem()
        let doneItem = UIBarButtonItem(title: "完了", style: .done, target: nil, action: nil)
        doneItem.tintColor = .white
        let cancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: nil, action: nil)
        cancelItem.action = #selector(self.cancel(_:))
        cancelItem.tintColor = .white
        navItem.rightBarButtonItem = doneItem
        navItem.leftBarButtonItem = cancelItem
        self.navBar.setItems([navItem], animated: false)
        
        self.view.addSubview(self.navBar)
        
        self.navBar.translatesAutoresizingMaskIntoConstraints = false
        self.navBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        self.navBar.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        self.navBar.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
    }
    
    private func setScrollView() {
        self.view.addSubview(self.scrollView)
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.topAnchor.constraint(equalTo: self.navBar.bottomAnchor).isActive = true
        self.scrollView.leadingAnchor.constraint(equalTo: self.navBar.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.navBar.trailingAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    private func setLabelsView() {
        
    }
    
    private func generateViewCategoryLabel(category: String) -> UILabel {
        let label = UILabel()
        label.text = category
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = PalermColor.Dark50.UIColor
        label.sizeToFit()
        return label
    }
}

// 時間選択Viewの表示処理
extension AlermSettingViewController {
    private func setHoursView() {
        self.setCurrentHour()
        
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
        label.topAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: topMargin).isActive = true
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
            if label == self.currentHour {
                hourButton.setOn(true)
            }
            hourButton.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(self.tappedHourButton(_:)))
            )
            hourButtonList.append(hourButton)
        }
        return hourButtonList
    }
    
    private func setCurrentHour() {
        let format = DateFormatter()
        format.dateFormat = DateFormatter.dateFormat(fromTemplate: "H", options: 0, locale: .current)
        self.currentHour = format.string(from: Date())
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

// くり返し選択Viewの表示処理
extension AlermSettingViewController {
    private func setLoopView() {
        
    }
    
    private func setAndGetLoopTitle() -> UILabel {
        let label = self.generateViewCategoryLabel(category: "繰り返し")
        self.scrollView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.topAnchor.constraint(equalTo: self., constant: )
        return label
    }
}

extension AlermSettingViewController {
    @objc func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func tappedHourButton(_ sender: UITapGestureRecognizer) {
        print("--- tapped hour button")
    }
    
    @objc private func tappedMinuteButton(_ sender: UITapGestureRecognizer) {
        print("--- tapped minutes button")
    }
}

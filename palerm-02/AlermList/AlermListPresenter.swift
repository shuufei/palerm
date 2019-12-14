//
//  AlermListPresenter.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/10/10.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import UserNotifications
import AVFoundation

protocol AlermListPresenterInput {
    func loadAlermList()
    var alermCardList: [AlermCard] { get }
}

protocol AlermListPresenterOutput: AnyObject {
    func resizeAlermCard(alermCard: AlermCard)
    func layoutIfNeededWithAnimation()
    func presentToSetting(viewController: UIViewController)
    func reload()
}

final class AlermListPresenter: AlermListPresenterInput {
    
    private weak var view: AlermListPresenterOutput!
    private let model: AlermListModelProtocol
    private let disposeBag = DisposeBag()
    private var _alermCardList: [AlermCard] = []
    
    public var alermCardList: [AlermCard] {
        get {
            return self._alermCardList
        }
    }
    
    public let alermCardGenerator = AlermCardGenerator()
    
    init(view: AlermListPresenterOutput, model: AlermListModelProtocol) {
        self.view = view
        self.model = model
        self.alermCardGenerator.delegate = self
        self.model.alerms$.bind { _ in
            let alerms = self.model.alerms
            print("--- changed alerms: ", alerms)
            self._alermCardList = []
            for (index, alerm) in alerms.enumerated() {
                var alermCard: AlermCard?
                if alerm.times.count == 1 {
                    let alermTime = AlermTime(time: alerm.times[0])
                    let isEnable = (alerm.enableTimes.count > 0 && alerm.enableTimes[0] == alerm.times[0])
                    alermCard = self.alermCardGenerator.generate(alermTime: alermTime, uuid: alerm.id, isEnable: isEnable)
                    alermCard!.head!.selfView.tag = index
                } else {
                    var alermTimeList: [AlermTime] = []
                    for time in alerm.times {
                        alermTimeList.append(AlermTime(time: time))
                    }
                    alermCard = self.alermCardGenerator.generate(alermTimes: alermTimeList, uuid: alerm.id, enableTimes: alerm.enableTimes)
                    alermCard!.foot!.selfView.tag = index
                    alermCard!.head!.selfView.tag = index
                }
                self._alermCardList.append(alermCard!)
            }
            self.view.reload()
        }
        .disposed(by: self.disposeBag)
//        self.sandboxNotification()
    }

    func loadAlermList() {
        model.loadAlermListFromLocalCache()
    }
    
    func updateEnableAlermTimes() {
        for alermCard in self.alermCardList {
            if (alermCard.alermTimes.count == 1) {
                guard let switcher = alermCard.head?.switcher else { continue }
                let times = alermCard.alermTimes.map({ $0.time })
                let enableTimes = switcher.isOn ? times : []
                let alerm = Alerm(id: alermCard.uuid, times: times, enableTimes: enableTimes)
                self.model.updateAlerm(alerm: alerm, isCommit: false)
            } else {
                guard let alermStateList = alermCard.alermTimeCellList?.alermStateList else { return }
                let times = alermCard.alermTimes.map({ $0.time })
                let enableTimes = alermStateList.filter({ $0.switcher.isOn }).map({ $0.time })
                let alerm = Alerm(id: alermCard.uuid, times: times, enableTimes: enableTimes)
                self.model.updateAlerm(alerm: alerm, isCommit: false)
            }
        }
    }
}

extension AlermListPresenter: AlermCardDelegate {
    func tapped(_ sender: UILongPressGestureRecognizer) {
        guard let alermCardIndex = sender.view?.tag else { return }
        guard
            let topAnchor = self.alermCardList[alermCardIndex].topAnchor,
            let topAnchorInitValue = self.alermCardList[alermCardIndex].topAnchorInitValue
        else { return }
        
        let switcher = self.alermCardList[alermCardIndex].head?.switcher ?? nil
        let beforeNavigateMoveHeight: CGFloat = 3
        
        var isTappedSwitcher = false
        if switcher != nil {
            let switcherSize = switcher!.frame.size
            let point = sender.location(in: switcher)
            isTappedSwitcher = (
                -10 <= point.x &&
                -10 <= point.y &&
                point.x <= switcherSize.width + 10 &&
                point.y <= switcherSize.height + 10
            )
        }

        switch sender.state {
        case .began:
            if isTappedSwitcher { return }
            topAnchor.constant += beforeNavigateMoveHeight
            self.view.layoutIfNeededWithAnimation()
            break
        case .ended:
            if isTappedSwitcher {
                self.switchAlerms(alermCard: self.alermCardList[alermCardIndex])
                topAnchor.constant = topAnchorInitValue
                self.view.layoutIfNeededWithAnimation()
                return
            }
            let uuid = self.alermCardList[alermCardIndex].uuid
            let alermTimes = self.alermCardList[alermCardIndex].alermTimes
            let alermSettingViewController = AlermSettingViewController(uuid: uuid, alermTimeList: alermTimes)

            self.view.presentToSetting(viewController: alermSettingViewController)
            topAnchor.constant = topAnchorInitValue
            self.view.layoutIfNeededWithAnimation()
            break
        default:
            return
        }
    }
    
    func tappedExpandTrigger(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        self.view.resizeAlermCard(alermCard: self.alermCardList[index])
    }
    
    func switchAlerms(alermCard: AlermCard) {
        guard let switcher = alermCard.head?.switcher else { return }
        let newState = !switcher.isOn
        switcher.setOn(newState, animated: true)
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.impactOccurred()
        if let alermStateList = alermCard.alermTimeCellList?.alermStateList {
            for alermState in alermStateList {
                alermState.switcher.setOn(newState, animated: true)
            }
        }
        self.updateEnableAlermTimes()
    }
    
    func switchedAlermEnableOfCell(_ sender: UISwitch) {
        self.updateEnableAlermTimes()
    }
}

extension AlermListPresenter {
    func sandboxNotification() {
        self.mvAlarmSound2Sounds()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound, .alert, .criticalAlert]) { (granted, error) in
            if error != nil { return }
            if granted {
                print("--- notification ok")
//                self.setNotification(hour: 23, minute: 55)
                self.setNotification(hour: 00, minute: 33)
            } else {
                print("--- notification ng")
            }
            
        }
    }
    
    func setNotification(hour: Int, minute: Int, second: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = "Calender Alerm"
        content.subtitle = "Subtitle"
        content.body = "Body"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "alerm-29sec.m4a"))
        
        let idenfier = UUID().uuidString
        
        for i in 0..<1 {
            var dateCommponents = DateComponents()
            dateCommponents.hour = hour
            dateCommponents.minute = minute
            dateCommponents.second = second + (i*5)
            let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: dateCommponents, repeats: false)
            let calenderRequest = UNNotificationRequest(identifier: "\(idenfier)-\(i)", content: content, trigger: calendarTrigger)
            UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
            UNUserNotificationCenter.current().add(calenderRequest, withCompletionHandler: nil)
        }

    }
    
    func mvAlarmSound2Sounds() {
        do {
            let libraryUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            let soundDirUrl = libraryUrl.appendingPathComponent("Sounds")
            try? FileManager.default.createDirectory(at: soundDirUrl, withIntermediateDirectories: true, attributes: nil)
            
            let path = Bundle.main.path(forResource: "alerm-28sec", ofType: "m4a")!
            let from = URL(fileURLWithPath: path)
            let dest = soundDirUrl.appendingPathComponent("alerm-29sec.m4a")
            let isExist = FileManager.default.fileExists(atPath: dest.relativePath)
            if !isExist {
                try FileManager.default.copyItem(at: from, to: dest)
            }
            print("--- success mv alarm sound")
        } catch let error {
            print("--- mv alarm sound failed: ", error)
        }
    }
}

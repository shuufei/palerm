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

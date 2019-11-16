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
        self.model.alerms.bind { alerms in
            print("--- changed alerms: ", alerms)
            for (index, times) in alerms.enumerated() {
                var alermCard: AlermCard?
                if times.count == 1 {
                    alermCard = self.alermCardGenerator.generate(time: times[0])
                } else {
                    alermCard = self.alermCardGenerator.generate(times: times)
                    alermCard!.foot!.selfView.tag = index
                }
                self._alermCardList.append(alermCard!)
            }
        }
        .disposed(by: self.disposeBag)
    }

    func loadAlermList() {
        model.loadAlermListFromLocalCache()
    }
}

extension AlermListPresenter: AlermCardDelegate {
    func tapped(_ sender: UILongPressGestureRecognizer) {
        print("--- tapped in alerm list presenter")
    }
    
    func tappedExpandTrigger(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        self.view.resizeAlermCard(alermCard: self.alermCardList[index]) 
    }
}

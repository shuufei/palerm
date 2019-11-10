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

protocol AlermListPresenterProtocol {
    func loadAlermList()
    var alermCardList: [AlermCard] { get }
}

final class AlermListPresenter: AlermListPresenterProtocol {
    
    private let model: AlermListModelProtocol
    private let disposeBag = DisposeBag()
    private var _alermCardList: [AlermCard] = []
    
    public var alermCardList: [AlermCard] {
        get {
            return self._alermCardList
        }
    }
    
    private let alermCardGenerator = AlermCardGenerator()
    
    init(model: AlermListModelProtocol) {
        self.model = model
        self.model.alerms.bind { alerms in
            print("--- changed alerms: ", alerms)
            for (_, times) in alerms.enumerated() {
                let alermCard: AlermCard = self.alermCardGenerator.generate(time: times[0])
                self._alermCardList.append(alermCard)
            }
        }
        .disposed(by: self.disposeBag)
    }

    func loadAlermList() {
        model.loadAlermListFromLocalCache()
    }
}

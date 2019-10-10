//
//  AlermListPresenter.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/10/10.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import UIKit

protocol AlermListPresenterProtocol {
    func loadAlermList()
}

final class AlermListPresenter: AlermListPresenterProtocol {
    
    private let model: AlermListModelProtocol
    
    init(model: AlermListModelProtocol) {
        self.model = model
    }

    func loadAlermList() {
        model.loadAlermListFromLocalCache()
    }
}

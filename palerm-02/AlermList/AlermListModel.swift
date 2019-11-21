//
//  AlermListModel.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/10/10.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol AlermListModelProtocol {
    func loadAlermListFromLocalCache()
    func addAlerm(alerm: [String])
    var alerms: BehaviorRelay<[[String]]> { get }
}

let alermTestData = Alerms(values: [
    ["08:00", "08:05", "08:10", "08:15", "08:20", "08:25", "08:30"],
    ["09:30"],
    ["10:10", "10:15", "10:20"]
])

class AlermListModel: AlermListModelProtocol {
    static let shared = AlermListModel()
    
    let localCache: LocalCache = .shared
    private let _alerms = BehaviorRelay<[[String]]>(value: [])

    public var alerms: BehaviorRelay<[[String]]> {
        get {
            return self._alerms
        }
    }
    
    func loadAlermListFromLocalCache() {
        localCache.setEncodableObject(forKey: "alerms", value: alermTestData)
        let data = localCache.getDecodableObject(forKey: "alerms") as Alerms?
        guard let alerms = data?.values else { return }
        self._alerms.accept(alerms)
    }
    
    func addAlerm(alerm: [String]) {
        var alerms = self.alerms.value
        alerms.append(alerm)
        self._alerms.accept(alerms)
    }
}

struct Alerms: Codable {
    let values: [[String]]

    init(values: [[String]]) {
        self.values = values
    }
}

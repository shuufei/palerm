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
    func addAlerm(alerm: Alerm)
    func updateAlerm(alerm: Alerm, isCommit: Bool)
    var alerms$: BehaviorRelay<[Alerm]> { get }
    var alerms: [Alerm] { get }
}

let alermTestData: [Alerm] = [
    Alerm(times:["08:00", "08:05", "08:10", "08:15", "08:20", "08:25", "08:30"]),
    Alerm(times: ["09:30"]),
    Alerm(times: ["10:10", "10:15", "10:20"])
]

class AlermListModel: AlermListModelProtocol {
    static let shared = AlermListModel()
    
    let localCache: LocalCache = .shared
    private let _alerms$ = BehaviorRelay<[Alerm]>(value: [])

    public var alerms$: BehaviorRelay<[Alerm]> {
        get {
            return self._alerms$
        }
    }
    
    public var alerms: [Alerm] = []
    
    func loadAlermListFromLocalCache() {
//        self.setAlermListToLocalCache(alermList: alermTestData)
        let data = localCache.getDecodableObject(forKey: "alerms") as [Alerm]?
        guard let alerms = data else { return }
        self.alerms = alerms
        self._alerms$.accept(alerms)
    }
    
    func addAlerm(alerm: Alerm) {
        var alerms = self.alerms
        alerms.append(alerm)
        self.setAlermListToLocalCache(alermList: alerms)
        self.alerms = alerms
        self._alerms$.accept(alerms)
    }
    
    func updateAlerm(alerm: Alerm, isCommit: Bool = true) {
        var alerms: [Alerm] = []
        for _alerm in self.alerms {
            if (alerm.id == _alerm.id) {
                alerms.append(alerm)
            } else {
                alerms.append(_alerm)
            }
        }
        self.setAlermListToLocalCache(alermList: alerms)
        self.alerms = alerms
        if (isCommit) {
            self._alerms$.accept(alerms)
        }
    }
    
    private func setAlermListToLocalCache(alermList: [Alerm]) {
        localCache.setEncodableObject(forKey: "alerms", value: alermList)
    }
}

struct Alerm: Codable {
    let times: [String]
    let enableTimes: [String]
    var id: String = NSUUID().uuidString
    
    init(times: [String]) {
        self.times = times
        self.enableTimes = times
    }
    
    init(id: String, times: [String]) {
        self.id = id
        self.times = times
        self.enableTimes = times
    }
    
    init(id: String, times: [String], enableTimes: [String]) {
        self.id = id
        self.times = times
        self.enableTimes = enableTimes
    }
}


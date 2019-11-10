//
//  AlermListModel.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/10/10.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import Foundation

protocol AlermListModelProtocol {
    func loadAlermListFromLocalCache()
}

let alermTestData = Alerms(times: [
    ["08:00", "08:05", "08:10", "08:15", "08:20", "08:25", "08:30"],
    ["09:30"],
    ["10:10", "10:15", "10:20"]
    ])

class AlermListModel: AlermListModelProtocol {
    
    let localCache: LocalCache = .shared
    
    func loadAlermListFromLocalCache() {
//        localCache.setEncodableObject(forKey: "alerms", value: alermTestData)
        let data = localCache.getDecodableObject(forKey: "alerms") as Alerms?
        guard let alerms = data?.times else { return }
        print("--- load alerms data: ", alerms)
    }
}

struct Alerms: Codable {
    let times: [[String]]
    
    init(times: [[String]]) {
        self.times = times
    }
}

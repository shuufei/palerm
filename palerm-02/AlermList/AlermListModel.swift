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

class AlermListModel: AlermListModelProtocol {
    
    let localCache: LocalCache = .shared
    
    func loadAlermListFromLocalCache() {
        print("-- load alerm list in model")
//        localCache.setData(forKey: "hoge", "hoge")
//        localCache.setData(forKey: "Boolean", true)
//        localCache.setData(forKey: "[String]", ["string1", "string2"])
        let dummyData: DummyData = DummyData(id: 1, name: "name")
//        localCache.(forKey: "dummydatate", dummyData)
        localCache.setEncodableObject(forKey: "dummydata", value: dummyData)
        let data = localCache.getDecodableObject(forKey: "dummydata") as DummyData?
        print("--- data: ", data!)
    }
}


struct DummyData: Codable {
    let id: Int
    let name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

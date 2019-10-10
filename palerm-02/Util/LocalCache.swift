//
//  LocalCache.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/10/10.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import Foundation

class LocalCache {
    static let shared = LocalCache()
    
    let userDefaults = UserDefaults.standard
    
    init() {}
    
    func setData<T>(forKey key: String,  _ data: T) {
        userDefaults.set(data, forKey: key)
        userDefaults.synchronize()
        let v: T = userDefaults.object(forKey: key) as! T
        print("--- v: ", v)
    }
    
    func setEncodableObject<T: Encodable>(forKey key: String, value: T) {
        guard let data = try? JSONEncoder().encode(value) else {
            return
        }
        userDefaults.set(data, forKey: key)
        userDefaults.synchronize()
    }
    
    func getDecodableObject<T: Decodable>(forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

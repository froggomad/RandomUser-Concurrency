//
//  Cache.swift
//  RandomUser Concurrency
//
//  Created by Kenneth Dubroff on 3/29/21.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var stores = [Key: Value]()
    private let queue = DispatchQueue(label: "CacheQueue")
    func cache(value: Value, for key: Key) {
        queue.sync {
            self.stores[key] = value
        }
    }
    
    func value(for key: Key) -> Value? {
        queue.sync {
            return self.stores[key] ?? nil
        }
    }
}

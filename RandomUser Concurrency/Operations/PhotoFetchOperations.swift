//
//  PhotoFetchOperation.swift
//  RandomUser Concurrency
//
//  Created by Kenneth Dubroff on 3/28/21.
//

import Foundation

enum PhotoType {
    case thumbnail
    case large
}

class PhotoFetchOperation: ConcurrentOperation {
    
    // MARK: - Properties
    private let queue = DispatchQueue(label: "PhotoFetchQueue")
    private var userRef: RandomUser
    var imageData: Data?
    var type: PhotoType
    private var dataTask: URLSessionDataTask?
    
    init(type: PhotoType, ref: RandomUser, session: URLSession = .shared) {
        self.userRef = ref
        self.type = type
        super.init()
    }
    
    override func start() {
        state = .isExecuting
        fetchPhoto()
        dataTask?.resume()
    }
    
    override func cancel() {
        state = .isFinished
        dataTask?.cancel()
    }
    
    func fetchPhoto() {
        var url: URL
        
        switch type {
        case .thumbnail:
            url = userRef.thumbnail
        case .large:
            url = userRef.large
        }
        dataTask = URLSession.shared.dataTask(with: url) { [unowned self] (data, _, error) in
            defer {
                self.state = .isFinished
            }
            if let error = error {
                print(error)
                return
            }
            guard let data = data else {
                print("No data")
                return
            }
            self.queue.sync {
                self.imageData = data
            }
        }
    }
}


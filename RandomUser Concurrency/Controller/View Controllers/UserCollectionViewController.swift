//
//  ViewController.swift
//  RandomUser Concurrency
//
//  Created by Kenneth Dubroff on 3/28/21.
//

import UIKit

class UserCollectionViewController: UICollectionViewController {
    // MARK: - Properties -
    /// The Operations Queue for large user images
    private let largeImageOpQueue = OperationQueue()
    /// Operations hashmap used to schedule requests
    private var operations = [String: Operation]()
    /// Cache holding image data for images that have already been retrieved
    private let largeImageCache = Cache<String, Data>()
    
    private var randomUsers: [RandomUser] = [] {
        didSet {
            if !randomUsers.isEmpty {
                collectionView.reloadData()
            }
        }
    }
    
    private let userController = RandomUserController()
    // MARK: - View Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.prefetchDataSource = self
        // populate cells with usernames
        userController.fetchUsers { result in
            switch result {
            case .success(let users):
                self.randomUsers.append(
                    contentsOf: users?.sorted(by: { $0.username < $1.username }) ?? []
                )
        
            case .failure(let error):
                print(error)
            }
        }
    }
    // MARK: - CollectionView DataSource -
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        randomUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = loadThumbnail(for: indexPath)
        return cell
    }
    
    /// sets ops to fetch data, cache, and display
    private func loadThumbnail(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as! PhotoCell
        let user = randomUsers[indexPath.item]
        cell.user = user
        // load thumbnail from cache
        if let imageData = largeImageCache.value(for: user.id),
           let image = UIImage(data: imageData) {
            cell.imageView.image = image
        } else {
            // fetch image from url
            let fetchOps = dataOps(for: user, at: indexPath)
            let imageSetOp = BlockOperation {
                DispatchQueue.main.async {
                    if let imageData = fetchOps.0.imageData {
                        cell.imageView.image = UIImage(data: imageData)
                    }
                }
            }
            imageSetOp.addDependency(fetchOps.0)
            
            OperationQueue.main.addOperation(imageSetOp)
            operations[user.id] = fetchOps.0
        }
        
        return cell
    }
    
    typealias FetchOperations = (PhotoFetchOperation, BlockOperation)
    
    /// Create fetch and cache operations for the user's large image and add them to the OperationQueue
    /// - Parameters:
    /// - Returns: FetchOperations (.0 is PhotoFetchOperation, .1 is BlockOperation aka cacheOp)
    private func dataOps(for user: RandomUser, at indexPath: IndexPath) -> FetchOperations {
        let user = randomUsers[indexPath.item]
        let fetchOp = PhotoFetchOperation(type: .large, ref: user)
        let cacheOp = BlockOperation {
            if let data = fetchOp.imageData {
                self.largeImageCache.cache(value: data, for: user.id)
            }
        }
        cacheOp.addDependency(fetchOp)
        largeImageOpQueue.addOperations ([
            fetchOp,
            cacheOp
        ], waitUntilFinished: false)
        return (fetchOp, cacheOp)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let user = randomUsers[indexPath.item]
        operations[user.id]?.cancel()
    }
}
// MARK: - Prefetch -
extension UserCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let user = randomUsers[indexPath.item]
            if largeImageCache.value(for: user.id) == nil {
                let fetchOps = dataOps(for: user, at: indexPath)
                operations[user.id] = fetchOps.0
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let user = randomUsers[indexPath.item]
            operations[user.id]?.cancel()
        }
    }
    
}

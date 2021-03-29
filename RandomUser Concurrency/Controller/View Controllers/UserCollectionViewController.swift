//
//  ViewController.swift
//  RandomUser Concurrency
//
//  Created by Kenneth Dubroff on 3/28/21.
//

import UIKit

class UserCollectionViewController: UICollectionViewController {
    // MARK: - Properties -
    private let largeImageOpQueue = OperationQueue()
    private var operations = [String: Operation]()
    
    private let largeImageCache = Cache<String, Data>()
    private var randomUsers: [RandomUser] = [] {
        didSet {
            if !randomUsers.isEmpty {
                collectionView.reloadData()
            }
        }
    }
    
    private let userController = RandomUserController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userController.fetchUsers { result in
            switch result {
            case .success(let users):
                self.randomUsers = users?.sorted(by: { user1, user2  in
                                                    var user1 = user1
                                                    var user2 = user2
                                                    return user1.username < user2.username }) ?? []
        
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        randomUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = loadThumbnail(for: indexPath)
        return cell
    }
    
    private func loadThumbnail(for indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as! PhotoCell
        var user = randomUsers[indexPath.item]
        //assign user to cell
        cell.user = user
        // load thumbnail
        if let imageData = largeImageCache.value(for: user.id),
           let image = UIImage(data: imageData) {
            cell.imageView.image = image
        } else {
            let fetchOps = dataOps(for: user, at: indexPath)
            let imageSetOp = BlockOperation {
                DispatchQueue.main.async {
                    if let imageData = fetchOps.0.imageData {
                        cell.imageView.image = UIImage(data: imageData)
                    }
                }
            }
            imageSetOp.addDependency(fetchOps.0)
            largeImageOpQueue.addOperations ([
                fetchOps.0,
                fetchOps.1
            ], waitUntilFinished: false)
            
            OperationQueue.main.addOperation(imageSetOp)
            operations[user.id] = fetchOps.0
        }
        
        return cell
    }
    
    private func dataOps(for user: RandomUser, at indexPath: IndexPath) -> (PhotoFetchOperation, BlockOperation) {
        var user = randomUsers[indexPath.item]
        let fetchOp = PhotoFetchOperation(type: .large, ref: user)
        let cacheOp = BlockOperation {
            if let data = fetchOp.imageData {
                self.largeImageCache.cache(value: data, for: user.id)
            }
        }
        cacheOp.addDependency(fetchOp)
        return (fetchOp, cacheOp)
    }
    
    
    
}

extension UserCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 100, height: 128)
    }
}

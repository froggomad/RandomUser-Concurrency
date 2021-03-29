//
//  ViewController.swift
//  RandomUser Concurrency
//
//  Created by Kenneth Dubroff on 3/28/21.
//

import UIKit

class UserCollectionViewController: UICollectionViewController {
    // MARK: - Properties -
    private let thumbnailFetchQueue = OperationQueue()
    private var operations = [Int: Operation]()
    
    private let thumbnailCache = Cache<Int, Data>()
    var randomUsers: [RandomUser] = [] {
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
                self.randomUsers = users ?? []
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        randomUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier, for: indexPath) as! PhotoCell
        cell.user = randomUsers[indexPath.item]
        return cell
    }


}


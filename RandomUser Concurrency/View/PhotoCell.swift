//
//  PhotoCell.swift
//  RandomUser Concurrency
//
//  Created by Kenneth Dubroff on 3/28/21.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    static let reuseIdentifier = "PhotoCell"
    private let defaultTitle = "Loading..."
    private let defaultImage = UIImage(systemName: "hourglass.fill")
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    var user: RandomUser? {
        didSet {
            updateViews()
        }
    }
    
    private func updateViews() {
        guard let user = user else {
            titleLabel.text = defaultTitle
            imageView.image = defaultImage
            return
        }
        titleLabel.text = user.username        
    }
}

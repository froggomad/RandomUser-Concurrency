//
//  RandomUser.swift
//  RandomUser Concurrency
//
//  Created by Kenneth Dubroff on 3/28/21.
//

import Foundation

struct UserResults: Codable {
    let results: [RandomUser]
}

struct LoginInformation: Codable {
    let username: String
}

struct PictureInformation: Codable {
    let large: URL
    let thumbnail: URL
}

struct RandomUser: Codable {
    lazy var username: String = login.username
    lazy var thumbnail: URL  = picture.thumbnail
    lazy var large: URL = picture.large
    // Codable properties
    let login: LoginInformation
    let picture: PictureInformation
    
}

//
//  RandomUser.swift
//  RandomUser Concurrency
//
//  Created by Kenneth Dubroff on 3/28/21.
//

import Foundation
/// TDO for RandomUser
struct UserResults: Codable {
    let results: [RandomUser]
}
/// TDO for RandomUser
struct LoginInformation: Codable {
    let uuid: String
    let username: String
}
/// TDO for RandomUser
struct PictureInformation: Codable {
    let large: URL
    let thumbnail: URL
}

struct RandomUser: Codable {
    var username: String { login.username }
    var thumbnail: URL { picture.thumbnail }
    var large: URL { picture.large }
    var id: String { login.uuid }
    // Codable properties
    let login: LoginInformation
    let picture: PictureInformation
}

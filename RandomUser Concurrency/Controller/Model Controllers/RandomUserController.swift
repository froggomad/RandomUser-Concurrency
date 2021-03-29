//
//  RandomUserController.swift
//  RandomUser Concurrency
//
//  Created by Kenneth Dubroff on 3/28/21.
//

import Foundation

class RandomUserController {   
    
    private let networkService = NetworkService()
    private let baseURL: URL = URL(string: "https://randomuser.me/api/")!
    
    func fetchUsers(results: Int = 500, page: Int = 1, seed: String = "abc", completion: @escaping (Result<[RandomUser]?, Error>) -> Void) {
        let pageQueryItem = URLQueryItem(name: "page", value: String(page))
        let resultQueryItem = URLQueryItem(name: "results", value: String(results))
        let seedQueryItem = URLQueryItem(name: "seed", value: seed)
        guard var components = URLComponents(string: baseURL.absoluteString) else { return }
        components.queryItems = [pageQueryItem, resultQueryItem, seedQueryItem]
        
        guard let request = networkService.createRequest(url: components.url, method: .get) else { return }
        networkService.loadData(using: request) { [unowned self] data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            let url = request.url
            print(url)
            guard let data = data,
                  let users = self.networkService.decode(to: UserResults.self, data: data)
            else {
                let error = NSError(domain: "\(#file).\(#function): \(#line)", code: 999, userInfo: [NSLocalizedDescriptionKey : "Object does not exist"])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            DispatchQueue.main.async {
                completion(.success(users.results))
            }
        }
    }
}

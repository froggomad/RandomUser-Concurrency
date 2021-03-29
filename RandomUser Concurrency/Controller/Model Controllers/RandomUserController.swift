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
    
    func fetchUsers(_ number: Int = 5000, completion: @escaping (Result<[RandomUser]?, Error>) -> Void) {
        let queryItem = URLQueryItem(name: "results", value: String(number))
        guard var components = URLComponents(string: baseURL.absoluteString) else { return }
        components.queryItems = [queryItem]
        
        guard let request = networkService.createRequest(url: components.url, method: .get) else { return }
        networkService.loadData(using: request) { [unowned self] data, _, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
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

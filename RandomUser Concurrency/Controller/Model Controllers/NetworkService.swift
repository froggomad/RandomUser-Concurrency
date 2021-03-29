//
//  NetworkService.swift
//  RandomUser Concurrency
//
//  Created by Kenneth Dubroff on 3/28/21.
//

import Foundation

/// Standard URL Handler that can also be used in Unit Tests with mock data
protocol NetworkLoader {
    func loadData(using request: URLRequest, with completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
}

// TODO: Improve error handling
/// Provide default error and response handling for network tasks
extension URLSession: NetworkLoader {
    func loadData(using request: URLRequest, with completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        self.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Networking error with \(String(describing: request.url?.absoluteString)) \n\(error)")
            }
            
            completion(data, response as? HTTPURLResponse, error)
        }.resume()
    }
}

class NetworkService {
    // MARK: - Types -
    
    ///Used to set a`URLRequest`'s HTTP Method
    enum HttpMethod: String {
        case get = "GET"
        case patch = "PATCH"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    /**
     used when the endpoint requires a header-type (i.e. "content-type") be specified in the header
     */
    enum HttpHeaderType: String {
        case contentType = "Content-Type"
    }
    
    /**
     the value of the header-type (i.e. "application/json")
     */
    enum HttpHeaderValue: String {
        case json = "application/json"
    }
    
    /**
     - parameter request: should return nil if there's an error or a valid request object if there isn't
     - parameter error: should return nil if the request succeeded and a valid error if it didn't
     */
    struct EncodingStatus {
        let request: URLRequest?
        let error: Error?
    }
    
    ///used to switch between live and Mock Data
    var dataLoader: NetworkLoader
    
    //MARK: - Init -
    ///defaults to URLSession implementation
    init(dataLoader: NetworkLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }
    
    ///for json encoding/decoding (can be modified to meet specific criteria)
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
    
    /**
     Create a request given a URL and requestMethod (GET, POST, CREATE, etc...)
     */
    func createRequest(
        url: URL?, method: HttpMethod,
        headerType: HttpHeaderType? = nil,
        headerValue: HttpHeaderValue? = nil
    ) -> URLRequest? {
        guard let requestUrl = url else {
            NSLog("request URL is nil")
            return nil
        }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.rawValue
        if let headerType = headerType,
           let headerValue = headerValue {
            request.setValue(headerValue.rawValue, forHTTPHeaderField: headerType.rawValue)
        }
        return request
    }
    
    /**
     Encode from a Swift object to JSON for transmitting to an endpoint
     - parameter type: the type to be encoded (i.e. MyCustomType.self)
     - parameter request: the URLRequest used to transmit the encoded result to the remote server
     - parameter dateFormatter: optional for use with JSONEncoder.dateEncodingStrategy
     - returns: An EncodingStatus object which should either contain an error and nil request or request and nil error
     */
    func encode<T: Encodable>(
        from type: T,
        request: URLRequest,
        dateFormatter: DateFormatter? = nil
    ) -> EncodingStatus {
        var request = request
        let jsonEncoder = JSONEncoder()
        //for optional dateFormatter
        if let dateFormatter = dateFormatter {
            jsonEncoder.dateEncodingStrategy = .formatted(dateFormatter)
        }
        
        do {
            request.httpBody = try jsonEncoder.encode(type)
        } catch {
            print("Error encoding object into JSON \(error)")
            return EncodingStatus(request: nil, error: error)
        }
        
        return EncodingStatus(request: request, error: nil)
    }
    
    func decode<T: Decodable>(
        to type: T.Type,
        data: Data,
        dateFormatter: DateFormatter? = nil
    ) -> T? {
        let decoder = JSONDecoder()
        //for optional dateFormatter
        if let dateFormatter = dateFormatter {
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error Decoding JSON into \(String(describing: type)) Object \(error)")
            return nil
        }
    }
    
    func loadData(using request: URLRequest, with completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.dataLoader.loadData(using: request, with: completion)
    }
}




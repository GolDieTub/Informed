//
//  NewsService.swift
//  Informed
//
//  Created by Uladzimir on 16/05/2025.
//

import Foundation
import Combine

class NewsService {
    static let shared = NewsService()
    private init() {}
    
    private let guardianURL = "https://us-central1-server-side-functions.cloudfunctions.net/guardian"
    private let navigationURL = "https://us-central1-server-side-functions.cloudfunctions.net/navigation"
    private let authHeader = "uladzimir-kucharenka"
    
    func fetchArticles(page: Int = 1, pageSize: Int = 9, completion: @escaping (Result<[Article], Error>) -> Void) {
        var urlComponents = URLComponents(string: guardianURL)!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "page-size", value: String(pageSize))
        ]
        var request = URLRequest(url: urlComponents.url!)
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error { return completion(.failure(error)) }
            guard let data = data else { return }
            do {
                let decoded = try JSONDecoder().decode(ArticleResponse.self, from: data)
                completion(.success(decoded.response.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchNavigationBlocks() async throws -> [NavigationBlock] {
        guard let url = URL(string: navigationURL) else {
            return []
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(authHeader, forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode([String: [NavigationBlock]].self, from: data)
        return decoded["results"] ?? []
    }
    
    func fetchArticlesPublisher(page: Int) -> AnyPublisher<[Article], Error> {
        Future { promise in
            self.fetchArticles(page: page) { result in
                promise(result)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchNavigationBlocksPublisher() -> AnyPublisher<[NavigationBlock], Error> {
        Future { promise in
            Task {
                do {
                    let blocks = try await self.fetchNavigationBlocks()
                    promise(.success(blocks))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

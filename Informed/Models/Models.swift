//
//  models.swift
//  Informed
//
//  Created by Uladzimir on 16/05/2025.
//

import Foundation

struct Article: Identifiable, Codable, Equatable {
    var id: String { apiUrl }
    let sectionName: String
    let webTitle: String
    let webUrl: String
    let apiUrl: String
    let webPublicationDate: String
}

struct ArticleResponse: Codable {
    let response: ArticleList
}

struct ArticleList: Codable {
    let results: [Article]
}

struct IdentifiableURL: Hashable, Identifiable {
    let url: URL
    var id: URL { url }
}

enum NewsItem: Identifiable {
    case article(Article)
    case banner(NavigationBlock)
    
    var id: String {
        switch self {
        case .article(let a): return a.id
        case .banner(let b): return "banner-\(b.id)"
        }
    }
}

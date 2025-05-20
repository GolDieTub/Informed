//
//  NavigationBlock.swift
//  Informed
//
//  Created by Uladzimir on 16/05/2025.
//

import Foundation

struct NavigationBlock: Identifiable, Decodable, Equatable, Hashable {
    let id: Int
    let title: String
    let subtitle: String?
    let title_symbol: String?
    let button_title: String
    let button_symbol: String?
    let navigation: NavigationType
    
    enum NavigationType: String, Codable {
        case push
        case modal
        case full_screen
        case unknown
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            self = NavigationType(rawValue: value) ?? .unknown
        }
    }
}

//
//  UserDefaultsStorage.swift
//  Informed
//
//  Created by Uladzimir on 19/05/2025.
//

import Foundation

protocol DataStorage {
    func save<T: Encodable>(_ value: T, forKey key: StorageKey) throws
    func load<T: Decodable>(_ type: T.Type, forKey key: StorageKey) throws -> T?
    func remove(forKey key: StorageKey)
    func hasValue(forKey key: StorageKey) -> Bool
}

enum StorageKey: String {
    case favorites
    case blocked
}

final class UserDefaultsStorage: DataStorage {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func save<T: Encodable>(_ value: T, forKey key: StorageKey) throws {
        do {
            let data = try JSONEncoder().encode(value)
            userDefaults.set(data, forKey: key.rawValue)
        } catch {
            throw StorageError.failedToEncode(error: error)
        }
    }
    
    func load<T: Decodable>(_ type: T.Type, forKey key: StorageKey) throws -> T? {
        guard let data = userDefaults.data(forKey: key.rawValue) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw StorageError.failedToDecode(error: error)
        }
    }
    
    func remove(forKey key: StorageKey) {
        userDefaults.removeObject(forKey: key.rawValue)
    }
    
    func hasValue(forKey key: StorageKey) -> Bool {
        return userDefaults.data(forKey: key.rawValue) != nil
    }
}

enum StorageError: Error, LocalizedError {
    case failedToEncode(error: Error)
    case failedToDecode(error: Error)
    
    var errorDescription: String? {
        switch self {
        case .failedToEncode(let error):
            return "Failed to encode data: \(error.localizedDescription)"
        case .failedToDecode(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        }
    }
}

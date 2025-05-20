//
//  NewsViewModel.swift
//  Informed
//
//  Created by Uladzimir on 16/05/2025.
//

import Foundation
import Combine

class NewsViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var favorites: [Article] = [] {
        didSet { persistFavorites() }
    }
    @Published var blocked: [Article] = [] {
        didSet { persistBlocked() }
    }
    @Published var isLoading = false
    @Published var selectedTab: Tab = .all
    @Published var navigationBlocks: [NavigationBlock] = []
    @Published var selectedBlock: NavigationBlock? = nil
    @Published var activeNavigation: NavigationBlock.NavigationType? = nil
    @Published var loadError = false
    @Published var errorMessage: String? = nil
    @Published var initialLoadingFinished = false
    
    private var page = 1
    private var cancellables = Set<AnyCancellable>()
    private let newsService: NewsServiceProtocol
    private let storage: DataStorage
    
    enum Tab { case all, favorites, blocked }
    
    init(
        newsService: NewsServiceProtocol = NewsService.shared,
        storage: DataStorage = UserDefaultsStorage()
    ) {
        self.newsService = newsService
        self.storage = storage
        loadPersistedData()
    }
    
    func loadInitial() {
        initialLoadingFinished = false
        fetchArticles(reset: true)
        fetchNavigationBlocks()
    }
    
    func fetchArticles(reset: Bool = false) {
        if reset { page = 1 }
        isLoading = true
        loadError = false
        errorMessage = nil
        
        newsService.fetchArticlesPublisher(page: page)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isLoading = false
                self?.initialLoadingFinished = true
            })
            .map { [weak self] newArticles -> [Article] in
                guard let self = self else { return [] }
                guard !reset else { return newArticles }
                let existingIds = Set(self.articles.map { $0.id })
                return newArticles.filter { !existingIds.contains($0.id) }
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] newArticles in
                    guard let self = self else { return }
                    reset ? (self.articles = newArticles) : self.articles.append(contentsOf: newArticles)
                    self.page += 1
                }
            )
            .store(in: &cancellables)
    }
    
    func fetchNavigationBlocks() {
        newsService.fetchNavigationBlocksPublisher()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Navigation blocks fetch error: \(error)")
                    }
                },
                receiveValue: { [weak self] blocks in
                    self?.navigationBlocks = blocks
                }
            )
            .store(in: &cancellables)
    }
    
    func toggleFavorite(_ article: Article) {
        if let index = favorites.firstIndex(where: { $0.id == article.id }) {
            favorites.remove(at: index)
        } else {
            favorites.insert(article, at: 0)
        }
    }
    
    func toggleBlocked(_ article: Article) {
        if let index = blocked.firstIndex(where: { $0.id == article.id }) {
            blocked.remove(at: index)
        } else {
            blocked.insert(article, at: 0)
            favorites.removeAll { $0.id == article.id }
        }
    }
    
    func isFavorite(_ article: Article) -> Bool {
        favorites.contains { $0.id == article.id }
    }
    
    func isBlocked(_ article: Article) -> Bool {
        blocked.contains { $0.id == article.id }
    }
    
    func select(_ block: NavigationBlock) {
        selectedBlock = block
        activeNavigation = block.navigation
    }
    
    func clearBannerSelection() {
        selectedBlock = nil
        activeNavigation = nil
    }
    
    var filteredArticles: [Article] {
        switch selectedTab {
        case .all:
            return articles.filter { !blocked.contains($0) }
        case .favorites:
            return favorites
        case .blocked:
            return blocked
        }
    }
    
    private func loadPersistedData() {
        favorites = (try? storage.load([Article].self, forKey: .favorites)) ?? []
        blocked = (try? storage.load([Article].self, forKey: .blocked)) ?? []
    }
    
    private func handleError(_ error: Error) {
        loadError = true
        errorMessage = error.isNetworkError
        ? "No Internet Connection"
        : "Something went wrong"
    }
    
    private func persistFavorites() {
        do {
            try storage.save(favorites, forKey: .favorites)
        } catch {
            handleStorageError(error, message: "Failed to save favorites")
        }
    }
    
    private func persistBlocked() {
        do {
            try storage.save(blocked, forKey: .blocked)
        } catch {
            handleStorageError(error, message: "Failed to save blocked articles")
        }
    }
    
    private func handleStorageError(_ error: Error, message: String) {
        print("\(message): \(error.localizedDescription)")
        errorMessage = message
    }
}

private extension Error {
    var isNetworkError: Bool {
        guard let urlError = self as? URLError else { return false }
        return urlError.code == .notConnectedToInternet
    }
}

protocol NewsServiceProtocol {
    func fetchArticlesPublisher(page: Int) -> AnyPublisher<[Article], Error>
    func fetchNavigationBlocksPublisher() -> AnyPublisher<[NavigationBlock], Error>
}

extension NewsService: NewsServiceProtocol {}

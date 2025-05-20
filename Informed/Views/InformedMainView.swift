//
//  ContentView.swift
//  Informed
//
//  Created by Uladzimir on 16/05/2025.
//

import SwiftUI

struct InformedMainView: View {
    @StateObject var viewModel = NewsViewModel()
    @State private var path: [NavigationBlock] = []
    @State private var selectedURL: IdentifiableURL?
    @State private var alertArticle: Article?
    @State private var alertIsUnblock = false
    @State private var infoAlertText: String?
    @State private var scrollOffset: CGFloat = 0
    
    private var allItems: [NewsItem] {
        var result: [NewsItem] = []
        let articles = viewModel.filteredArticles
        let banners = viewModel.navigationBlocks.sorted { $0.id < $1.id }
        var bannerCounter = 0
        
        for (index, article) in articles.enumerated() {
            result.append(.article(article))
            
            if viewModel.selectedTab == .all, (index + 1) % 3 == 0, !banners.isEmpty {
                let banner = banners[bannerCounter % banners.count]
                result.append(.banner(banner))
                bannerCounter += 1
            }
        }
        return result
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.lightGrayBg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    
                    if viewModel.selectedTab == .favorites && viewModel.favorites.isEmpty {
                        emptyStateView(image: "heart.circle.fill", message: "No Favorite News")
                    } else if viewModel.selectedTab == .blocked && viewModel.blocked.isEmpty {
                        emptyStateView(image: "nosign", message: "No Blocked News")
                    } else if viewModel.initialLoadingFinished && (viewModel.loadError || viewModel.filteredArticles.isEmpty) {
                        noResultsView
                    } else {
                        articleListView
                    }
                }
                
                if viewModel.isLoading && viewModel.filteredArticles.isEmpty {
                    loadingOverlay
                }
            }
            .navigationDestination(for: NavigationBlock.self) { block in
                BannerScreen(block: block)
            }
            .fullScreenCover(item: $selectedURL) { wrapper in
                SafariView(url: wrapper.url)
            }
            .sheet(isPresented: Binding(
                get: { viewModel.activeNavigation == .modal },
                set: { if !$0 { viewModel.clearBannerSelection() } }
            )) {
                if let block = viewModel.selectedBlock {
                    BannerScreen(block: block)
                }
            }
            .fullScreenCover(isPresented: Binding(
                get: { viewModel.activeNavigation == .full_screen },
                set: { if !$0 { viewModel.clearBannerSelection() } }
            )) {
                if let block = viewModel.selectedBlock {
                    BannerScreen(block: block)
                }
            }
            .customAlert(
                isPresented: alertArticle != nil,
                isUnblock: alertIsUnblock,
                onConfirm: {
                    if let article = alertArticle {
                        viewModel.toggleBlocked(article)
                    }
                    alertArticle = nil
                },
                onCancel: {
                    alertArticle = nil
                }
            )
            .customInfoAlert(
                isPresented: Binding(get: { infoAlertText != nil }, set: { if !$0 { infoAlertText = nil } }),
                message: infoAlertText ?? "",
                onDismiss: {
                    infoAlertText = nil
                }
            )
            .onReceive(viewModel.$errorMessage.compactMap { $0 }) { message in
                infoAlertText = message
            }
        }
        .onAppear {
            viewModel.loadInitial()
        }
        .preferredColorScheme(.light)
    }
    
    private var headerView: some View {
        let config = HeaderAnimationConfig()
        let shouldAnimateHeader = viewModel.filteredArticles.count >= config.minArticlesCount
        let clamped = shouldAnimateHeader ? min(max(-scrollOffset, 0), config.maxOffset) : 0
        let progress = clamped / config.maxOffset
        let interpolatedFontSize = config.fontSize(for: progress)
        let horizontalOffset = config.xOffset(for: progress, containerWidth: UIScreen.main.bounds.width)

        return VStack(spacing: 0) {
            Text("News")
                .font(.system(size: interpolatedFontSize, weight: .bold))
                .foregroundColor(.textPrimary)
                .frame(height: config.headerHeight)
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(x: horizontalOffset)
                .padding(.horizontal, config.horizontalPadding)
            
            ZStack {
                if progress < config.pickerHideThreshold {
                    Picker("Filter", selection: $viewModel.selectedTab) {
                        Text("All").tag(NewsViewModel.Tab.all)
                        Text("Favorites").tag(NewsViewModel.Tab.favorites)
                        Text("Blocked").tag(NewsViewModel.Tab.blocked)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, config.horizontalPadding)
                    .transition(.opacity)
                }
            }
            .frame(height: config.pickerHeight(for: progress))
            .clipped()
            .opacity(1 - progress)
        }
        .frame(height: config.totalHeight - config.headerHeight * progress)
        .background(Color.lightGrayBg)
        .animation(.easeInOut(duration: config.animationDuration), value: progress)
    }
    
    private func emptyStateView(image: String, message: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: image)
                .font(.system(size: 48))
                .foregroundColor(.accentPrimary)
            Text(message)
                .foregroundColor(.textPrimary)
                .fontWeight(.semibold)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentPrimary)
            Text("No Results")
                .foregroundColor(.textPrimary)
                .font(.system(size: 17, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            Button {
                viewModel.loadInitial()
            } label: {
                ZStack {
                    Text("Refresh")
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .semibold))
                        .tracking(0.4)
                        .frame(maxWidth: .infinity, alignment: .center)
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                .frame(width: 328, height: 44)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var articleListView: some View {
        ScrollView {
            Color.clear
                .frame(height: 0)
                .trackScrollOffset { offset in
                    scrollOffset = offset
                }
            
            LazyVStack(spacing: 8) {
                ForEach(allItems) { item in
                    VStack {
                        switch item {
                        case .article(let article):
                            NewsCardView(
                                article: article,
                                currentTab: viewModel.selectedTab,
                                onArticleTap: {
                                    if let url = URL(string: article.webUrl) {
                                        selectedURL = IdentifiableURL(url: url)
                                    }
                                },
                                onFavorite: { viewModel.toggleFavorite(article) },
                                onUnfavorite: { viewModel.toggleFavorite(article) },
                                onBlock: {
                                    alertArticle = article
                                    alertIsUnblock = false
                                },
                                onUnblock: {
                                    alertArticle = article
                                    alertIsUnblock = true
                                },
                                isFavorite: viewModel.isFavorite(article)
                            )
                            .onAppear {
                                if viewModel.selectedTab == .all,
                                   article == viewModel.filteredArticles.last,
                                   !viewModel.isLoading {
                                    viewModel.fetchArticles()
                                }
                            }
                            
                        case .banner(let block):
                            BannerDynamicView(block: block) {
                                switch block.navigation {
                                case .push:
                                    path.append(block)
                                case .modal:
                                    viewModel.select(block)
                                    viewModel.activeNavigation = .modal
                                case .full_screen:
                                    viewModel.select(block)
                                    viewModel.activeNavigation = .full_screen
                                case .unknown: break
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                if viewModel.isLoading && !viewModel.filteredArticles.isEmpty {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .padding()
                        Spacer()
                    }
                }
            }
            .background(Color.lightGrayBg)
        }
        .coordinateSpace(name: "scroll")
        .refreshable {
            viewModel.loadInitial()
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                .scaleEffect(1.5)
        }
    }
}

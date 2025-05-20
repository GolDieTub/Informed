//
//  NewsCardView.swift
//  Informed
//
//  Created by Uladzimir on 17/05/2025.
//

import SwiftUI

struct NewsCardView: View {
    let article: Article
    let currentTab: NewsViewModel.Tab
    let onArticleTap: () -> Void
    let onFavorite: () -> Void
    let onUnfavorite: () -> Void
    let onBlock: () -> Void
    let onUnblock: () -> Void
    let isFavorite: Bool
    
    var body: some View {
        Button(action: onArticleTap) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .frame(height: 110)
                
                HStack(alignment: .top, spacing: 12) {
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.lightGrayBg)
                            .frame(width: 94, height: 86)
                        
                        Image(systemName: "newspaper.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 20)
                            .foregroundColor(.accentPrimary)
                            .padding(.top, 33)
                            .padding(.leading, 35)
                        
                        if isFavorite {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.blue)
                                .padding(4)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: -6, y: -6)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(article.webTitle)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                        
                        Text("\(article.sectionName) • \(article.webPublicationDate.formattedDate())")
                            .font(.system(size: 15))
                            .foregroundColor(.textSecondary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                    }
                    
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.leading, 12)
                .padding(.trailing, 40)
                
                Menu {
                    switch currentTab {
                    case .all:
                        if isFavorite {
                            Button {
                                onUnfavorite()
                            } label: {
                                Label("Remove from Favorites", systemImage: "heart.slash")
                            }
                        } else {
                            Button {
                                onFavorite()
                            } label: {
                                Label("Add to Favorites", systemImage: "heart")
                            }
                        }
                        
                        Button(role: .destructive) {
                            onBlock()
                        } label: {
                            Label("Block", systemImage: "nosign")
                        }
                        
                    case .favorites:
                        Button {
                            onUnfavorite()
                        } label: {
                            Label("Remove from Favorites", systemImage: "heart.slash")
                        }
                        
                        Button(role: .destructive) {
                            onBlock()
                        } label: {
                            Label("Block", systemImage: "nosign")
                        }
                        
                    case .blocked:
                        Button(role: .destructive) {
                            onUnblock()
                        } label: {
                            Label("Unblock", systemImage: "lock.open")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.textSecondary)
                        .frame(width: 24, height: 24)
                        .padding(.top, 12)
                        .padding(.trailing, 12)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

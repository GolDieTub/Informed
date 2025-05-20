//
//  BannerScreen.swift
//  Informed
//
//  Created by Uladzimir on 18/05/2025.
//

import SwiftUI

struct BannerScreen: View {
    let block: NavigationBlock
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: block.navigation == .push ? .center : .topLeading) {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack {
                Spacer()
                
                if let symbol = block.title_symbol {
                    Image(systemName: symbol)
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.blue)
                }
                
                Text(block.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .padding(.top, block.title_symbol != nil ? 8 : 0)
                
                if let subtitle = block.subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                        .padding(.top, 4)
                }
                
                Spacer()
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
            if block.navigation != .push {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.blue)
                        .padding(16)
                }
            }
        }
        .toolbar {
            if block.navigation == .push {
                ToolbarItem(placement: .principal) {
                    Text(block.title)
                        .foregroundColor(.textPrimary)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

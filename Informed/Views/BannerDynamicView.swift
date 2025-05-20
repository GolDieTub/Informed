//
//  BannerDynamicView.swift
//  Informed
//
//  Created by Uladzimir on 18/05/2025.
//

import SwiftUI

struct BannerDynamicView: View {
    let block: NavigationBlock
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            if let symbol = block.title_symbol {
                Image(systemName: symbol)
                    .foregroundColor(.blue)
                    .font(.system(size: 28))
            }
            
            Text(block.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.textPrimary)
            
            if let subtitle = block.subtitle {
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: action) {
                ZStack {
                    Text(block.button_title)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Spacer()
                        if let symbol = block.button_symbol {
                            Image(systemName: symbol)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
    }
}

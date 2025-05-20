//
//  CustomAlertModifier.swift
//  Informed
//
//  Created by Uladzimir on 18/05/2025.
//

import SwiftUI

struct CustomAlertModifier: ViewModifier {
    let isPresented: Bool
    let isUnblock: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                CustomBlurBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack(spacing: 4) {
                        Text(isUnblock ? "Do you want to unblock?" : "Do you want to block?")
                            .font(.system(size: 17, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .frame(height: 22, alignment: .center)
                        
                        Text(isUnblock
                             ? "Confirm to unblock this news source"
                             : "Confirm to block this news source")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .frame(height: 18, alignment: .center)
                        .padding(.bottom, 15)
                    }
                    .padding(.top, 21)
                    .padding(.horizontal, 16)
                    
                    
                    Divider()
                    
                    Button(action: onConfirm) {
                        Text(isUnblock ? "Unblock" : "Block")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(width: 270, height: 44)
                    }
                    
                    Divider()
                    
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 17))
                            .foregroundColor(.blue)
                            .frame(width: 270, height: 44)
                    }
                }
                .frame(width: 270, height: 166)
                .background(Color(.systemBackground))
                .cornerRadius(14)
                .transition(.scale)
                .zIndex(2)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }
}

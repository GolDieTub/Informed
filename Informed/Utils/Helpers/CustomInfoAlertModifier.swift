//
//  CustomInfoAlertModifier.swift
//  Informed
//
//  Created by Uladzimir on 18/05/2025.
//

import SwiftUI

struct CustomInfoAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                
                CustomBlurBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Text(message)
                        .font(.system(size: 17, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 20)
                        .padding(.horizontal, 24)
                        .frame(width: 270)
                    
                    Divider()
                    
                    Button(action: onDismiss) {
                        Text("OK")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, maxHeight: 44)
                    }
                }
                .background(Color.white)
                .cornerRadius(14)
                .frame(width: 270)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }
}

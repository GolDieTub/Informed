//
//  View.swift
//  Informed
//
//  Created by Uladzimir on 18/05/2025.
//

import SwiftUI

extension View {
    func customAlert(
        isPresented: Bool,
        isUnblock: Bool,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> some View {
        self.modifier(CustomAlertModifier(
            isPresented: isPresented,
            isUnblock: isUnblock,
            onConfirm: onConfirm,
            onCancel: onCancel
        ))
    }
    
    func customInfoAlert(
        isPresented: Binding<Bool>,
        message: String,
        onDismiss: @escaping () -> Void
    ) -> some View {
        self.modifier(CustomInfoAlertModifier(
            isPresented: isPresented,
            message: message,
            onDismiss: onDismiss
        ))
    }
    
    func trackScrollOffset(_ action: @escaping (CGFloat) -> Void) -> some View {
        background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).minY)
            }
        )
        .onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: action)
    }
    
}

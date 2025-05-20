//
//  HeaderAnimationConfig.swift
//  Informed
//
//  Created by Uladzimir on 20/05/2025.
//

import SwiftUI

struct HeaderAnimationConfig {
    let minFontSize: CGFloat = 18
    let maxFontSize: CGFloat = 34
    let headerHeight: CGFloat = 56
    let maxOffset: CGFloat = 80
    let pickerHideThreshold: CGFloat = 0.1
    let animationDuration: Double = 0.4
    let horizontalPadding: CGFloat = 16
    let minArticlesCount: Int = 7
    
    func fontSize(for progress: CGFloat) -> CGFloat {
        maxFontSize - (maxFontSize - minFontSize) * progress
    }

    func xOffset(for progress: CGFloat, containerWidth: CGFloat) -> CGFloat {
        (containerWidth / 2 - horizontalPadding * 2) * progress
    }

    func pickerHeight(for progress: CGFloat) -> CGFloat {
        headerHeight * (1 - progress)
    }

    var totalHeight: CGFloat {
        headerHeight * 2
    }
}


//
//  String.swift
//  Informed
//
//  Created by Uladzimir on 18/05/2025.
//

import Foundation

extension String {
    func formattedDate(inputFormat: String = "yyyy-MM-dd'T'HH:mm:ssZ", outputFormat: String = "MMM d, yyyy") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = inputFormat
        
        guard let date = formatter.date(from: self) else { return self }
        
        formatter.dateFormat = outputFormat
        return formatter.string(from: date)
    }
}

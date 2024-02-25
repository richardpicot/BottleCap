//
//  NumberFormatterUtility.swift
//  Bottle Cap
//
//  Created by Richard Picot on 23/02/2024.
//

import Foundation

struct NumberFormatterUtility {
    static func roundedValue(_ value: Double) -> Double {
        return (value * 10).rounded() / 10
    }
    
    static func formatRounded(_ value: Double) -> String {
        let roundedValue = self.roundedValue(value)
        if roundedValue.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", roundedValue)
        } else {
            return String(format: "%.1f", roundedValue)
        }
    }
}


//
//  L10n.swift
//  Reynard
//
//  Chinese localization helpers.
//

import Foundation

enum L10n {
    static func string(_ key: String, comment: String = "") -> String {
        return NSLocalizedString(key, comment: comment)
    }
    
    static func format(_ key: String, _ arguments: CVarArg...) -> String {
        let format = string(key)
        return String(format: format, locale: Locale.current, arguments: arguments)
    }
}

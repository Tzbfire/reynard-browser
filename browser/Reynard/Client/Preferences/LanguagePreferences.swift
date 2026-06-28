//
//  LanguagePreferences.swift
//  Reynard
//
//  Created for Chinese language negotiation support.
//

import Foundation

enum LanguagePreferenceMode: String, CaseIterable {
    case followSystem
    case simplifiedChinese
    case traditionalChinese
    case english
    case custom
    
    var displayName: String {
        switch self {
        case .followSystem:
            return L10n.string("Follow System")
        case .simplifiedChinese:
            return L10n.string("Simplified Chinese")
        case .traditionalChinese:
            return L10n.string("Traditional Chinese")
        case .english:
            return L10n.string("English")
        case .custom:
            return L10n.string("Custom")
        }
    }
    
    var defaultLanguageTags: [String]? {
        switch self {
        case .followSystem:
            return nil
        case .simplifiedChinese:
            return ["zh-CN", "zh", "en-US", "en"]
        case .traditionalChinese:
            return ["zh-TW", "zh-Hant", "zh", "en-US", "en"]
        case .english:
            return ["en-US", "en"]
        case .custom:
            return nil
        }
    }
}

enum BrowserLanguagePreferences {
    static let simplifiedChineseAcceptLanguage = "zh-CN,zh;q=0.9,en-US;q=0.6,en;q=0.5"
    
    static var languageTags: [String] {
        switch Prefs.LanguageSettings.mode {
        case .custom:
            let customTags = normalizedLanguageTags(from: Prefs.LanguageSettings.customLanguageTags)
            if !customTags.isEmpty {
                return customTags
            }
            return normalizedLanguageTags(from: Locale.preferredLanguages)
        case .followSystem:
            return normalizedLanguageTags(from: Locale.preferredLanguages)
        case .simplifiedChinese, .traditionalChinese, .english:
            return Prefs.LanguageSettings.mode.defaultLanguageTags ?? normalizedLanguageTags(from: Locale.preferredLanguages)
        }
    }
    
    static var primaryLanguageTag: String {
        return languageTags.first ?? "en-US"
    }
    
    static var acceptLanguageHeader: String {
        return acceptLanguageHeader(from: languageTags)
    }
    
    static var geckoAcceptLanguages: String {
        return languageTags.joined(separator: ",")
    }
    
    static var geckoLocaleList: String {
        return languageTags.joined(separator: ",")
    }
    
    static var usesChineseLanguage: Bool {
        return languageTags.contains { $0.lowercased().hasPrefix("zh") }
    }
    
    static func normalizedLanguageTags(from rawValues: [String]) -> [String] {
        var result: [String] = []
        var seen: Set<String> = []
        
        for rawValue in rawValues {
            let normalized = rawValue
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "_", with: "-")
            guard !normalized.isEmpty else {
                continue
            }
            let key = normalized.lowercased()
            guard !seen.contains(key) else {
                continue
            }
            seen.insert(key)
            result.append(normalized)
        }
        
        return result
    }
    
    static func languageTags(from customValue: String) -> [String] {
        return normalizedLanguageTags(
            from: customValue
                .split { $0 == "," || $0 == ";" || $0 == "\n" || $0 == " " || $0 == "\t" }
                .map(String.init)
        )
    }
    
    private static func acceptLanguageHeader(from tags: [String]) -> String {
        let normalizedTags = normalizedLanguageTags(from: tags)
        guard !normalizedTags.isEmpty else {
            return "en-US,en;q=0.9"
        }
        
        return normalizedTags.enumerated().map { index, tag in
            guard index > 0 else {
                return tag
            }
            let quality = max(1.0 - (Double(index) * 0.1), 0.1)
            return String(format: "%@;q=%.1f", tag, quality)
        }.joined(separator: ",")
    }
}

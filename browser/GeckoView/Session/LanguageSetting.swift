//
//  LanguageSetting.swift
//  Reynard
//
//  Created by Minis on 29/6/26.
//

import Foundation

public struct LanguageSetting: Equatable {
    public static var `default`: LanguageSetting {
        return LanguageSetting(preferredLanguages: Locale.preferredLanguages)
    }
    
    public let acceptLanguages: String
    public let requestedLocales: String
    public let httpAcceptLanguage: String
    
    public init(preferredLanguages: [String]) {
        let tags = Self.languageTags(from: preferredLanguages)
        self.acceptLanguages = tags.joined(separator: ",")
        self.requestedLocales = tags.first ?? "en-US"
        self.httpAcceptLanguage = Self.httpAcceptLanguage(from: tags)
    }
    
    private static func languageTags(from preferredLanguages: [String]) -> [String] {
        var result: [String] = []
        
        for language in preferredLanguages {
            let normalized = normalize(language)
            guard !normalized.isEmpty else { continue }
            append(normalized, to: &result)
            
            if let baseLanguage = normalized.split(separator: "-").first.map(String.init),
               baseLanguage != normalized {
                append(baseLanguage, to: &result)
            }
        }
        
        append("en-US", to: &result)
        append("en", to: &result)
        return result
    }
    
    private static func normalize(_ language: String) -> String {
        let identifier = language
            .replacingOccurrences(of: "_", with: "-")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch identifier {
        case "zh-Hans", "zh-Hans-CN":
            return "zh-CN"
        case "zh-Hant", "zh-Hant-TW":
            return "zh-TW"
        case "zh-Hant-HK":
            return "zh-HK"
        default:
            return identifier
        }
    }
    
    private static func append(_ tag: String, to tags: inout [String]) {
        guard !tags.contains(where: { $0.caseInsensitiveCompare(tag) == .orderedSame }) else {
            return
        }
        tags.append(tag)
    }
    
    private static func httpAcceptLanguage(from tags: [String]) -> String {
        return tags.enumerated().map { index, tag in
            guard index > 0 else { return tag }
            let tenths = max(10 - index, 1)
            return "\(tag);q=0.\(tenths)"
        }.joined(separator: ", ")
    }
}

//
//  LanguagePreferencesViewController.swift
//  Reynard
//
//  Created for website language negotiation support.
//

import UIKit

final class LanguagePreferencesViewController: SettingsTableViewController {
    private enum Section: CaseIterable {
        case preferredLanguage
        case customLanguages
        
        var text: SettingsSectionText {
            switch self {
            case .preferredLanguage:
                return SettingsSectionText(
                    headerTitle: L10n.string("Preferred Website Language"),
                    footerTitle: L10n.string("This controls the Accept-Language header and Gecko locale list used by websites. It affects multilingual pages and navigator.language / navigator.languages.")
                )
            case .customLanguages:
                return SettingsSectionText(
                    headerTitle: L10n.string("Custom Language Tags"),
                    footerTitle: L10n.string("Enter BCP 47 language tags separated by commas, for example zh-CN,zh,en-US,en.")
                )
            }
        }
    }
    
    private enum Row: CaseIterable {
        case followSystem
        case simplifiedChinese
        case traditionalChinese
        case english
        case custom
        
        var mode: LanguagePreferenceMode {
            switch self {
            case .followSystem:
                return .followSystem
            case .simplifiedChinese:
                return .simplifiedChinese
            case .traditionalChinese:
                return .traditionalChinese
            case .english:
                return .english
            case .custom:
                return .custom
            }
        }
    }
    
    init() {
        super.init(style: .insetGrouped)
        title = L10n.string("Language")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard Section.allCases.indices.contains(section) else {
            return 0
        }
        
        switch Section.allCases[section] {
        case .preferredLanguage:
            return Row.allCases.count
        case .customLanguages:
            return 1
        }
    }
    
    override func sectionText(for section: Int) -> SettingsSectionText {
        guard Section.allCases.indices.contains(section) else {
            return SettingsSectionText()
        }
        return Section.allCases[section].text
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard Section.allCases.indices.contains(indexPath.section) else {
            return UITableViewCell()
        }
        
        switch Section.allCases[indexPath.section] {
        case .preferredLanguage:
            guard Row.allCases.indices.contains(indexPath.row) else {
                return UITableViewCell()
            }
            let row = Row.allCases[indexPath.row]
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.textLabel?.text = row.mode.displayName
            cell.detailTextLabel?.text = detailText(for: row.mode)
            cell.detailTextLabel?.textColor = .secondaryLabel
            cell.accessoryType = Prefs.LanguageSettings.mode == row.mode ? .checkmark : .none
            return cell
        case .customLanguages:
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            cell.textLabel?.text = L10n.string("Language Tags")
            cell.detailTextLabel?.text = customLanguageTagsDisplayValue
            cell.detailTextLabel?.textColor = .secondaryLabel
            cell.accessoryType = .disclosureIndicator
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        guard Section.allCases.indices.contains(indexPath.section) else {
            return
        }
        
        switch Section.allCases[indexPath.section] {
        case .preferredLanguage:
            guard Row.allCases.indices.contains(indexPath.row) else {
                return
            }
            Prefs.LanguageSettings.mode = Row.allCases[indexPath.row].mode
            tableView.reloadData()
        case .customLanguages:
            presentCustomLanguageEditor()
        }
    }
    
    private var customLanguageTagsDisplayValue: String {
        let value = Prefs.LanguageSettings.customLanguageTags
        return value.isEmpty ? L10n.string("Not Set") : value
    }
    
    private func detailText(for mode: LanguagePreferenceMode) -> String? {
        switch mode {
        case .followSystem:
            return BrowserLanguagePreferences.normalizedLanguageTags(from: Locale.preferredLanguages).joined(separator: ",")
        case .simplifiedChinese, .traditionalChinese, .english:
            return mode.defaultLanguageTags?.joined(separator: ",")
        case .custom:
            return customLanguageTagsDisplayValue
        }
    }
    
    private func presentCustomLanguageEditor() {
        let alert = UIAlertController(
            title: L10n.string("Custom Language Tags"),
            message: L10n.string("Enter BCP 47 language tags separated by commas, for example zh-CN,zh,en-US,en."),
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "zh-CN,zh,en-US,en"
            textField.text = Prefs.LanguageSettings.customLanguageTags
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: L10n.string("Cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.string("Save"), style: .default) { [weak self, weak alert] _ in
            let value = alert?.textFields?.first?.text ?? ""
            Prefs.LanguageSettings.customLanguageTags = value
            Prefs.LanguageSettings.mode = .custom
            self?.tableView.reloadData()
        })
        present(alert, animated: true)
    }
}

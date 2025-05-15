import Foundation

class SettingsManager {
    static let shared = SettingsManager()
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let apiUrl = "apiUrl"
        static let refreshInterval = "refreshInterval"
    }
    
    var apiUrl: String {
        get {
            return userDefaults.string(forKey: Keys.apiUrl) ?? "http://tednewardsandbox.site44.com/questions.json"
        }
        set {
            userDefaults.set(newValue, forKey: Keys.apiUrl)
        }
    }
    
    var refreshInterval: Int {
        get {
            return userDefaults.integer(forKey: Keys.refreshInterval)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.refreshInterval)
        }
    }
    
    func resetToDefaults() {
        apiUrl = "http://tednewardsandbox.site44.com/questions.json"
        refreshInterval = 0
    }
} 
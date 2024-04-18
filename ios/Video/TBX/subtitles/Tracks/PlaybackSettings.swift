import Foundation

let KEY_SUBTITLE_LANGUAGE_DISABLED = "disabled"//.stringLocalized()

/// Stores user's playback preferences, such as prefered audio and subtitle languages.
///
/// The preferred language format is: two characters, lowercased.
///
/// For example, the spanish language format is: 'es'
class PlaybackSettings {
    
    // MARK: - Keys
    static private var KEY_AUDIO_LANGUAGE: String = "playback_settings_audio_language"
    static private var KEY_SUBTITLE_LANGUAGE: String = "playback_settings_subtitle_language"
    
    static var audioLanguagePreference: String? {
        get {
            #if DEBUG
            print("PLAYBACK SETTINGS: CURRENT AUDIO PREFERENCE: \(String(describing: UserDefaults.standard.value(forKey: KEY_AUDIO_LANGUAGE)))")
            #endif
            return UserDefaults.standard.value(forKey: KEY_AUDIO_LANGUAGE) as? String
        }
        set {
            let newValueNormalized = newValue != nil ? normalizeLanguage(newValue!) : newValue
            #if DEBUG
            print("PLAYBACK SETTINGS: NEW AUDIO PREFERENCE: \(String(describing: newValueNormalized))")
            #endif
            UserDefaults.standard.setValue(
                newValueNormalized,
                forKey: KEY_AUDIO_LANGUAGE)
        }
    }
    
    static var subtitleLanguagePreference: String? {
        get {
            #if DEBUG
            print("PLAYBACK SETTINGS: CURRENT SUBTITLE PREFERENCE: \(String(describing: UserDefaults.standard.value(forKey: KEY_SUBTITLE_LANGUAGE)))")
            #endif
            return UserDefaults.standard.value(forKey: KEY_SUBTITLE_LANGUAGE) as? String
        }
        set {
            let newValueNormalized = newValue != nil ? normalizeLanguage(newValue!) : newValue
            #if DEBUG
            print("PLAYBACK SETTINGS: NEW SUBTITLE PREFERENCE: \(String(describing: newValueNormalized))")
            #endif
            UserDefaults.standard.setValue(
                newValueNormalized,
                forKey: KEY_SUBTITLE_LANGUAGE)
        }
    }
    
    static func checkIfLanguageTagsMatch(forLanguage language: String, currentMediaLanguage: String) -> Bool {
        let languageNormalized = normalizeLanguage(language)
        let currentMediaLanguageNormalized = normalizeLanguage(currentMediaLanguage)
        
        #if DEBUG
        print("PLAYBACK SETTINGS: CHECK IF LANGUAGE TAGS MATCH:")
        print("LANGUAGE: \(languageNormalized)")
        print("CURRENT MEDIA LANGUAGE :\(currentMediaLanguageNormalized)")
        #endif
        
        return currentMediaLanguageNormalized.caseInsensitiveCompare(languageNormalized) == .orderedSame
    }
    
    /// Workaround to unify different media language formats. The language format is retrieved from inside
    /// the media manifests, so it can't be configured from the backend :(.
    static func normalizeLanguage(_ currentMediaLanguage: String) -> String {
        
        switch currentMediaLanguage {
            
        case "ES", "spa":
            return "es"
        case "EN", "eng":
            return "en"
        case "PT", "por":
            return "pt"
        default:
            return currentMediaLanguage
        }
    }
    
    static func isSubtitlesDisabled() -> Bool {
        if let subtitleLanguagePreference = self.subtitleLanguagePreference, subtitleLanguagePreference == KEY_SUBTITLE_LANGUAGE_DISABLED {
            return true
        } else {
            return false
        }
    }
    
    static func setSubtitlesDisabled() {
        self.subtitleLanguagePreference = "disabled"
    }
    
    static var isRadioModeEnabled = false
    /// Determines if the user prefers 'both audio and video' or 'audio only' for content reproduction.
    static var isRadioModeOn = false

}

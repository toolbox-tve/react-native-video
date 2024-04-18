import UIKit
import AVKit
import Foundation


protocol SubtitlesManagerDelegate: AnyObject {
    func updateSubtitles(text: String, position: Int)
}

private let kSubtitlesTimerUpdateFrecuency = Double(0.25)

/// Handles the logic to manage external subtitles.
class PlayerExternalSubtitlesManager {
    
    // MARK: Vars.    
    private var subtitleTimer: Timer?
    var subtitles: [Subtitlable]
    private var currentSubtitle: Subtitlable?
    
    /// We keep a weak reference to the player to access the current time. With the current time, we can get the appropiate subtitle's text for that time.
    weak var player: AVPlayer?
    
    private weak var delegate: SubtitlesManagerDelegate?
    
    // MARK: Init.
    
    init(subtitles: [Subtitlable], delegate: SubtitlesManagerDelegate, player: AVPlayer?) {
        self.subtitles = subtitles
        self.delegate = delegate
        self.player = player
    }
    
    // MARK: - Subtitles Management Logic.
    
    func startDisplayingSubtitles() {
        
        if currentSubtitle == nil {
            currentSubtitle = getDefaultSubtitles()
        }
        
        PlaybackSettings.subtitleLanguagePreference = currentSubtitle?.subtitleLanguage
        
        currentSubtitle?.loadSubtitles(completionBlockSuccess: {
            // Start timer.
            let when = DispatchTime.now()
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.subtitleTimer = Timer.scheduledTimer(
                    timeInterval: kSubtitlesTimerUpdateFrecuency,
                    target: self,
                    selector: #selector(self.subtitlesTimerUpdated),
                    userInfo: nil,
                    repeats: true
                )
            }
        }) {
            // Handle error.
        }
    }
    
    func stopDisplayingSubtitles() {
        self.subtitleTimer?.invalidate()
    }
    
    @objc
    func subtitlesTimerUpdated() {
        // Get current time.
        guard let currentItem = self.player?.currentItem else {
            return
        }
        
        // Get subtitles text for current time.
        let position = Int(currentItem.currentTime().seconds)
        
        if let subtitlesText = currentSubtitle?.getSubtitleTextForPosition(position: position), let linePosition = currentSubtitle?.getLineForSubtitleTextForPosition(position: position) {

            // Tell the player that the new subtitles text is available.
            self.delegate?.updateSubtitles(text: subtitlesText, position: linePosition)
        }
    }
    
    #if os(tvOS)
    /// Get the subtitles in the language preferred by the user. If no preference is set, get the default subtitles.
    private func getSubtitlesBasedOnPlaybackSettings() -> Subtitlable {
        if let langPreference = PlaybackSettings.subtitleLanguagePreference {
            for subtitle in subtitles {
                if PlaybackSettings.checkIfLanguageTagsMatch(
                    forLanguage: subtitle.subtitleLanguage,
                    currentMediaLanguage: langPreference) {
                    return subtitle
                }
            }
        }
        
        return getDefaultSubtitles()
    }
    #endif
    
    private func getDefaultSubtitles() -> Subtitlable {
        for subtitle in subtitles {
            if subtitle.isDefault {
                return subtitle
            }
        }
        return subtitles.first!
    }
    
    func getSubtitlesOptions() -> [PlaybackSetting] {
        return subtitles.map {
            #if DEBUG
            print("SUBTITLES - EXTERNAL - LANGUAGE: \(String(describing: $0.textTrackData?.srclang))")
            #endif
            return PlaybackSetting(
                displayName: $0.textTrackData?.label ?? "",
                language: $0.textTrackData?.srclang ?? "")
        }
    }
    
    #if os(tvOS)
    func getSubtitlesOffOption() -> PlaybackSetting {
        return PlaybackSetting(
            displayName: "Desactivados",
            language: KEY_SUBTITLE_LANGUAGE_DISABLED)
    }
    
    func getCurrentSubtitleOption() -> PlaybackSetting {
        if PlaybackSettings.isSubtitlesDisabled() {
            return getSubtitlesOffOption()
        }

        if let _currentSubtitle = currentSubtitle {
            return PlaybackSetting(
                displayName: _currentSubtitle.textTrackData?.label ?? "",
                language: _currentSubtitle.textTrackData?.srclang ?? "")
        }
        
        return getSubtitlesOffOption()
    }
    #endif
    
    // MARK: - Subtitles Label Configuration.
    
    func configureSubtitlesLabelForEmptyState(subtitlesLabel: UILabel?) {
        subtitlesLabel?.backgroundColor = UIColor.clear
    }
    
    func configureSubtitlesLabelForNormalState(subtitlesLabel: UILabel?) {
        subtitlesLabel?.backgroundColor = UIColor.clear
    }
    
    func switchSubtitles(toLanguage language: String?) {
        stopDisplayingSubtitles()
        
        if let lang = language {
            PlaybackSettings.subtitleLanguagePreference = lang
            
            currentSubtitle = subtitles.filter {
                $0.textTrackData!.srclang == language
            }.first

        } else {
            PlaybackSettings.subtitleLanguagePreference = KEY_SUBTITLE_LANGUAGE_DISABLED
        }
        
        startDisplayingSubtitles()
    }
    
    /// Determines if the menu button to display the subtitles options should be visible or not.
    func shouldDisplaySubtitlesButton() -> Bool {
        if let _ = currentSubtitle {
            return true
        } else {
            return false
        }
    }
    
    /// Determines if the subtitles should be visible or not.
    func shouldDisplaySubtitles() -> Bool {
        if let subtitleLanguagePreference = PlaybackSettings.subtitleLanguagePreference {
            if subtitleLanguagePreference == KEY_SUBTITLE_LANGUAGE_DISABLED {
                return false
            } else {
                return true
            }
            
        } else if let isDefault = currentSubtitle?.isDefault {
            return isDefault
        } else {
            return false
        }
    }
    
    func updateSubtitles(subtitles: [Subtitlable]) {
        stopDisplayingSubtitles()
        
        currentSubtitle = nil
        self.subtitles = subtitles
    }
}

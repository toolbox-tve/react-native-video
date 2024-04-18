//
//  Subtitle.swift
//  TBXPlayer
//
//  Created by Toolbox Digital S.A on 27/11/17.
//  Copyright © 2017 Gaston Montes. All rights reserved.
//

import Foundation

/// Defines a common behaviour that every subtitle class must conform to.
protocol Subtitlable {
    
    var subtitleData: VttParse? { get set }
    var subtitleLanguage: String { get set }
    var textTrackData: TextTrackData? { get set }
    var isDefault: Bool { get set }
    
    func loadSubtitles(completionBlockSuccess:(()-> Void)?, completionBlockFail:(()-> Void)?)
    func getSubtitleTextForPosition(position: Int) -> String
    func getLineForSubtitleTextForPosition(position: Int) -> Int
}

/// Subtitle class for .vtt subtitles.
class Subtitle {
    
    fileprivate var subtitlesPath: String
    internal var subtitleData: VttParse?
    var subtitleLanguage: String
    var textTrackData: TextTrackData?
    var isDefault: Bool
    
    init(subtitlesJSON: JSON) {
        subtitlesPath = subtitlesJSON["src"].stringValue
        subtitleLanguage = subtitlesJSON["srclang"].stringValue
        textTrackData = TextTrackData(
            src: subtitlesJSON["src"].stringValue,
            label: subtitlesJSON["label"].stringValue,
            srclang: subtitlesJSON["srclang"].stringValue)
        isDefault = subtitlesJSON["default"].bool ?? false
    }
    
    init(track: TrackDTO) {
        subtitlesPath = track.src
        subtitleLanguage = track.srcLang
        textTrackData = TextTrackData(
            src: track.src,
            label: track.label,
            srclang: track.srcLang)
        isDefault = track.isDefault ?? false
    }
}

public struct TrackDTO {
    var src: String
    var srcLang: String
    var label: String
    var isDefault: Bool?
    var contentType: String
    
    init(src: String, srcLang: String, label: String, isDefault: Bool?, contentType: String) {
        self.src = src
        self.srcLang = srcLang
        self.label = label
        self.isDefault = isDefault
        self.contentType = contentType
    }
}

extension Subtitle: Subtitlable {
    
    func loadSubtitles(completionBlockSuccess:(()-> Void)?, completionBlockFail:(()-> Void)?) {
        
        guard let subtitlesURL = URL(string: self.subtitlesPath) else {
            completionBlockFail?()
            return
        }
        
        let configRequest = URLSessionConfiguration.default
        let mainSession = URLSession(configuration: configRequest, delegate: nil, delegateQueue: OperationQueue.main)
        let mainTask = mainSession.dataTask(with: subtitlesURL) { (data, response, error) in
            if let data = data, let utf8Text = String(data: data, encoding: .utf8) {
                self.subtitleData = VttParse(utf8Text: utf8Text)
                completionBlockSuccess?()
            } else {
                completionBlockFail?()
            }
        }
        mainTask.resume()
    }
    
    func getSubtitleTextForPosition(position: Int) -> String {
        let text = subtitleData?.getLabelForPosition(position: Int64(position))?.getText() ?? ""
        return text
    }
    
    func getLineForSubtitleTextForPosition(position: Int) -> Int {
        let line = subtitleData?.getLabelForPosition(position: Int64(position))?.getPosition() ?? 85
        return line
    }
}

/// Defines a common behaviour that every trickplay class must conform to.
protocol Trickplay {
    
    var trickplayData: VttTrickplayParse? { get set }
    
    func loadThumbnails(completionBlockSuccess:(()-> Void)?, completionBlockFail:(()-> Void)?)
    func getThumbnailForPosition(position: Int64, completionBlockSuccess:((UIImage)-> Void)?, completionBlockFail:(()-> Void)?)
}

/// Trickplay class for filmstrip.
class TrickplayFilmstrip {
    
    fileprivate var filmstripPath: String
    internal var trickplayData: VttTrickplayParse?
    
    init(filmstripPath: String) {
        self.filmstripPath = filmstripPath
    }
    
    func getBaseImageURL(fromFilmstripURL filmstripURL: URL) -> String {
        return filmstripPath.stringByDeletingLastPathComponent
    }
}

extension TrickplayFilmstrip: Trickplay {
    
    func loadThumbnails(completionBlockSuccess:(()-> Void)?, completionBlockFail:(()-> Void)?) {
        
        guard let filmstripURL = URL(string: self.filmstripPath) else {
            completionBlockFail?()
            return
        }
        
        let configRequest = URLSessionConfiguration.default
        let mainSession = URLSession(configuration: configRequest, delegate: nil, delegateQueue: OperationQueue.main)
        let mainTask = mainSession.dataTask(with: filmstripURL) { (data, response, error) in
            if let data = data, let utf8Text = String(data: data, encoding: .utf8) {
                
                self.trickplayData = VttTrickplayParse(
                    utf8Text: utf8Text,
                    baseImageURL: self.getBaseImageURL(fromFilmstripURL: filmstripURL)
                )
                completionBlockSuccess?()
            } else {
                completionBlockFail?()
            }
        }
        mainTask.resume()
    }
    
    func getThumbnailForPosition(position: Int64, completionBlockSuccess:((UIImage)-> Void)?, completionBlockFail:(()-> Void)?) {
        self.trickplayData?.getThumbnailForPosition(
            position: position,
            completionBlockSuccess: completionBlockSuccess,
            completionBlockFail: completionBlockFail
        )
    }
}

extension String {
    
    //MARK: - Variables
    var htmlToAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSMutableAttributedString(
                data: data,
                options: [
                    .documentType: NSMutableAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
    }
    
    var stringByDeletingLastPathComponent: String {
        get {
            return (self as NSString).deletingLastPathComponent
        }
    }
}

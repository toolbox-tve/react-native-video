//
//  VttParse.swift
//  webvtt
//
//  Created by Ignacio Marenco on 19/07/17.
//  Copyright © 2017 Ignacio Marenco. All rights reserved.
//

import UIKit
import AVFoundation

class VttParse {
    
    var items = [VttItem]()
    var totalLines = [String]()
    
    init(utf8Text: String) {
        let lines = utf8Text.components(separatedBy: .newlines)
        
        totalLines = lines
        
        for i in 0 ..< lines.count {
            if lines[i].contains("-->") {
                self.getInstanceForLine(time: lines[i], str: self.getCompleteText(index: (i + 1) , lines: lines))
            }
        }
    }
    
    ///get the text full for Subtitle Item
    func getCompleteText(index: Int, lines: [String]) -> String {
        var result :String = ""
        
        for i in index ..< lines.count {
            let textLine = lines[i]
            
            if(!textLine.contains("-->") && !textLine.isEmpty && !textLine.isInt){
                result += " "+lines[i]
            }
            else if(textLine.contains("-->")){
                break
            }
        }
        return result
    }
    
    func getLabelForPosition(position :Int64) -> VttItem? {
        var result:VttItem? = nil
        
        for i in 0 ..< items.count {
            if position >= items[i].getStart() && position <= items[i].getEnd() {
                result = items[i]
                break
            }
        }

        return result
    
    }
    
    func replace(input:String, string:String, replacement:String) -> String {
        return input.replacingOccurrences(of: string, with: replacement)
    }
    
    func getTime(str: String) -> Int64 {
        let timeComponents = str.components(separatedBy: ":")
        
        if (timeComponents.count == 3) {
            return parseExpectedTimeFormat(timeComponents: timeComponents)
        } else if (timeComponents.count == 2) {
            return parseAlternativeTimeFormat(timeComponents: timeComponents)
        } else {
            return 0
        }
    }
    
    /// Parses expected time format: [HR:MIN:SEC] - e.g: 00:00:38.505
    func parseExpectedTimeFormat(timeComponents: [String]) -> Int64 {
        let hours: Int64 = self.getHourSeconds(time: timeComponents[0])
        let minutes: Int64 = self.getMinuteSecond(time: timeComponents[1])
        let seconds: Int64 = self.getSeconds(time: timeComponents[2])
        
        return hours + minutes + seconds
    }
    
    /// Parses alternative time format: [MIN:SEC] - e.g: 00:38.505
    func parseAlternativeTimeFormat(timeComponents: [String]) -> Int64 {
        let minutes: Int64 = self.getMinuteSecond(time: timeComponents[0])
        var seconds: Int64!
        if timeComponents[1].range(of: ".") != nil {
            seconds = self.getSeconds(time: timeComponents[1].components(separatedBy: ".").first!)
        } else {
            seconds = self.getSeconds(time: timeComponents[1])
        }
        
        return minutes + seconds
    }
    
    func getHourSeconds(time: String) -> Int64 {
        let hour = Int64(time)!
        
        return hour * 60 * 60
    }
    
    func getMinuteSecond(time:String)-> Int64 {
        let minutes = Int64(time)!
        
        return minutes * 60
    }
    
    func getSeconds(time: String) -> Int64 {
        let normalizedTimeString = self.replace(input: time, string: "-", replacement: "")
        return Int64(normalizedTimeString) ?? .zero
    }
    
    func removeTagFromString(text: String) -> String {
        return text
            .substring(fromIndex: 1)
            .replacingOccurrences(of: "-",
                                  with: "\n-",
                                  options: .caseInsensitive,
                                  range: nil)
            .replacingOccurrences(of: "<[^>]+>",
                                  with: "",
                                  options: .regularExpression,
                                  range: nil)
    }
    
    private func parseStringTime(time: String) -> String {
        let index = time.index(time.startIndex, offsetBy: 8)
        
        let normalizedTimeString = self.replace(input: time, string: " ", replacement: "")
        
        return String(normalizedTimeString[..<index])
    }
    
    func getLinePercentage(times: [String]) -> Int {
        var line = 0
        for i in times {
            if i.substring(toIndex: 4).lowercased() == "line" {
                if let number = Int.parse(from: i) {
                    line = number
                }
            }
        }
        return line
    }

    private func getInstanceForLine(time: String, str: String) {
        let times : [String] = time.components(separatedBy: "-->")
        let times2: [String] = time.components(separatedBy: " ")
        let start = self.getTime(str: self.parseStringTime(time: times[0]))
        let end = self.getTime(str: self.parseStringTime(time: times[1]))
        let position = self.getLinePercentage(times: times2)
        items.append(VttItem(text: removeTagFromString(text: str), start: start, end: end, position: position))
        return
    }
}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
    
    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)), upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}

extension Int {
    static func parse(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}

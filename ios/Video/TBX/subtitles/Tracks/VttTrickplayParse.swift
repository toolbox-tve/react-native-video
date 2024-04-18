//
//  VttTrickplayParse.swift
//  Expirience
//
//  Created by Toolbox Digital S.A on 10/4/18.
//  Copyright © 2018 Toolbox Development. All rights reserved.
//

import UIKit

class VttTrickplayParse {
    
    var items = [VttTrickplayItem]()
    var totalLines = [String]()
    var baseImageURL: String
    
    init( utf8Text :String, baseImageURL: String) {
        
        let lines = utf8Text.components(separatedBy: .newlines)
        totalLines = lines
        
        self.baseImageURL = baseImageURL
        
        for i in 0 ..< lines.count {
            if lines[i].contains("-->") {
                self.getInstanceForLine(time: lines[i], str: self.getCompleteText(index: (i + 1) , lines: lines))
            }
        }
    }
    
    func getCompleteText(index:Int, lines:[String]) -> String {
        var result :String = ""
        
        for i in index ..< lines.count {
            if lines[i].isEmpty && !result.isEmpty {
                break
            }else {
                result = result + " " + lines[i]
            }
        }
        
        return result
    }
    
    func getThumbnailForPosition(position: Int64, completionBlockSuccess:((UIImage)-> Void)?, completionBlockFail:(()-> Void)?) {
        
        for i in 0 ..< items.count {
            if position >= items[i].getStart() && position <= items[i].getEnd() {
                let result: VttTrickplayItem = items[i]
                result.getThumbnailImage(completionBlockSuccess: { thumbnailImage in
                    completionBlockSuccess?(thumbnailImage)
                }, completionBlockFail: {
                    completionBlockFail?()
                })
            }
        }
        
        completionBlockFail?()
    }
    
    func replace(input:String, string:String, replacement:String) -> String {
        return input.replacingOccurrences(of: string, with:replacement)
    }
    
    func getTime(str:String) -> Int64 {
        let time = str.components(separatedBy: ":")
        if(time.count != 3){
            return 0
        }
        
        let hours :Int64 = self.getHourSeconds(time: time[0])
        let minutes :Int64 = self.getMinuteSecond(time: time[1])
        let seconds :Int64 = self.getSeconds(time: time[2])
        
        return hours + minutes + seconds;
    }
    
    func getHourSeconds(time:String)-> Int64{
        let hour = Int64(time)!
        
        return hour * 60 * 60
    }
    
    func getMinuteSecond(time:String)-> Int64 {
        let minutes = Int64(time)!
        
        return minutes * 60
    }
    
    func getSeconds(time:String) -> Int64{
        return Int64(time)!
    }
    
    func removeTagFromString(text: String) -> String{
        return text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    func parseStringTime(time :String ) -> String {
        let index = time.index(time.startIndex, offsetBy: 8)
        return String(self.replace(input: time, string: " ", replacement: "")[..<index])
    }
    
    func getInstanceForLine(time :String, str:String) {
        let times : [String] = time.components(separatedBy: "-->")
        let start = self.getTime(str: self.parseStringTime(time: times[0]))
        let end = self.getTime(str: self.parseStringTime(time: times[1]))
        items.append(VttTrickplayItem(text: removeTagFromString(text:str), start: start, end: end, baseImageURL: self.baseImageURL))
        return
    }
}

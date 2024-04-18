//
//  VttItem.swift
//  webvtt
//
//  Created by Ignacio Marenco on 20/07/17.
//  Copyright © 2017 Ignacio Marenco. All rights reserved.
//

import UIKit

class VttItem {
    private var start: Int64
    private  var end: Int64
    private var text: String
    private var position: Int
    
    init(text:String, start: Int64, end:Int64, position: Int) {
        self.start = start
        self.end = end
        self.text = text
        self.position = position
    }
    
    func getStart() -> Int64 {
        return start
    }
    
    func getEnd() -> Int64 {
        return end
    }
    
    func getText() -> String {
        return text
    }
    
    func getPosition() -> Int {
        return position
    }
    
}

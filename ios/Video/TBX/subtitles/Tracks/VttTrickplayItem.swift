//
//  VttTrickplayItem.swift
//  Expirience
//
//  Created by Toolbox Digital S.A on 10/4/18.
//  Copyright © 2018 Toolbox Development. All rights reserved.
//

import UIKit

struct ThumbnailData {
    var fullImageURL: String
    var thumbnailRect: CGRect
}

class VttTrickplayItem {
    private var start: Int64
    private var end: Int64
    private var text: String
    
    var fullImageURL: String?
    var xPosition: Int?
    var yPosition: Int?
    var width: Int?
    var height: Int?
    
    init(text:String, start: Int64, end:Int64, baseImageURL: String) {
        self.start = start
        self.end = end
        self.text = text
        
        let stringArray = text.components(separatedBy: "#")
        let imagePath = stringArray[0]
        
        self.fullImageURL = "\(baseImageURL)/\(imagePath.replacingOccurrences(of: " ", with: ""))"
        
        let imageSizeString = stringArray[1]
        let imageSizeStringArray = imageSizeString.components(separatedBy: ",")
        
        let xStringArray = imageSizeStringArray[0].components(separatedBy: "=")
        let xString = xStringArray[1]
        self.xPosition = Int(xString)
        
        self.yPosition = Int(imageSizeStringArray[1])
        self.width = Int(imageSizeStringArray[2])
        self.height = Int(imageSizeStringArray[3])
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
    
    func getThumbnailImage(completionBlockSuccess:((UIImage)-> Void)?, completionBlockFail:(()-> Void)?) {
        UIImage.imageFromWeb(imageURL: self.fullImageURL!, completionBlockSuccess: { fullImage in
            let thumbnailRect: CGRect = CGRect(
                x: self.xPosition!,
                y: self.yPosition!,
                width: self.width!,
                height: self.height!
            )
            if let thumbnailImage = fullImage.imageByCroppingToRect(rect: thumbnailRect) {
                completionBlockSuccess?(thumbnailImage)
            } else {
                completionBlockFail?()
            }
        }) {
            completionBlockFail?()
        }
    }
    
    func getThumbnailData() -> ThumbnailData {
        let thumbnailRect: CGRect = CGRect(
            x: self.xPosition!,
            y: self.yPosition!,
            width: self.width!,
            height: self.height!
        )
        return ThumbnailData(fullImageURL: self.fullImageURL!, thumbnailRect: thumbnailRect)
    }
}

extension UIImage {
    
    static func imageFromWeb(imageURL: String, completionBlockSuccess:((UIImage)-> Void)?, completionBlockFail:(()-> Void)?) {
        
        if let imaURL: URL = URL(string: imageURL) {
            
            let configRequest = URLSessionConfiguration.default
            let mainSession = URLSession(configuration: configRequest, delegate: nil, delegateQueue: OperationQueue.main)
            let mainTask = mainSession.dataTask(with: imaURL, completionHandler: { (data, response, error) -> Void in
                
                if error != nil {
                    // Error loading image.
                    completionBlockFail?()
                }
                
                if data != nil {
                    DispatchQueue.main.async(execute: { () -> Void in
                        let img = UIImage.init(data: data!)!
                        completionBlockSuccess?(img)
                    })
                }else{
                    // Error loading image.
                    completionBlockFail?()
                }
            })
            mainTask.resume()
            
        } else{
            // Error loading image.
            completionBlockFail?()
        }
    }
    
    class func imageDot(size: Float, color: UIColor) -> UIImage {
        let sizeFloat = CGFloat(size)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: sizeFloat, height: sizeFloat), false, 0)

        let graphicsContext = UIGraphicsGetCurrentContext()!
        graphicsContext.saveGState()

        let dotRect = CGRect(x: 0, y: 0, width: sizeFloat, height: sizeFloat)
        graphicsContext.setFillColor(color.cgColor)
        graphicsContext.fillEllipse(in: dotRect)

        graphicsContext.restoreGState()
        
        let dotImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        
        return dotImage
    }
    
    func imageByCroppingToRect(rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, CGFloat(1))
        self.draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        return result
    }

}

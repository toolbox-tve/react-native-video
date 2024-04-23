//
//  tbxResolver.swift
//  react-native-video
//
//  Created by David on 07/01/2023.
//

import Foundation
import Promises

public class TbxResolver: ResolverStrategyProtocol {
    public var resolverName: String = "tbx"
    
    public func canResolve(_ network: String, _ provider: String) -> Bool {
        // Default resolver for content encoded by toolbox
        return true
    }
    
    public func createLicenseRequest(licenseServer: String, spcData: Data?, contentId: String, headers: [String : Any]?) -> URLRequest {
        var assetKID: String = contentId.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        var completeLicenseURL = "\(licenseServer)&assetId=\(assetKID)"
        
        var request = URLRequest(url: URL(string: completeLicenseURL)!)
        request.httpMethod = "POST"
        
        if let headers = headers {
            for item in headers {
                guard let key = item.key as? String, let value = item.value as? String else {
                    continue
                }
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        request.httpBody = spcData!
        
        print(request.cURL(pretty: true))
        return request
    }
    
    public func fetchLicense(licenseServer: String, spcData: Data?, contentId: String, headers: [String : Any]?, options: [String : Any]?) -> Promises.Promise<Data> {
        let request = createLicenseRequest(licenseServer:licenseServer, spcData:spcData, contentId:contentId, headers:headers)

        return Promise<Data>(on: .global()) { fulfill, reject in
            let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler:{ (data:Data!,response:URLResponse!,error:Error!) in
                
                let httpResponse:HTTPURLResponse! = (response as! HTTPURLResponse)

                guard error == nil else {
                    print("Error getting license from \(licenseServer), HTTP status code \(httpResponse.statusCode)")
                    reject(error)
                    return
                }
                guard httpResponse.statusCode == 200 else {
                    print("Error getting license from \(licenseServer), HTTP status code \(httpResponse.statusCode)")
                    reject(RCTVideoErrorHandler.licenseRequestNotOk(httpResponse.statusCode))
                    return
                }
                
                fulfill(data)
            })
            postDataTask.resume()
        }
    }
    
    
}


//
//  HboResolver.swift
//  react-native-video
//
//  Created by Kevin Gracia on 8/3/23.
//

import Foundation

public class HBOResolver: DRMResolverStrategyProtocol {
    public var resolverName: String = "hbo"
    
    public func canResolve(_ network: String, _ provider: String) -> Bool {
        let canResolve = provider.caseInsensitiveCompare(self.resolverName) == .orderedSame

        return canResolve
    }
    
    public func createLicenseRequest(licenseServer: String, spcData: Data?, contentId: String, headers: [String : Any]?) -> URLRequest {
        
        let url = URL(string: licenseServer)
        var xmlRequest = URLRequest(url: url!)
        
        xmlRequest.httpMethod = "POST"
        
        if let headers = headers {
            for item in headers {
                guard let key = item.key as? String, let value = item.value as? String else {
                    continue
                }
                xmlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        xmlRequest.httpBody = getXMLSPCAsString(spcData: spcData!).data(using: .utf8)
        
        //print(xmlRequest.cURL(pretty: true))
        return xmlRequest
    }
    
    public func fetchLicense(licenseServer: String, spcData: Data?, contentId: String, headers: [String : Any]?, options: [String : Any]?) async throws -> Data{
        let countryID = options!["countryID"] as! String
        let operatorID = options!["operatorID"] as! String
        let paseoToken = options!["paseoToken"] as! String
        let hboHeader = getCustomHeaderBase64(paseoToken, contentId, operatorID, countryID)
        let hboHeaders = headers?.merging(["dt-custom-data": hboHeader], uniquingKeysWith: {(first, _) in first})
        
        let request = createLicenseRequest(licenseServer:licenseServer, spcData:spcData, contentId:contentId, headers:hboHeaders)
        
        return Data()
        
        /*return Promise<Data>(on: .global()) { fulfill, reject in
            let postDataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler:{ (data:Data!,response:URLResponse!,error:Error!) in
                
                let httpResponse:HTTPURLResponse! = (response as! HTTPURLResponse)

                guard error == nil else {
                    print("[ERROR][TBXPlayer/fetchLicense] >>> Error getting license from \(licenseServer), HTTP status code \(httpResponse.statusCode)")
                    reject(error)
                    return
                }
                guard httpResponse.statusCode == 200 else {
                    print("[[ERROR]TBXPlayer/fetchLicense] >>> Error getting license from \(licenseServer), HTTP status code \(httpResponse.statusCode)")
                    reject(RCTVideoErrorHandler.licenseRequestNotOk(httpResponse.statusCode))
                    return
                }
                
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonDict = json as? [String: Any] else {
                    print("[[ERROR]TBXPlayer/fetchLicense] >>> Can't convert json response yo Dict")
                    let error = NSError(domain: "HboResolver", code: 0, userInfo: [NSLocalizedDescriptionKey : "Can't process license response to JSON dict"])
                    reject(error)
                    return
                }
               
                let license64 = jsonDict["License"] as! String
                let ckcData = Data(base64Encoded: license64)
                fulfill(ckcData!)
            })
            postDataTask.resume()
        }*/
    }
    
    //MARK: Private Methods:
    
    func getCustomHeaderBase64(_ paseoToken: String,_ skd: String, _ operatorID: String, _ countryID: String) -> String {
        let headerPayload: String = "tokenID=\(paseoToken)|skd://\(skd)|operatorID=\(operatorID)|countryID=\(countryID)"
        return headerPayload
    }
    
    func getXMLSPCAsString(spcData: Data) -> String {
        let stringParams: String = "<LicenseRequest xmlns=\"go:v6:interop\">" +
                                            "<PlaybackCtx><![CDATA[" +
                                                "\(spcData.base64EncodedString())" +
                                            "]]></PlaybackCtx>" +
                                        "</LicenseRequest>"
        return stringParams
    }
    
}



extension URL {
    
    func getUrlParamsAsDictionary() -> [String: String] {
        var queryParams = [String: String]()
        
        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return queryParams }
        
        if let queryItems = urlComponents.queryItems {
            for queryItem: URLQueryItem in queryItems {
                if queryItem.value == nil {
                    continue
                }
                queryParams[queryItem.name] = queryItem.value
            }
        }
        
        return queryParams
    }
}


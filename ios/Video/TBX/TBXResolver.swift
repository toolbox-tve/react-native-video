//
//  tbxResolver.swift
//  react-native-video
//
//  Created by David on 07/01/2023.
//

import Foundation
import Promises

public class TBXResolver: DRMResolverStrategyProtocol {
    public var resolverName: String = "tbx"
    
    public func canResolve(_ network: String, _ provider: String) -> Bool {
        // Default resolver for content encoded by toolbox
        return true
    }
    
    public func createLicenseRequest(licenseServer: String, spcData: Data?, contentId: String, headers: [String : Any]?) -> URLRequest {
        let assetKID: String = contentId.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let completeLicenseURL : String = "\(licenseServer)&assetId=\(assetKID)"

        var request = URLRequest(url: URL(string: completeLicenseURL)!)
        request.httpMethod = "POST"

        if let headers {
            for item in headers {
                guard let key = item.key as? String, let value = item.value as? String else {
                    continue
                }
                request.setValue(value, forHTTPHeaderField: key)
            }
        }

        request.httpBody = spcData!
        return request
    }
    
    public func fetchLicense(licenseServer: String, spcData: Data?, contentId: String, headers: [String : Any]?, options: [String : Any]?) -> Promises.Promise<Data> {
      let request = createLicenseRequest(licenseServer: licenseServer, spcData: spcData, contentId: contentId, headers: headers)

      let (data, response) = try await URLSession.shared.data(from: request)
 
      return data;
    }
}


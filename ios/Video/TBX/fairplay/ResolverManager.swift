//
//  ResolverManager.swift
//  react-native-video
//
//  Created by David on 09/01/2023.
//

import Foundation
import Promises

class ResolverManager {
    static var instance = ResolverManager()
    private let resolvers: [ResolverStrategyProtocol] = [
        HboResolver()
    ]
    
    func fetchLicense(licenseServer: String, spcData: Data?, contentId: String, headers: [String : Any]?, options: [String: Any]?) -> Promises.Promise<Data> {
        let network = options!["network"] as! String
        let provider = options!["provider"] as! String
        let strategy = resolvers.filter { $0.canResolve(network, provider) }.first ?? TbxResolver()
        
        print("[TBPlayer/FAIRPLAY]] >>>> USE \(strategy.resolverName) RESOLVER.")
        
        return strategy.fetchLicense(licenseServer: licenseServer, spcData: spcData, contentId: contentId, headers: headers, options: options)
    }
}

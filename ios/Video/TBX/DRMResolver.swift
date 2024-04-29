//
//  ResolverManager.swift
//  react-native-video
//
//  Created by David on 09/01/2023.
//

import Foundation

class DRMResolver {
    static var instance = DRMResolver()

    private let resolvers: [DRMResolverStrategyProtocol] = [
      HBOResolver()
    ]
    
    func fetchLicense(licenseServer: String, spcData: Data?, contentId: String, headers: [String : Any]?, options: [String: Any]?) async throws -> Data {
      let network = options!["network"] as! String
      let provider = options!["provider"] as! String
      let strategy = resolvers.filter { $0.canResolve(network, provider) }.first ?? TBXResolver()
      
      print("[TBPlayer/FAIRPLAY]] >>>> USE \(strategy.resolverName) RESOLVER.")
      
      return try await strategy.fetchLicense(licenseServer: licenseServer, spcData: spcData, contentId: contentId, headers: headers, options: options)
    }
}

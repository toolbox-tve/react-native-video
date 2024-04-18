//
//  ResolverStrategyProtocol.swift
//  react-native-video
//
//  Created by David on 07/01/2023.
//

import Foundation
import Promises

public protocol ResolverStrategyProtocol {
    var resolverName: String { get }
    
    ///Return if this content resolve specific strategy
    ///- Parameters:
    ///- Return:
    func canResolve(_ network: String, _ provider: String) -> Bool
    
    /// Create custom url request with license url
    ///- Return: URLRequest
    func createLicenseRequest(
        licenseServer: String,
        spcData: Data?,
        contentId: String,
        headers: [String:Any]?
    ) -> URLRequest
    
    ///Return fetching license promise for resolver
    ///- Return: Promise<Data>
    func fetchLicense(
        licenseServer: String,
        spcData: Data?,
        contentId: String,
        headers: [String:Any]?,
        options: [String:Any]?
    ) -> Promise<Data>
}

//
//  Auth.swift
//  Auth
//
//  Created by SkyRim on 2020/3/27.
//  Copyright © 2020 SkyRim. All rights reserved.
//

import Foundation

// 接口类
public class Auth {
    static let defaultAuth: Auth = Auth()
    let storage: Storage
    
    init(storage: Storage = StorageImpl()) {
        self.storage = storage
    }
    
    func auth(fullUrl: String) -> Bool {
        let apiReq = ApiRequest(fullUrl: fullUrl)
        return auth(apiRequest: apiReq)
    }
    
    func auth(apiRequest: ApiRequest) -> Bool {
        let currentTime = CFAbsoluteTimeGetCurrent()
        guard currentTime < apiRequest.expiredTime else {
            return false
        }
        
        guard let pwd = storage.getPassword(with: apiRequest.appID) else {
            return false
        }
        
        let clientToken = AuthToken(token: apiRequest.token, expiredTime: apiRequest.expiredTime)
        let svrToken = AuthToken(baseUrl: apiRequest.baseUrl, appID: apiRequest.appID, password: pwd, expiredTime: apiRequest.expiredTime)
        
        return svrToken.isMatch(to: clientToken)
    }
}

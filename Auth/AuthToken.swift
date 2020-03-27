//
//  AuthToken.swift
//  Auth
//
//  Created by SkyRim on 2020/3/27.
//  Copyright © 2020 SkyRim. All rights reserved.
//

import Foundation

public class AuthToken {
    let token: String
    private let expiredTime: TimeInterval
    
    init(baseUrl: String, appID: Int, password: String, expiredTime: TimeInterval) {
        let fullUrl = baseUrl + String(appID) + password + String(expiredTime)
        token = fullUrl.md5()
        self.expiredTime = expiredTime
    }
    
    init(token: String, expiredTime: TimeInterval) {
        self.token = token
        self.expiredTime = expiredTime
    }
    
    func isExpired() -> Bool {
        let currentTime = CFAbsoluteTimeGetCurrent();
        return currentTime > expiredTime
    }
    
    func isMatch(to token: AuthToken) -> Bool {
        return self.token == token.token
    }
}

/// encrypt
extension String {
    func md5() -> String {
        return self;//假装进行了md5
    }
}

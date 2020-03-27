//
//  ApiRequest.swift
//  Auth
//
//  Created by SkyRim on 2020/3/27.
//  Copyright © 2020 SkyRim. All rights reserved.
//

import Foundation

public class ApiRequest {
    let baseUrl: String
    let token: String
    let appID: Int
    let expiredTime: TimeInterval
    
    let fullUrl: String
    
    init(baseUrl: String, token: String, appID: Int, expiredTime: TimeInterval) {
        self.baseUrl = baseUrl
        self.token = token
        self.appID = appID
        self.expiredTime = expiredTime
        
        //拼接query
        self.fullUrl = baseUrl + "?" + "token:" + token + "&" + "appID:" + String(appID) + "&" + "expiredTime:" + String(expiredTime)
    }
    
    init(fullUrl: String) {
        self.fullUrl = fullUrl
        //解析省略
        self.baseUrl = ""
        self.token = ""
        self.appID = 0
        self.expiredTime = 0
    }
}

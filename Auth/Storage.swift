//
//  Storage.swift
//  Auth
//
//  Created by SkyRim on 2020/3/27.
//  Copyright © 2020 SkyRim. All rights reserved.
//

import Foundation

protocol Storage {
    func getPassword(with appID: Int) -> String?
}

public class StorageImpl : Storage {
    func getPassword(with appID: Int) -> String? {//省略实现
        return nil
    }
}

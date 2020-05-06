//
//  StockDetailModel.swift
//  AngelBroking_IOSTest
//
//  Created by Amsys on 17/02/20.
//  Copyright © 2020 SivaKumarAketi. All rights reserved.
//

import Foundation

struct StockModel {
    let ok : Bool?
    let users : [StockDetailModel]?

    enum CodingKeys: String, CodingKey {

        case ok = "ok"
        case users = "users"
    }
}

class StockDetailModel {
    var avatar_url: String?
    var display_name: String?
    var username: String?
    var id: Int?
}

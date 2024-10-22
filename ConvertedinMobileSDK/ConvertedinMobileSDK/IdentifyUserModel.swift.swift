//
//  identifyUserModel.swift
//  
//
//  Created by Eslam Ali  on 19/09/2023.
//

import Foundation


struct identifyUserModel: Codable {
    let cid: String?
    let  csid: String?
    let is_anonymous: Bool?
}


struct eventModel: Codable {
    let msg: String?
}

struct saveTokenModel: Codable {
    let message: String?
}


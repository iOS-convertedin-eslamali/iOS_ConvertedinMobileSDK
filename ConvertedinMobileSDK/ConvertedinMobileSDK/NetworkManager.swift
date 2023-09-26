//
//  NetworkManager.swift
//  
//
//  Created by Eslam Ali  on 19/09/2023.
//

import Foundation


class NetworkManager {
    
    static let shared  = NetworkManager()
    
    enum requestType: String {
        case identify = "identity"
        case event = "events"
        case saveToken = "deviceTokens/save"
        case deleteToken = "deviceTokens/delete"
        case refreshToken = "deviceTokens/refresh"
    }
    
    func PostAPI(pixelId: String?, storeUrl: String?, parameters: [String: Any], type: requestType, compeletion: @escaping (Data?) -> Void){
        guard let pixelId else {return}
        guard let storeUrl else {return}
        var url = ""
        switch type {
        case .identify, .event:
            url = String(format: "https://app.converted.in/api/v1/\(pixelId)/\(type.rawValue)")
        case .saveToken, .deleteToken, .refreshToken:
            url = String(format: "https://app.convertedin.com/api/webhooks/push-notification/\(pixelId)/\(type.rawValue)")
        }
        guard let serviceUrl = URL(string: url) else { return }

        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue(storeUrl, forHTTPHeaderField: "Referer")
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Application/json", forHTTPHeaderField: "Accept")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        
        request.httpBody = httpBody
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {return}
            guard  let data = data else {return}
            compeletion(data)
        }.resume()
    }
}

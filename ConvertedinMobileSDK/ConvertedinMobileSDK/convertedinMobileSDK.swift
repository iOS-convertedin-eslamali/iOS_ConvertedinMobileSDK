// Convertedin Mobile SDK

public protocol convertedinManager {
    func identifyUser(email: String?, countryCode: String?, phone: String?)
    func saveDeviceToken(token: String)
    func deleteDeviceToken()
    func refreshDeviceToken(newToken: String)
    func addEvent<T>(eventName: String, currency: String ,total: Int ,products: [T]) where T : Codable
    func viewContentEvent<T>(currency: String ,total: Int ,products: [T]) where T : Codable
    func pageViewEvent<T>(currency: String ,total: Int ,products: [T]) where T : Codable
    func addToCartEvent<T>(currency: String ,total: Int ,products: [T]) where T : Codable
    func initiateCheckoutEvent<T>(currency: String ,total: Int ,products: [T]) where T : Codable
    func purchaseEvent<T>(currency: String ,total: Int ,products: [T]) where T : Codable
}

import Foundation
public class convertedinMobileSDK: convertedinManager {
    
    //MARK:- Variables
    
    public static let manager : convertedinManager = convertedinMobileSDK(pixelId: nil, storeUrl: nil)
    
    private var pixelId : String?
    private var storeUrl : String?
    private var cid: String?
    private var cuid: String?
    
    public enum eventType: String {
        case purchase = "Purchase"
        case checkout = "InitiateCheckout"
        case addToCart = "AddToCart"
        case viewPage = "PageView"
        case viewContent = "ViewContent"
    }
    
    public struct ProductModel: Codable {
        let id: Int?
        let quantity: Int?
        let name: String?
    }
    
    //MARK:- Initlizers
    public init(pixelId: String?, storeUrl: String?) {
        self.pixelId = pixelId
        self.storeUrl = storeUrl
    }
    
    //MARK:- Functions
    public func identifyUser(email: String?, countryCode: String?, phone: String?){
        guard let pixelId else {return}
        guard let storeUrl else {return}
        
        var parameterDictionary = ["csid": "deviceToken" ]
        if let email = email {
            parameterDictionary["email"] = email
        }
        
        if let countryCode = countryCode, let phone = phone {
            parameterDictionary["country_code"] = countryCode
            parameterDictionary["phone"] = phone
        }
        
        NetworkManager.shared.PostAPI(pixelId: pixelId, storeUrl: storeUrl, parameters: parameterDictionary, type: .identify) { data in
            guard  let data = data else {return}
            do {
                let identifyUserModel: identifyUserModel  = try CustomDecoder.decode(data: data)
                print(identifyUserModel)
                self.cid = identifyUserModel.cid
                self.cuid = identifyUserModel.csid
                
            } catch {
                print(error)
            }
        }
    }
    
    
    public func saveDeviceToken(token: String) {
        guard let pixelId else {return}
        guard let storeUrl else {return}
        guard let cid else {return}
        
        let parameterDictionary:  [String: Any] = [
            "customer_id" : cid,
            "device_token": token,
            "token_type" : "iOS",
        ]
        
        NetworkManager.shared.PostAPI(pixelId: pixelId, storeUrl: storeUrl, parameters: parameterDictionary, type: .saveToken) { data in
            guard  let data = data else {return}
            do {
                let eventModel: saveTokenModel  = try CustomDecoder.decode(data: data)
                print(eventModel.message ?? "")
                UserDefaults.standard.setValue(token, forKey: "current_device_token")
            } catch {
                print(error)
            }
        }
    }
    
    public func deleteDeviceToken() {
        guard let token  = UserDefaults.standard.string(forKey: "current_device_token") else {return}
        guard let pixelId else {return}
        guard let storeUrl else {return}
        
        let parameterDictionary:  [String: Any] = [
            "device_token": token,
            "token_type" : "iOS",
        ]
        
        NetworkManager.shared.PostAPI(pixelId: pixelId, storeUrl: storeUrl, parameters: parameterDictionary, type: .deleteToken) { data in
            guard  let data = data else {return}
            do {
                let eventModel: saveTokenModel  = try CustomDecoder.decode(data: data)
                print(eventModel.message ?? "")
                UserDefaults.standard.setValue(token, forKey: "current_device_token")
            } catch {
                print(error)
            }
        }
    }
    
    public func refreshDeviceToken(newToken: String){
        deleteDeviceToken()
        guard let pixelId else {return}
        guard let storeUrl else {return}
        let oldToken = UserDefaults.standard.string(forKey: "current_device_token") ?? ""
        
        let parameterDictionary:  [String: Any] = [
            
            "device_token": oldToken,
            "token_type" : "iOS",
            "new_device_token": newToken,
            "new_token_type" : "iOS",
        ]
        
        NetworkManager.shared.PostAPI(pixelId: pixelId, storeUrl: storeUrl, parameters: parameterDictionary, type: .refreshToken) { data in
            guard  let data = data else {return}
            do {
                let eventModel: saveTokenModel  = try CustomDecoder.decode(data: data)
                print(eventModel.message ?? "")
                UserDefaults.standard.setValue(newToken, forKey: "current_device_token")
            } catch {
                print(error)
            }
        }
    }
    
    //MARK:- Events
    public func addEvent<T>(eventName: String, currency: String ,total: Int ,products: [T]) where T : Codable {
        guard let pixelId else {return}
        guard let storeUrl else {return}
        guard let cuid else {return}
        
        var parameterDictionary:  [String: Any] = [:]
        
        let encoder = JSONEncoder()
        do {
            let result = try encoder.encode(products)
            let productsModelArray: [ProductModel]  = try CustomDecoder.decode(data: result)
            
            parameterDictionary = [
                "event" : eventName,
                "cuid": cuid,
                "data" : [
                    "currency" : currency,
                    "value": total,
                ] as [String : Any]
            ]
            
            productsModelArray.enumerated().forEach { (item) in
                let service = item.element
                let index = item.offset
                guard let id = service.id  else {return}
                guard let name = service.name  else {return}
                guard let quantity = service.quantity  else {return}
                parameterDictionary["data[content][\(index)][name]"] = name
                parameterDictionary["data[content][\(index)][id]"] = id
                parameterDictionary["data[content][\(index)][quantity]"] = quantity
            }
        } catch {
            print(error)
        }
        
        NetworkManager.shared.PostAPI(pixelId: pixelId, storeUrl: storeUrl, parameters: parameterDictionary, type: .event) { data in
            guard  let data = data else {return}
            do {
                let eventModel: eventModel  = try CustomDecoder.decode(data: data)
                print(eventModel.msg ?? "")
                
            } catch {
                print(error)
            }
        }
    }
    
    public func viewContentEvent<T>(currency: String ,total: Int ,products: [T]) where T : Codable {
        addEvent(eventName: eventType.viewContent.rawValue , currency: currency, total: total, products: products)
    }
    
    public func pageViewEvent<T>(currency: String ,total: Int ,products: [T]) where T : Codable {
        addEvent(eventName: eventType.viewPage.rawValue , currency: currency, total: total, products: products)
    }
    
    public func addToCartEvent<T>(currency: String ,total: Int ,products: [T]) where T : Codable {
        addEvent(eventName: eventType.addToCart.rawValue , currency: currency, total: total, products: products)
    }
    
    public func initiateCheckoutEvent<T>(currency: String ,total: Int ,products: [T]) where T : Codable {
        addEvent(eventName: eventType.checkout.rawValue , currency: currency, total: total, products: products)
    }
    
    public func purchaseEvent<T>(currency: String ,total: Int ,products: [T]) where T : Codable {
        addEvent(eventName: eventType.purchase.rawValue , currency: currency, total: total, products: products)
    }
    
}

// Convertedin Mobile SDK

import Foundation
public class ConvertedinMobileSDK {
    
    //MARK:- Variables
    static var shared = ConvertedinMobileSDK()
    
    static var pixelId : String?
    static var storeUrl : String?
    static var deviceToken: String?
    static var cid: String? {
        didSet {
            guard let token  = deviceToken, !token.isEmpty else {return}
            saveDeviceToken(token: token)
        }
    }
    static var cuid: String?
    
    public enum eventType: String {
        case purchase = "Purchase"
        case checkout = "InitiateCheckout"
        case addToCart = "AddToCart"
        case viewPage = "PageView"
        case viewContent = "ViewContent"
    }
    
    public struct ConvertedinProduct: Codable {
        let id: Int?
        let quantity: Int?
        let name: String?
        
        
       public init(id: Int?, quantity: Int?, name: String?) {
            self.id = id
            self.quantity = quantity
            self.name = name
        }
    }
    
    //MARK:- Initlizers
    
    public static func configure(pixelId: String?, storeUrl: String?) {
        self.pixelId = pixelId
        self.storeUrl = storeUrl
        identifyUser(email: nil, countryCode: nil, phone: nil)
    }
    
    //MARK:- Functions
    public static func identifyUser(email: String?, countryCode: String?, phone: String?){
        guard let pixelId else {return}
        guard let storeUrl else {return}
        guard let deviceToken = deviceToken else {return}
        
        var parameterDictionary: [String : Any] = [ : ]
       
        if let csid = self.cuid {
            parameterDictionary["csid"] = csid
        }
        
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
    
    public static func setFcmToken(token: String) {
        self.deviceToken = token
    }
    
    public static func saveDeviceToken(token: String) {
        guard let pixelId else {return}
        guard let storeUrl else {return}
        guard let cid, !cid.isEmpty else {return}
        
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
    
    public static func deleteDeviceToken() {
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
    
    public static func refreshDeviceToken(newToken: String){
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
    public static func addEvent(eventName: String, currency: String ,total: Int ,products: [ConvertedinProduct]) {
        guard let pixelId else {return}
        guard let storeUrl else {return}
        guard let cuid else {return}
        
        var parameterDictionary:  [String: Any] = [:]

        
            parameterDictionary = [
                "event" : eventName,
                "cuid": cuid,
                "data" : [
                    "currency" : currency,
                    "value": total,
                ] as [String : Any]
            ]
            
        products.enumerated().forEach { (item) in
                let service = item.element
                let index = item.offset
                guard let id = service.id  else {return}
                guard let name = service.name  else {return}
                guard let quantity = service.quantity  else {return}
                parameterDictionary["data[content][\(index)][name]"] = name
                parameterDictionary["data[content][\(index)][id]"] = id
                parameterDictionary["data[content][\(index)][quantity]"] = quantity
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
    
    public static func viewContentEvent(currency: String ,total: Int ,products: [ConvertedinProduct]) {
        addEvent(eventName: eventType.viewContent.rawValue , currency: currency, total: total, products: products)
    }
    
    public static func pageViewEvent(currency: String ,total: Int ,products: [ConvertedinProduct]) {
        addEvent(eventName: eventType.viewPage.rawValue , currency: currency, total: total, products: products)
    }
    
    public static func addToCartEvent(currency: String ,total: Int ,products: [ConvertedinProduct]) {
        addEvent(eventName: eventType.addToCart.rawValue , currency: currency, total: total, products: products)
    }
    
    public static func initiateCheckoutEvent(currency: String ,total: Int ,products: [ConvertedinProduct]) {
        addEvent(eventName: eventType.checkout.rawValue , currency: currency, total: total, products: products)
    }
    
    public static func purchaseEvent(currency: String ,total: Int ,products: [ConvertedinProduct]) {
        addEvent(eventName: eventType.purchase.rawValue , currency: currency, total: total, products: products)
    }
    
}

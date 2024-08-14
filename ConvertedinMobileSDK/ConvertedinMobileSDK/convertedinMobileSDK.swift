// Convertedin Mobile SDK

import Foundation
public class ConvertedinMobileSDK {
    
    //MARK:- Variables
    static var shared = ConvertedinMobileSDK()
    
    static var pixelId : String?
    static var storeUrl : String?
    static var deviceToken: String?
    static private var isLoggedin: Bool = false
    static private var isFirstTimeOpenApp: Bool = true
    static var cid: String? {
        didSet {
            guard UserDefaults.standard.string(forKey: "ConvertedinMobileSDK_cid") == nil else { return }
            saveCidLoccally(cid: cid)
        }
    }
    
    static var cuid: String? {
        didSet {
            guard let token  = deviceToken, !token.isEmpty else {return}
            saveDeviceToken(token: token)
            guard UserDefaults.standard.string(forKey: "ConvertedinMobileSDK_csid") == nil else { return }
            saveCsidLoccally(csid: cuid)
        }
    }
    
    public enum eventType: String {
        case purchase = "Purchase"
        case checkout = "InitiateCheckout"
        case addToCart = "AddToCart"
        case viewPage = "PageView"
        case viewContent = "ViewContent"
        case register = "Register"
        case appOpen = "OpenApp"
        case clickOnPush = "ClickOnPush"
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
    }
    
    //MARK:- Functions
    public static func identifyUser(email: String?, countryCode: String?, phone: String?){
        guard let pixelId else {return}
        guard let storeUrl else {return}
        
        var parameterDictionary: [String : Any] = [ "src": "push" ]
        
        if let storedCsid = UserDefaults.standard.string(forKey: "ConvertedinMobileSDK_csid") {
            parameterDictionary["csid"] = storedCsid
        }
        
        if let storedCid = UserDefaults.standard.string(forKey: "ConvertedinMobileSDK_cid") {
            parameterDictionary["anonymous_cid"] = storedCid
        }
        
        if let email = email {
            self.isLoggedin = true
            parameterDictionary["email"] = email
        }
        
        if let countryCode = countryCode{
            self.isLoggedin = true
            parameterDictionary["country_code"] = countryCode
           
        }
        
        if let phone = phone {
            self.isLoggedin = true
            parameterDictionary["phone"] = phone
        }
        
        NetworkManager.shared.PostAPI(pixelId: pixelId, storeUrl: storeUrl, parameters: parameterDictionary, type: .identify) { data in
            guard  let data = data else {return}
            do {
                let identifyUserModel: identifyUserModel  = try CustomDecoder.decode(data: data)
                print(identifyUserModel)
                self.cid = identifyUserModel.cid
                self.cuid = identifyUserModel.csid
                if isLoggedin {
                    saveCidLoccally(cid: identifyUserModel.cid)
                    saveCsidLoccally(csid: identifyUserModel.csid)
                }
            } catch {
                print(error)
            }
        }
    }
    
    public static func setFcmToken(token: String) {
        self.deviceToken = token
        identifyUser(email: nil, countryCode: nil, phone: nil)
        appOpen()
    }
    
    private static func saveCidLoccally(cid: String?) {
        guard let cid = cid, !cid.isEmpty else { return }
        UserDefaults.standard.setValue(cid, forKey: "ConvertedinMobileSDK_cid")
    }
    
    private static func saveCampaignIdLoccally(campaignId: String?) {
        guard let campaignId = campaignId, !campaignId.isEmpty else { return }
        UserDefaults.standard.setValue(campaignId, forKey: "ConvertedinMobileSDK_campaignId")
    }
        
    private static func saveCsidLoccally(csid: String?) {
        guard let csid = csid, !csid.isEmpty else { return }
        UserDefaults.standard.setValue(csid, forKey: "ConvertedinMobileSDK_csid")
    }
    
    public static func saveDeviceToken(token: String) {
        guard let pixelId else {return}
        guard let storeUrl else {return}
        guard let cuid, !cuid.isEmpty else {return}
        
        let parameterDictionary:  [String: Any] = [
            "customer_id" : cuid,
            "device_token": token,
            "token_type" : "iOS",
        ]
        
        NetworkManager.shared.PostAPI(pixelId: pixelId, storeUrl: storeUrl, parameters: parameterDictionary, type: .saveToken) { data in
            guard  let data = data else {return}
            do {
                let eventModel: saveTokenModel  = try CustomDecoder.decode(data: data)
                print(eventModel.message ?? "Empty Message ")
                
                UserDefaults.standard.setValue(token, forKey: "ConvertedinMobileSDK_token")
            } catch {
                print(error)
            }
        }
    }
    
    public static func deleteDeviceToken() {
        guard let token  = UserDefaults.standard.string(forKey: "ConvertedinMobileSDK_token") else {return}
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
                UserDefaults.standard.setValue(token, forKey: "ConvertedinMobileSDK_token")
            } catch {
                print(error)
            }
        }
    }
    
    public static func refreshDeviceToken(newToken: String){
        deleteDeviceToken()
        guard let pixelId else {return}
        guard let storeUrl else {return}
        let oldToken = UserDefaults.standard.string(forKey: "ConvertedinMobileSDK_token") ?? ""
        
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
                UserDefaults.standard.setValue(newToken, forKey: "ConvertedinMobileSDK_token")
            } catch {
                print(error)
            }
        }
    }
    
    //MARK:- Events
    public static func addEvent(eventName: String, currency: String ,total: Int ,products: [ConvertedinProduct]) {
        guard let pixelId else {return}
        guard let storeUrl else {return}
        
        var parameterDictionary:  [String: Any] = [:]
        
        
        parameterDictionary = [
            "event" : eventName,
            "data" : [
                "currency" : currency,
                "value": total,
            ] as [String : Any]
        ]
        
        if let cuid = UserDefaults.standard.string(forKey: "ConvertedinMobileSDK_csid") {
            parameterDictionary["cuid"] = cuid
            parameterDictionary["cid"] = cuid
        }
        
        if let campaignId = UserDefaults.standard.string(forKey: "ConvertedinMobileSDK_campaignId") {
            parameterDictionary["ca"] = campaignId
        }
        
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
    
    public static func onPushNotificationClicked(campaignId: String) {
        ClickOnPush(campaignId: campaignId)
    }
    
    private static func ClickOnPush(campaignId: String) {
        saveCampaignIdLoccally(campaignId: campaignId)
        addEvent(eventName: eventType.clickOnPush.rawValue , currency: "", total: 0, products: [])
    }
    
        
    public static func appOpen() {
        addEvent(eventName: eventType.appOpen.rawValue , currency: "", total: 0, products: [])
    }
      

    public static func registerEvent() {
        addEvent(eventName: eventType.register.rawValue , currency: "", total: 0, products: [])
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

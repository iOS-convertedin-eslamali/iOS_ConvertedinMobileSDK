// Convertedin Mobile SDK

import Foundation
public class ConvertedinMobileSDK {
    
    // MARK: - Variables
    static var shared = ConvertedinMobileSDK()
    static var pixelId : String?
    static var storeUrl : String?
    static var deviceToken: String?
    static var deviceTokenSaved: Bool = false
    typealias EventParameters = [String: Any]
 
    // --- cid & csid
    static var cid: String? {
        didSet {
            saveCidLoccally(cid: cid)
        }
    }
    
    static var csid: String? {
        didSet {
            saveCsidLoccally(csid: csid)
            if let token  = deviceToken, !token.isEmpty {
                saveDeviceToken(token: token)
                
            }
        }
    }
    
    static var isAnonymous: Bool? {
        didSet {
            guard let isAnonymous else { return }
            saveIsAnonymousLoccally(isAnonymous: isAnonymous)
        }
    }
    
    public enum EventType: String {
        case purchase = "Purchase"
        case checkout = "InitiateCheckout"
        case addToCart = "AddToCart"
        case viewPage = "PageView"
        case viewContent = "ViewContent"
        case register = "Register"
        case appOpen = "OpenApp"
        case clickOnPush = "ClickOnPush"
//        case login = "Login"
    }
    
    public enum AuthenticationType {
        case login
        case register
    }
    
    // --- Product Model ---
    public struct ConvertedinProduct: Codable {
        let id: Int
        let quantity: Int
        let name: String?
        
        
        public init(id: Int, quantity: Int, name: String?) {
            self.id = id
            self.quantity = quantity
            self.name = name
        }
    }
    
    // MARK: - Configuration
    public static func configure(pixelId: String?, storeUrl: String?) {
        self.pixelId = pixelId
        self.storeUrl = storeUrl
    }
    
    // MARK: - Private Functions
    private static func saveCidLoccally(cid: String?) {
        guard let cid = cid, !cid.isEmpty else { return }
        UserDefaults.standard.setValue(cid, forKey: "ConvertedinMobileSDK_cid")
    }
    
    private static func saveIsAnonymousLoccally(isAnonymous: Bool) {
        UserDefaults.standard.setValue(isAnonymous, forKey: "ConvertedinMobileSDK_isAnonymous")
    }
    
    private static func saveCampaignIdLoccally(campaignId: String?) {
        guard let campaignId = campaignId, !campaignId.isEmpty else { return }
        UserDefaults.standard.setValue(campaignId, forKey: "ConvertedinMobileSDK_campaignId")
    }
    
    private static func saveCsidLoccally(csid: String?) {
        guard let csid = csid, !csid.isEmpty else { return }
        UserDefaults.standard.setValue(csid, forKey: "ConvertedinMobileSDK_csid")
    }
    
    // Add product details to parameters
    private static func addProductData(_ parameters: inout EventParameters, products: [ConvertedinProduct]) {
        guard !products.isEmpty else { return }
        
        let productData = products.enumerated().compactMap { (index, product) -> EventParameters? in
            var productDict: EventParameters = [
                "id": product.id,
                "quantity": product.quantity
            ]
            if let name = product.name {
                productDict["name"] = name
            }
            return ["data[content][\(index)]": productDict]
        }
        
        productData.forEach { parameters.merge($0) { (_, new) in new } }
    }
    
    private static func generateCuid() -> String {
        if let cuid = UserDefaults.standard.string(forKey: "ConvertedinMobileSDK_cuid") {
            return cuid
        } else {
            let cuid = UUID().uuidString
            UserDefaults.standard.setValue(cuid, forKey: "ConvertedinMobileSDK_cuid")
            return cuid
        }
    }
    
    // MARK: - Public Functions
    public static func setFcmToken(token: String) {
        self.deviceToken = token
        identifyUser(email: nil, countryCode: nil, phone: nil)
        appOpen()
    }
    
    @available(*, deprecated, message: "This function will be deprecated in a future version.")
    public static func identifyUser(email: String?, countryCode: String?, phone: String?, authType: AuthenticationType? = nil){
        guard let pixelId else {return}
        guard let storeUrl else {return}
        
        var parameterDictionary: [String : Any] = [
            "src": "push",
            "cuid" : generateCuid()
        ]
        
        if let storedCsid = UserDefaults.standard.string(forKey: "ConvertedinMobileSDK_csid") {
            parameterDictionary["csid"] = storedCsid
        }
        
        if let storedCid = UserDefaults.standard.string(forKey: "ConvertedinMobileSDK_cid") {
            parameterDictionary["anonymous_cid"] = storedCid
        }
        
        if let email = email {
            parameterDictionary["email"] = email
        }
        
        if let countryCode = countryCode{
            parameterDictionary["country_code"] = countryCode
        }
        
        if let phone = phone {
            parameterDictionary["phone"] = phone
        }
            
        NetworkManager.shared.PostAPI(pixelId: pixelId, storeUrl: storeUrl, parameters: parameterDictionary, type: .identify) { data in
            guard  let data = data else {return}
            do {
                let identifyUserModel: identifyUserModel  = try CustomDecoder.decode(data: data)
                self.cid = identifyUserModel.cid
                self.csid = identifyUserModel.csid
                self.isAnonymous = identifyUserModel.is_anonymous
                
                if authType == .register {
                    registerEvent()
                }
            } catch {
                print(error)
            }
        }
    }
    
    public static func login(email: String) {
        identifyUser(email: email, countryCode: nil, phone: nil, authType: .login)
    }
    
    public static func login(phone: String, countryCode: String?) {
        identifyUser(email: nil, countryCode: countryCode, phone: phone, authType: .login)
    }
     
    public static func register(email: String) {
        identifyUser(email: email, countryCode: nil, phone: nil, authType: .register)
    }
    
    public static func register(phone: String, countryCode: String?) {
        identifyUser(email: nil, countryCode: countryCode, phone: phone, authType: .register)
    }
    
    public static func setUserData(phone: String, countryCode: String?) {
        guard UserDefaults.standard.bool(forKey: "ConvertedinMobileSDK_isAnonymous") == true else { return }
        identifyUser(email: nil, countryCode: countryCode, phone: phone)
    }
    
    public static func setUserData(email: String) {
        guard UserDefaults.standard.bool(forKey: "ConvertedinMobileSDK_isAnonymous") == true else { return }
        identifyUser(email: email, countryCode: nil, phone: nil)
    }
    
    public static func saveDeviceToken(token: String) {
        guard deviceTokenSaved == false else { return }
        guard let pixelId else {return}
        guard let storeUrl else {return}
        guard let csid, !csid.isEmpty else {return}
        
        let parameterDictionary:  EventParameters = [
            "customer_id" : csid,
            "device_token": token,
            "token_type" : "iOS",
            "cuid" : generateCuid()
        ]
        
        NetworkManager.shared.PostAPI(pixelId: pixelId, storeUrl: storeUrl, parameters: parameterDictionary, type: .saveToken) { data in
            guard  let data = data else {return}
            do {
                let eventModel: saveTokenModel  = try CustomDecoder.decode(data: data)
                UserDefaults.standard.setValue(token, forKey: "ConvertedinMobileSDK_token")
                deviceTokenSaved = true
                print(eventModel.message ?? "")
            } catch {
                print(error)
            }
        }
    }
    
    public static func deleteDeviceToken() {
        guard let token  = UserDefaults.standard.string(forKey: "ConvertedinMobileSDK_token") else {return}
        guard let pixelId else {return}
        guard let storeUrl else {return}
        
        let parameterDictionary:  EventParameters = [
            "device_token": token,
            "token_type" : "iOS",
        ]
        
        NetworkManager.shared.PostAPI(pixelId: pixelId, storeUrl: storeUrl, parameters: parameterDictionary, type: .deleteToken) { data in
            guard  let data = data else {return}
            do {
                let eventModel: saveTokenModel  = try CustomDecoder.decode(data: data)
                print(eventModel.message ?? "")
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
        
        let parameterDictionary:  EventParameters = [
            
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
    public static func addEvent(eventName: String, orderId: String? = nil, currency: String ,total: String ,products: [ConvertedinProduct]) {
        guard let pixelId else {return}
        guard let storeUrl else {return}
        
        var parameterDictionary:  EventParameters = [ "event" : eventName ]
        let eventType = EventType(rawValue: eventName)
        
        switch eventType {
        case .viewPage, .appOpen, .clickOnPush, .register:
            break // No additional data needed for these events
        case .purchase:
            guard let orderId = orderId, !currency.isEmpty, !total.isEmpty else { return }
            parameterDictionary["data"] = [
                "currency": currency,
                "value": total,
                "order_id": orderId ]
            addProductData(&parameterDictionary, products: products)
        default:
            guard !currency.isEmpty, !total.isEmpty else { return }
            parameterDictionary["data"] = [
                "currency": currency,
                "value": total
            ]
            addProductData(&parameterDictionary, products: products)
        }
        
        // --- Optional Paramters ---
        if let cid = UserDefaults.standard.string(forKey: "ConvertedinMobileSDK_cid") {
            parameterDictionary["cid"] = cid
        }
        
        if let campaignId = UserDefaults.standard.string(forKey: "ConvertedinMobileSDK_campaignId") {
            parameterDictionary["ca"] = campaignId
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
        addEvent(eventName: EventType.clickOnPush.rawValue , currency: "", total: "", products: [])
    }
    
    public static func appOpen() {
        addEvent(eventName: EventType.appOpen.rawValue , currency: "", total: "", products: [])
    }
    
    private static func registerEvent() {
        addEvent(eventName: EventType.register.rawValue , currency: "", total: "", products: [])
    }

    public static func viewContentEvent(currency: String ,total: String ,products: [ConvertedinProduct]) {
        addEvent(eventName: EventType.viewContent.rawValue , currency: currency, total: total, products: products)
    }
    
    public static func pageViewEvent() {
        addEvent(eventName: EventType.viewPage.rawValue , currency: "", total: "", products: [])
    }
    
    public static func addToCartEvent(currency: String ,total: String ,products: [ConvertedinProduct]) {
        addEvent(eventName: EventType.addToCart.rawValue , currency: currency, total: total, products: products)
    }
    
    public static func initiateCheckoutEvent(currency: String ,total: String ,products: [ConvertedinProduct]) {
        addEvent(eventName: EventType.checkout.rawValue , currency: currency, total: total, products: products)
    }
    
    public static func purchaseEvent(orderId: String, currency: String ,total: String ,products: [ConvertedinProduct]) {
        addEvent(eventName: EventType.purchase.rawValue, orderId: orderId, currency: currency, total: total, products: products)
    }
}

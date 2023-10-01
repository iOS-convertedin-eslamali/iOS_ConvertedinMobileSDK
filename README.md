# ConvertedinMobileSDK

Welcome to the ConvertedinMobileSDK documentation!

## Table of Contents

- [Introduction](#introduction)
- [Installation](#installation)
- [Getting Started](#getting-started)


## Introduction

Convertedin SDK for events and push notifications is a powerful tool for developers to create engaging and personalized experiences for your app users. With this SDK, developers can easily track user behavior and send targeted push notifications to drive engagement and increase retention. Push notifications allow developers to reach users even when they're not actively using the app, keeping them up to date with the latest news, updates, and promotions. By leveraging Convertedin SDK for events and push notifications, developers can create more meaningful and impactful experiences for their users, leading to higher engagement, increased user satisfaction, and ultimately, greater success for their app.

## Installation

 __Installation with Swift Package Manager__

To integrate ConvertedinMobileSDK into your iOS project using Swift Package Manager, follow these simple steps:

- Open Your Project: In Xcode  
- open your project workspace or project file where you want to add the framework.  
- Go to the "File" menu.   
- Select "Swift Packages."  
- Choose "Add Package Dependency..."  
- Enter the Repository URL:  
```
 https://github.com/iOS-convertedin-eslamali/iOS_ConvertedinMobileSDK.git 
```
- Click "Next & Finish"  
- Build and Run:  
- Xcode will automatically resolve and fetch the framework package.  
- Build and run your project to start using ConvertedinMobileSDK in your application  

And that's it! You've successfully integrated ConvertedinMobileSDK into your project using Swift Package Manager. 🚀


__Installation with Cocoapods__  

To effortlessly integrate ConvertedinMobileSDK into your iOS project using CocoaPods, follow these straightforward steps:  
First you need to install cocaopods, Here's a comprehensive guide on how to install cocoapods [ here ](https://guides.cocoapods.org/using/getting-started.html)  

After installing the Cocoapods successfully  

- Open the Podfile in a text editor and add the following line.
```
 pod 'ConvertedinMobileSDK'
```

- Run the following command to install the framework and its dependencies:
 ```
 pod install
```
You can now import and use ConvertedinMobileSDK in your iOS project. Xcode will handle the linking and configuration.  
And that's it! You've successfully integrated ConvertedinMobileSDK into your project using CocoaPods. 🚀


## Getting Started
**Step 1:**
- Open your app's AppDelegate.swift file.
- Import ConvertedinMobileSDK at the top of AppDelegate.swift using the following line of code   
```swift
 import convertedinMobileSDK
```
- In the application(_:didFinishLaunchingWithOptions:) method, integrate our framework by adding the following code:
```swift
 ConvertedinMobileSDK.configure(pixelId: "Pixel_id", storeUrl: "store@test.com")
```
Make sure to set the pixelId and storeUrl as the appropriate initialization parameters for your use case. These parameters are crucial for configuring the SDK with your desired settings.

**Step 2:**   
For your app to make the best use of ConvertedinMobileSDK, it's essential to set up push notifications in the `AppDelegate`. Here's a comprehensive guide on how to Push Notification [Push Notifications Documentation](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/establishing_a_certificate-based_connection_to_apns).   

- After Setup the Push Notification successfully, Implement the didReceiveRegistrationToken method in your AppDelegate.swift file to receive the FCM device token. This method is called when a new token is generated or an existing token is updated, with the following code 

```swift
 func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken = fcmToken {
            UserDefaults.standard.set(fcmToken, forKey: "convertedin_fcmToken")
        }
    }
```

**Step 3:**   
- After successfully receiving a response from the login method or any other relevant action, you can use our ConvertedinMobileSDK's method to identify the user. Follow these steps to ensure user identification:

```swift
ConvertedinMobileSDK.identifyUser(email: "test@converted.in", countryCode: nil, phone: nil)
```
In this code snippet, you have the option to identify the user using either their email or phone number. Replace "test@converted.in" with the user's email address and provide the appropriate country code if you are identifying the user by phone number.

**Step 4:** **Add Event**  ConvertedinMobileSDK offers a set of predefined events that are commonly used in most e-commerce applications. These predefined events include:

- `ViewContent`: To track when a user views content, such as a product.
- `PageView`: To track when a user views a specific page.
- `AddToCart`: To track when a user adds an item to their cart.
- `InitiateCheckout`: To track when a user initiates the checkout process.
- `Purchase`: To track when a user completes a purchase.

You can use these predefined events to gather valuable data and insights about user interactions in your application effortlessly.

 If the predefined events do not fully meet your tracking needs, don't worry! **ConvertedinMobileSDK** allows you to create your own custom events using unique identifiers. This flexibility enables you to tailor event tracking to the specific actions and interactions that matter most to your application.

By leveraging both predefined and custom events, you can gain a comprehensive understanding of user behavior and make data-driven decisions to enhance your e-commerce application.

you can use a predefined events with the following code:
```swift
ConvertedinMobileSDK.pageViewEvent()
ConvertedinMobileSDK.PageViewEvent()
ConvertedinMobileSDK.AddToCartEvent()
ConvertedinMobileSDK.InitiateCheckoutEvent()
ConvertedinMobileSDK.PurchaseEvent()
```

or you can create your custom events using the following code:
```swift
ConvertedinMobileSDK.addEvent()
```

- Please, be mindful of methods that require parameters related to currency, total price, and a set of products. These parameters are crucial for accurate event tracking and analytics in your e-commerce application.


**Step 5:** Logging Out or Notification Cessation

- If you want to stop geting our notification or when the user logout, call our ConvertedinMobileSDK's deleteDeviceToken method to unregister the device for notifications. This ensures that the user no longer receives notifications from your app.

```swift
ConvertedinMobileSDK.deleteDeviceToken()
```


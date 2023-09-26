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
Import ConvertedinMobileSDK at the top of your Swift source files where you intend to use it
```swift
 import convertedinMobileSDK
```

**Step 2:** In the variables area of your code, declare a variable to hold an instance of the SDK. Place this line of code:

```swift
var convertedinSDK: convertedinMobileSDK?
```

**Step 3:** Inside the `viewDidLoad` method, initialize the ConvtertedinMobileSDK SDK by adding the following code snippet:

```swift
convertedinSDK = convertedinMobileSDK(pixelId: "Pixel_id", storeUrl: "store@test.com")
```
Make sure to set the pixelId and storeUrl as the appropriate initialization parameters for your use case. These parameters are crucial for configuring the SDK with your desired settings.

**Step 4:** Then you need to identify a user in your application, you can use the following line of code:

```swift
convertedinSDK?.identifyUser(email: "test@converted.in", countryCode: nil, phone: nil)
```
In this code snippet, you have the option to identify the user using either their email or phone number. Replace "test@converted.in" with the user's email address and provide the appropriate country code if you are identifying the user by phone number.

**Step 5:** **Add Event**  ConvertedinMobileSDK offers a set of predefined events that are commonly used in most e-commerce applications. These predefined events include:

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
convertedinSDK?.pageViewEvent()
convertedinSDK?.PageViewEvent()
convertedinSDK?.AddToCartEvent()
convertedinSDK?.InitiateCheckoutEvent()
convertedinSDK?.PurchaseEvent()
```

or you can create your custom events using the following code:
```swift
convertedinSDK?.addEvent()
```


Please, be mindful of methods that require parameters related to currency, total price, and a set of products. These parameters are crucial for accurate event tracking and analytics in your e-commerce application.


**Step 5:** **Push Notification** To use Convertedin SDK’s push notifications, you need to integrate with firebase notifications.  
Integrating your iOS app with Firebase Cloud Messaging (FCM) for push notifications allows you to send push notifications to your app users.  

Here's a comprehensive guide on how to integrate Firebase notifications into your iOS app: [ here ](https://firebase.google.com/docs/ios/installation-methods)

After Integrating you project with firebase successfully, call this method on the SDK to send the firebase token to start getting notifications from your dashboard
```swift
convertedinSDK?.saveDeviceToken(token: "device_token")
```

⚠️ Important Note: Each Time firebase token is updated you must call saveDeviceToken method to save the new firebase token

If user logged out or you want user to stop getting notifications from our side, you can call this method
```swift
convertedinSDK?.deleteDeviceToken()
```










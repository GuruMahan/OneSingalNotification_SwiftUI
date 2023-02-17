//
//  OneSingalNotificationPOCApp.swift
//  OneSingalNotificationPOC
//
//  Created by Guru Mahan on 16/02/23.
//

import SwiftUI
import OneSignal
import OneSignalNotificationServiceExtention
import OneSignalExtension
import UserNotifications


@main
struct OneSingalNotificationPOCApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
class AppDelegate: UIResponder, UIApplicationDelegate,OSSubscriptionObserver {
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges) {
        
    }
    
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges) {
         if !stateChanges.from.isSubscribed && stateChanges.to.isSubscribed {
            print("Subscribed for OneSignal push notifications!")
         }
        print("SubscriptionStateChange: \n\(String(describing: stateChanges))")

         //The player id is inside stateChanges. But be careful, this value can be nil if the user has not granted you permission to send notifications.
         if let playerId = stateChanges.to.userId {
            print("Current playerId \(playerId)")
         }
      }
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    
    
    
    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
         // Example of detecting answering the permission prompt
         if stateChanges.from.status == OSNotificationPermission.notDetermined {
            if stateChanges.to.status == OSNotificationPermission.authorized {
               print("Thanks for accepting notifications!")
            } else if stateChanges.to.status == OSNotificationPermission.denied {
               print("Notifications not accepted. You can turn them on later under your iOS settings.")
            }
         }
         // prints out all properties
        print("PermissionStateChanges: \n\(String(describing: stateChanges))")
      }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        OneSignal.add(self as OSSubscriptionObserver)
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
       
           OneSignal.initWithLaunchOptions(launchOptions)
           OneSignal.setAppId("f9e2942b-300b-4039-8b47-666584bd4c90")
           
           OneSignal.promptForPushNotifications(userResponse: { accepted in
             print("User accepted notifications: \(accepted)")
           })
       
        setupExternalId()
       
           return true
    }
    
   
    
    private func setupExternalId() {
      let externalUserId = randomString(of: 10)
    
      OneSignal.setExternalUserId(externalUserId, withSuccess: { results in
        print("External user id update complete with results: ", results!.description)
        if let pushResults = results!["push"] {
          print("Set external user id push status: ", pushResults)
        }
        if let emailResults = results!["email"] {
          print("Set external user id email status: ", emailResults)
        }
        if let smsResults = results!["sms"] {
          print("Set external user id sms status: ", smsResults)
        }
      }, withFailure: {error in
        print("Set external user id done with error: " + error.debugDescription)
      })
    }
    
    
    
    private func randomString(of length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      var s = ""
      for _ in 0 ..< length {
        s.append(letters.randomElement()!)
      }
      return s
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        OneSignal.promptForPushNotifications(userResponse: { accepted in
          print("User accepted notifications: \(accepted)")
                    
          if let deviceState = OneSignal.getDeviceState() {
         //   let userId = deviceState.userId
            let pushToken = deviceState.pushToken
          //  let subscribed = deviceState.isSubscribed
              print("pushToken ====> \(String(describing: pushToken))") //Here you can get the token
          }
         })
        let userinfo = response.notification.request.content.userInfo
        NotificationCenter.default.post(name: NSNotification.Name("Detail"), object: nil, userInfo: userinfo)
       
        completionHandler()
    }
}


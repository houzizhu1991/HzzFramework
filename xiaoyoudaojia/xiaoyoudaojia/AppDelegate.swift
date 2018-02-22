//
//  AppDelegate.swift
//  xiaoyoudaojia
//
//  Created by 罗心恺 on 2018/1/25.
//  Copyright © 2018年 罗心恺. All rights reserved.
//

import UIKit
import SVProgressHUD

import UserNotifications

protocol XYDZLocationUpdateDelegate:class {
    func locationDidUpdate(_ success:Bool)
}

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate, AMapLocationManagerDelegate, JPUSHRegisterDelegate {
   
    var window: UIWindow?
    private var locationManager :AMapLocationManager!
    weak  var locationUpdateDelegate:XYDZLocationUpdateDelegate?
    
    private var enableUploadLoaction:Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(2.0)
        
        self.initSDK(launchOptions)
        
       
    
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        
        let objcData = NSData.init(data: deviceToken)
        
        let tokenString = objcData.description.replacingOccurrences(of: ">", with: "").replacingOccurrences(of: "<", with: "").replacingOccurrences(of: " ", with: "")
        
          JPUSHService.registerDeviceToken(deviceToken)
        
        HzzLog(message: "注册APNs成功   \(String(describing: tokenString))")
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        HzzLog(message: "注册APNs失败   \(error)")
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        HzzLog(message: "收到推送通知   \(userInfo)")
        
        if HzzBaseUser.sharedIUser.isLogin() {
            // to do
        }
        
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        HzzLog(message: "收到推送通知   \(userInfo)")
        
        if HzzBaseUser.sharedIUser.isLogin() {
            // to do
        }
        
        completionHandler(.newData)
    }
    
    
    func initSDK(_ options:[UIApplicationLaunchOptionsKey: Any]?)  {
        
        // Bugly
        Bugly.start(withAppId: "demokey")
        
        // 高德地图
        AMapServices.shared().apiKey = "demokey"
        self.locationManager = AMapLocationManager.init()
        self.locationManager.delegate = self
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.locationTimeout = 3
        self.locationManager.reGeocodeTimeout = 2
        
        //开始定位
        self.getLocation()
        
        //极光推送
        let entity:JPUSHRegisterEntity = JPUSHRegisterEntity.init()
        entity.types = Int(UInt8(JPAuthorizationOptions.alert.rawValue) | UInt8(JPAuthorizationOptions.badge.rawValue) |
            UInt8(JPAuthorizationOptions.sound.rawValue))
        
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        
        // 生产环境 和 开发环境
          JPUSHService.setup(withOption: options, appKey: "71f1271839c9775c29eda082", channel: "APPStore", apsForProduction: true)
        
        // 接收自定义消息
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.networkDidReceiveMesssge(_:)), name: NSNotification.Name.jpfNetworkDidReceiveMessage, object: nil)
        
        // 自启动推送通知
        if options != nil && (options![UIApplicationLaunchOptionsKey.remoteNotification] != nil) {
            
            if HzzBaseUser.sharedIUser.isLogin() {
                // to do
            }
        }
    }
    
    
    func getLocation()  {
        //开始定位
        self.locationManager.requestLocation(withReGeocode: false) { (location, geocode, error) in
            
                 if error == nil {
                    HzzLog(message: "定位成功:  \(String(describing: location))")
                
                      if HzzBaseUser.sharedIUser.location == nil {
                       HzzBaseUser.sharedIUser.location = location?.coordinate
                      if self.locationUpdateDelegate != nil {
                        self.locationUpdateDelegate!.locationDidUpdate(true)
                      }
                        
                    }
                 }else {
                    
                    if self.locationUpdateDelegate != nil {
                  self.locationUpdateDelegate!.locationDidUpdate(false)
                 }
            }
        }
    }
    
//    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!) {
//        HzzLog(message: "定位成功:  \(location)")
//
//        if HzzBaseUser.sharedIUser.location == nil {
//           //SVProgressHUD.showSuccess(withStatus: "位置更新成功")
//           HzzBaseUser.sharedIUser.location = location.coordinate
//           if self.locationUpdateDelegate != nil {
//            self.locationUpdateDelegate!.locationDidUpdate(true)
//           }
//
//           // 上传经纬度
//            let timer = Timer.init(fireAt: Date.distantPast, interval: 20, target: self, selector: #selector(AppDelegate.uploadLoactionAction), userInfo: nil, repeats: true)
//
//            RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
//        }
//    }
    
//    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
//        HzzLog(message: "定位失败")
//
//        if self.locationUpdateDelegate != nil {
//            self.locationUpdateDelegate!.locationDidUpdate(false)
//        }
//
//
//    }

    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        
        let userInfo = notification.request.content.userInfo
        if notification.request.trigger != nil {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        
        // 允许在前台展示消息
    completionHandler(Int(UNNotificationPresentationOptions.alert.rawValue))
        
    }
    
    @available(iOS 10.0, *)
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        let userInfo = response.notification.request.content.userInfo
        if response.notification.request.trigger != nil {
            JPUSHService.handleRemoteNotification(userInfo)
        }
        
    
        completionHandler()
        
    }
    
    @objc func networkDidReceiveMesssge(_ noti:Notification) {
        
        HzzLog(message: "message ======== \(noti.userInfo)")
        
        let userInfo = noti.userInfo
        let extras = userInfo!["extras"] as? [String:Any]
//        if extras != nil {
//            let orderID = extras!["id"] as? String
//            if orderID != nil {
//              NotificationCenter.default.post(name: NSNotification.Name.init("ReceiveNewOrder"), object: orderID)
//            }
//        }
    }
    
}


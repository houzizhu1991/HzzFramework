//
//  JJGUser.swift
//  JiaJuGe
//
//  Created by 罗心恺 on 2017/12/27.
//  Copyright © 2017年 罗心恺. All rights reserved.
//

import Foundation

private let localUserKey = "xydjUser"

class HzzBaseUser {
    static  let sharedIUser = HzzBaseUser()
    var phoneNum:String = ""
    var token:String = ""
    var uid:String = ""
    var location:CLLocationCoordinate2D?
    var province:String = ""
    var city:String = ""
    var zone:String = ""
    var infoDic:[String:Any]?
    var receivePushNoti:Bool = false
    
    private init(){
        
    }
    
    private func saveInfo() {
        // 持久化
        let  info = ["phone":self.phoneNum, "token":self.token]
        UserDefaults.standard.set(info, forKey: localUserKey)
        UserDefaults.standard.synchronize()
    }
    
    func updateBaseInfo(_ info:[String:Any]) {
        let token = info["access_token"] as? String
        if token != nil {
            self.token = token!
        }
        
        let phone = info["phone"] as? String
        if phone != nil {
            self.phoneNum = phone!
        }
        
        self.saveInfo()
        //self.enableGrab(true, finish: nil)
    }
    
    
    func enablePushNotification(_ enable:Bool, finish:((Bool) -> Void)?) {
        if self.receivePushNoti == enable {
            return
        }
        
          if enable {
            // 绑定别名
            JPUSHService.setAlias(HzzBaseUser.sharedIUser.token, completion: { (code, alias, seq) in
            if code == 0 {
            HzzLog(message: "绑定别名成功")
                self.receivePushNoti = true
                finish?(true)
            
            }else {
            HzzLog(message: "绑定失败 错误码 == \(code)")
                finish?(false)
            }
            
            
            }, seq: 0)
            
            
            
            }else {
            JPUSHService.deleteAlias({ (code, alias, seq) in
                if code == 0 {
                    HzzLog(message: "已解除绑定")
                    self.receivePushNoti = false
                    finish?(true)
                }else {
                    HzzLog(message: "解除绑定失败  错误码=== \(code)")
                    finish?(false)
                }
                
            }, seq: 1)
            
        }
        
    }
    
    func isLogin() -> Bool {
        if self.token.count > 0 {
            return true
        }
        
        if UserDefaults.standard.object(forKey: localUserKey) is [String:Any] {
            let info = UserDefaults.standard.object(forKey: localUserKey) as! [String:Any]
            self.token = info["token"] as! String
            self.phoneNum = info["phone"] as! String
            return true
        }
        return false
    }
    
    
    func logOut() {
        self.enablePushNotification(false, finish: nil)
        UserDefaults.standard.removeObject(forKey: localUserKey)
        self.clearInfo()
    }
    
    private func clearInfo() {
        self.phoneNum = ""
        self.token = ""
    }
    
}

//
//  BaseNavigationViewController.swift
//  JiaJuGe
//
//  Created by 罗心恺 on 2017/12/26.
//  Copyright © 2017年 罗心恺. All rights reserved.
//

import UIKit

class BaseNavigationViewController: UINavigationController,UINavigationControllerDelegate {
    
    private var lock:NSLock = NSLock()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.interactivePopGestureRecognizer?.isEnabled = false
        self.view.backgroundColor = UIColor.white
        self.delegate = self
        self.navigationBar.isTranslucent = false
        self.navigationBar.shadowImage = UIImage.init()
        
        self.navigationBar.tintColor = kThemeColor
//        self.navigationBar.setBackgroundImage(UIImage.imageWithColor(color: kThemeColor), for: .default)
        
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
         NotificationCenter.default.addObserver(self, selector: #selector(BaseNavigationViewController.loginTimeOut), name: NSNotification.Name(rawValue: kHzzLoginTimeOut), object: nil)
        
          NotificationCenter.default.addObserver(self, selector: #selector(BaseNavigationViewController.logOut), name: NSNotification.Name(rawValue: kHzzLogout), object: nil)
        
    
        // Do any additional setup after loading the view.
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
    }
    
    
    @objc func loginTimeOut() {
        self.lock.lock()
        
         HzzBaseUser.sharedIUser.logOut()
        
        let alertVC:UIAlertController = UIAlertController.init(title: "登录超时", message: "您的账号在其他设备登录", preferredStyle: .alert)
        
        let cancelAction:UIAlertAction = UIAlertAction.init(title: "确定", style: .cancel, handler: {
            (action) in
            
            self.popToRootViewController(animated: true)
            
        })
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
        self.lock.unlock()
        
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
    }
    
   @objc func logOut() {
        HzzBaseUser.sharedIUser.logOut()
        self.popToRootViewController(animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  BaseTabBarViewController.swift
//  JiaJuGe
//
//  Created by 罗心恺 on 2017/12/28.
//  Copyright © 2017年 罗心恺. All rights reserved.
//

import UIKit

class BaseTabBarViewController: UITabBarController,UITabBarControllerDelegate {
    private var lock:NSLock = NSLock()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        //JJGLog(message: self.navigationController?.viewControllers.index(of: self))
        
        NotificationCenter.default.addObserver(self, selector: #selector(BaseTabBarViewController.loginTimeOut), name: NSNotification.Name(rawValue: kHzzLoginTimeOut), object: nil)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logOut() {
        HzzBaseUser.sharedIUser.logOut()
    }
    
    @objc func loginTimeOut() {
        self.lock.lock()
        let alertVC:UIAlertController = UIAlertController.init(title: "登录超时", message: "您的账号在其他设备登录", preferredStyle: .alert)
       
        let cancelAction:UIAlertAction = UIAlertAction.init(title: "确定", style: .cancel, handler: {
            (action) in
            
               self.logOut()
               self.navigationController?.popViewController(animated: true)
            
        })
        alertVC.addAction(cancelAction)
        self.present(alertVC, animated: true, completion: nil)
        self.lock.unlock()
        
    }
        

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

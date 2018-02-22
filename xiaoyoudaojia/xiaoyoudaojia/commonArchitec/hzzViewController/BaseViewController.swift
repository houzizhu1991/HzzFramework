//
//  BaseViewController.swift
//  JiaJuGe
//
//  Created by 罗心恺 on 2017/12/26.
//  Copyright © 2017年 罗心恺. All rights reserved.
//

import UIKit
import SVProgressHUD

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        // 返回键
        self.leftImage = UIImage.init(named: "icon_back")
        self.leftBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.leftBtn?.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
        self.leftBtn?.addTarget(self, action: #selector(BaseViewController.leftBtnClick), for: .touchUpInside)
        
        self.hideLeftBtn(hide: self.navigationController?.viewControllers.index(of: self) == 0)
        
        // Do any additional setup after loading the view.
    }
    
    // swift 4.0 @objc
    @objc func leftBtnClick()  {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func rightBtnClick()  {
        HzzLog(message: "youbian")
        self.contactCustomerService()
    }
    
    // 联系客服
    func contactCustomerService() {
        self.callSomeone(phone: "028-85803640")
    }
    
    // 打电话
    func callSomeone(phone:String) {
        var filterStr = String()
        filterStr.append(phone)
        
        if filterStr.contains("-") {
            let index = phone.index(of: "-")
            filterStr.remove(at: index!)
        }
        
        let predicate = NSPredicate(format: " SELF MATCHES %@", InputRegexs.Mobile.rawValue)
        let predicate1 = NSPredicate(format: " SELF MATCHES %@", InputRegexs.Phone.rawValue)
        
        let validPhone =  (predicate.evaluate(with:filterStr) || predicate1.evaluate(with: filterStr))
        if validPhone {

            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL.init(string: ("tel://\(filterStr)"))!, options: [:], completionHandler: nil)
            }else {
                UIApplication.shared.openURL(URL.init(string: ("tel://\(filterStr)"))!)
            }
            

        }else {
            HzzLog(message: "illegal  PhoneNumber!!!")
            
        }
    }
    
    func showMessage(_ message:String)  {
        SVProgressHUD.showMessage(message)
    }
    
    func showSuccessMessage(_ message:String) {
        SVProgressHUD.showSuccess(withStatus: message)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // deinit
    deinit {
        print(self , "-----------deinit---------")
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

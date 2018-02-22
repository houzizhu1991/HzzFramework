//
//  ViewController+Extension.swift
//  JiaJuGe
//
//  Created by 罗心恺 on 2017/12/26.
//  Copyright © 2017年 罗心恺. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol VCItemDelegate {
    var leftImage:UIImage?   {get set}
    var rightImage:UIImage?  {get set}
    var leftBtn:UIButton?    {get}
    var rightBtn:UIButton?   {get}
    func hideLeftBtn(hide:Bool)
    func hideRightBtn(hide:Bool)
}

class JJGPhotoChooseTool:NSObject,UINavigationControllerDelegate,UIImagePickerControllerDelegate  {
    private var imgClosure:((UIImage) -> Void)?
    weak var controller: UIViewController?
    init(controller:UIViewController, callBack:((UIImage) -> Void)?) {
        self.controller = controller
        self.imgClosure = callBack
    }
    
    func selectFromAlbum()  {
       let tAuthStatus = PHPhotoLibrary.authorizationStatus()
        // 无权限
        if (tAuthStatus == .restricted || tAuthStatus == .denied) {
            self.controller?.showAlert(title: "提示", message: "此应用无法使用你的相册，请在iPhone的设置中开启访问相册!", cancelTitle: "取消", cancelBlock: nil, queryTitle: "去设置", queryBlock: { (action) in
                UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
            })
        }
            // 未知权限
        else if (tAuthStatus == .notDetermined) {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if (status == .authorized) {
                    self.queryAddPhotos()
                }
            })
        }
        else {
            self.queryAddPhotos()
        }
        
    }
    
    func selectByShoot()  {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if (authStatus == .restricted || authStatus == .denied) {
            self.controller?.showAlert(title: "提示", message: "此应用无法使用你的相机，请在iPhone的“设置 -> 隐私 -> 相机”选项中开启相机功能!", cancelTitle: "取消", cancelBlock: nil, queryTitle: "去设置", queryBlock: { (action) in
                UIApplication.shared.openURL(URL.init(string: UIApplicationOpenSettingsURLString)!)
            })
            
        }
        else {
            //判断是否可以打开相机，模拟器此功能无法使用
            if (UIImagePickerController.isSourceTypeAvailable(.camera))
            {
                
                let pickerVC = UIImagePickerController.init()
                pickerVC.sourceType = .camera
                pickerVC.cameraCaptureMode = .photo
                pickerVC.delegate = self
                self.controller?.navigationController?.present(pickerVC, animated: true, completion: nil)
                
            }
            else{
                //如果没有提示用户
                self.controller?.showAlert(title: nil, message: "未检测到摄像头", cancelTitle: "知道了", cancelBlock: nil, queryTitle: nil, queryBlock: nil)
            }
        }
        
    }
    
    private func queryAddPhotos() {
        let pickerVC = UIImagePickerController.init()
        pickerVC.sourceType = .savedPhotosAlbum
        pickerVC.allowsEditing = true
        pickerVC.delegate = self
        self.controller?.present(pickerVC, animated: true, completion: nil)
    }
    
    
    // 图片选择代理方法
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("取消图片选择")
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if picker.sourceType == .camera {
            if self.imgClosure != nil {
                DispatchQueue.main.async {
                    self.imgClosure!(info[UIImagePickerControllerOriginalImage] as! UIImage)
                }
            }
            
        }else {
            if self.imgClosure != nil {
                DispatchQueue.main.async {
                   self.imgClosure!(info[UIImagePickerControllerEditedImage] as! UIImage)
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController : VCItemDelegate  {
    var leftImage:UIImage?   {
        get {
            return ((self.navigationItem.leftBarButtonItem?.customView) as? UIButton)?.image(for: UIControlState.normal)
        }
        set  {
            let leftBtn:UIButton = UIButton.init(type: UIButtonType.custom)
            leftBtn.frame = CGRect(x:0,y:0,width:70,height:44)
            leftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            leftBtn.setImage(newValue, for: UIControlState.normal)
            let leftBarItem:UIBarButtonItem = UIBarButtonItem.init(customView: leftBtn)
            self.navigationItem.leftBarButtonItem = leftBarItem
        }}
    
    var leftTitle:String?  {
        get {
            return  ((self.navigationItem.leftBarButtonItem?.customView) as? UIButton)?.title(for: UIControlState.normal)
        }
        set {
            let leftBtn:UIButton = UIButton.init(type: UIButtonType.custom)
            leftBtn.frame = CGRect(x:0,y:0,width:70,height:44)
            leftBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
            leftBtn.setTitle(newValue, for: UIControlState.normal)
            leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            let leftBarItem:UIBarButtonItem = UIBarButtonItem.init(customView: leftBtn)
            self.navigationItem.leftBarButtonItem = leftBarItem
        }}
    
    
    var rightImage:UIImage?  {
        get {
             return  ((self.navigationItem.rightBarButtonItem?.customView) as? UIButton)?.image(for: UIControlState.normal)
        }
        set {
            let rightBtn:UIButton = UIButton.init(type: UIButtonType.custom)
            rightBtn.frame = CGRect(x:0,y:0,width:70,height:44)
            rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
            rightBtn.setImage(newValue, for: UIControlState.normal)
            let rightBarItem:UIBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
            self.navigationItem.rightBarButtonItem = rightBarItem
        }}
    
    var rightTitle:String?  {
        get {
            return  ((self.navigationItem.rightBarButtonItem?.customView) as? UIButton)?.title(for: UIControlState.normal)
        }
        set {
            let rightBtn:UIButton = UIButton.init(type: UIButtonType.custom)
            rightBtn.frame = CGRect(x:0,y:0,width:70,height:44)
            rightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
            rightBtn.setTitle(newValue, for: UIControlState.normal)
            rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            let rightBarItem:UIBarButtonItem = UIBarButtonItem.init(customView: rightBtn)
            self.navigationItem.rightBarButtonItem = rightBarItem
        }}
    
    
    
    var leftBtn:UIButton?    {
        get  {
            return ((self.navigationItem.leftBarButtonItem?.customView) as? UIButton)
            
        }
    
    }
    var rightBtn:UIButton?   {
        get {
            return ((self.navigationItem.rightBarButtonItem?.customView) as? UIButton)
        }
    }
    
    func hideLeftBtn(hide: Bool)  {
        self.leftBtn?.isHidden = hide
    }
    
    func hideRightBtn(hide:Bool) {
        self.rightBtn?.isHidden = hide
    }
    
    // 选择图片
    func getPhoto(fromAlbumcallBack:(() -> Void)?, shootCallBack:(() -> Void)?){
        let sheetVC:UIAlertController = UIAlertController.init(title: nil, message: "请选择图片来源：", preferredStyle: .actionSheet)
        
        let cancelAction:UIAlertAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            sheetVC.addAction(cancelAction)

        let shootAction:UIAlertAction = UIAlertAction.init(title: "拍照", style: .default, handler:{
            (action) in
         
            shootCallBack?()
            
        })
            sheetVC.addAction(shootAction)
        
    
         let fromAlbumAction:UIAlertAction = UIAlertAction.init(title: "相册", style: .default, handler:{
        (action) in
            fromAlbumcallBack?()
    
    })
        sheetVC.addAction(fromAlbumAction)
        self.present(sheetVC, animated: true, completion: nil)
    
    }
    
    // alertView
    func showAlert(title:String?,message:String?,cancelTitle:String?, cancelBlock:((UIAlertAction) -> Void)?,queryTitle:String?, queryBlock:((UIAlertAction) -> Void)?) -> Void {
        
//        let alertVC1 = XYDZAlertViewController.init(title: title!, message: message, cancelAction: cancelBlock, cancelTitle: cancelTitle!, queryTitle: queryTitle!, queryAction:queryBlock)
//
//        self.present(alertVC1, animated: true, completion: nil)
//
//
//        return
        
        let alertVC:UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        if  cancelTitle != nil {
            let cancelAction:UIAlertAction = UIAlertAction.init(title: cancelTitle, style: .cancel, handler: cancelBlock)
            alertVC.addAction(cancelAction)
        }
        
        if queryBlock != nil && queryTitle != nil {
            let queryAction:UIAlertAction = UIAlertAction.init(title: queryTitle, style: .default, handler: queryBlock)
            alertVC.addAction(queryAction)
        }
        self.present(alertVC, animated: true, completion: nil)
    }
}


extension BaseViewController {
    
    
}

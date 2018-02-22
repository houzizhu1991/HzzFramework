//
//  HzzWebViewController.swift
//  JiaJuGe
//
//  Created by app on 2018/2/12.
//  Copyright © 2018年 罗心恺. All rights reserved.
//

import UIKit
import WebKit
import SVProgressHUD

class HzzWebViewController: BaseViewController , WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    
     var indexURL:String?
     var detailURL:String?
     var webView:WKWebView?
     var userContent:WKUserContentController?
     var progressView:UIProgressView?
    
     override func viewDidLoad() {
        super.viewDidLoad()
        self.hideRightBtn(hide: true)
        self.setupLeftItems()
        self.setupWebView()
        
        // Do any additional setup after loading the view.
    }
    
    func setupWebView()  {
        var urlString = ""
        if self.indexURL != nil {
            urlString = self.indexURL! + "?" + "accessToken="
                + HzzBaseUser.sharedIUser.token
        }
        
        if self.detailURL != nil {
            urlString = self.detailURL!
        }
        
        let myURL = URL(string: urlString)
        // 配置环境
        let config = WKWebViewConfiguration.init()
        self.userContent = WKUserContentController.init()
        
        // 禁止缩放
        let javascript = "var meta = document.createElement('meta');meta.setAttribute('name', 'viewport');meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');document.getElementsByTagName('head')[0].appendChild(meta);"
        
        let userScript = WKUserScript.init(source: javascript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        
        self.userContent?.addUserScript(userScript)
        config.userContentController = self.userContent!
        
        self.webView = WKWebView(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kNavHeight), configuration: config)
        self.webView?.navigationDelegate = self
        self.webView?.uiDelegate = self
        self.view.addSubview(self.webView!)
        
        var myRequest = URLRequest(url: myURL!)
        myRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.webView?.load(myRequest)
        
        self.webView!.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        self.webView!.addObserver(self, forKeyPath: "url", options: [.new, .old], context: nil)
        
        self.progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 2))
        self.progressView?.trackTintColor = UIColor.white
        self.progressView?.progressTintColor = UIColor.blue
        self.view.addSubview(self.progressView!)
        
        SVProgressHUD.show()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addScriptMessageHandlers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeScriptMessageHandlers()
    }
    
    func setupLeftItems()  {
        var leftItems:[UIBarButtonItem] = []
        let backBtn:UIButton = UIButton.init(type: UIButtonType.custom)
        backBtn.frame = CGRect(x:0,y:0,width:44,height:44)
        backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        backBtn.setImage(UIImage.init(named: "icon_back_b"), for: UIControlState.normal)
        backBtn.addTarget(self, action: #selector(BaseViewController.leftBtnClick), for: .touchUpInside)
        let backBarItem:UIBarButtonItem = UIBarButtonItem.init(customView: backBtn)
        leftItems.append(backBarItem)
        
        if self.indexURL == nil {
            let closeBtn:UIButton = UIButton.init(type: UIButtonType.custom)
            closeBtn.frame = CGRect(x:0,y:0,width:44,height:44)
            closeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
            closeBtn.addTarget(self, action: #selector(HzzWebViewController.backToRoot), for: .touchUpInside)
            closeBtn.setImage(UIImage.init(named: "close_btn_white"), for: UIControlState.normal)
            let closeBarItem:UIBarButtonItem = UIBarButtonItem.init(customView: closeBtn)
            leftItems.append(closeBarItem)
        }
        
        self.navigationItem.leftBarButtonItems = leftItems
    }
    
    // MARK:注册的js方法
    func jsMethods() -> [String] {
        return ["logout"]
    }
    
    // MARK:webView 代理方法
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    //当内容开始返回时调用
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
    }
    
    // 页面加载完成之后调用
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.getElementById('rbtn').innerHTML") { [weak self] (result, error) in
            HzzLog(message: result)
            if result is String {
                self?.rightBtn?.setTitle(result as? String, for: .normal)
                self?.rightBtn?.isHidden = false
               
            }
        }
        
        self.navigationItem.title = webView.title
        self.progressView?.progress = 0
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        SVProgressHUD.dismiss()
        
    }
    
    //页面加载失败时调用
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.progressView?.progress = 0
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        SVProgressHUD.showError(withStatus: "加载失败")
    }
    
    // 接收到服务器跳转请求之后调用
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    // 在发送请求之前，决定是否跳转
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)  {
        
        HzzLog(message: navigationAction.request.url)
        
        var newRequest = navigationAction.request
        //
        if newRequest.cachePolicy == .useProtocolCachePolicy {
            newRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            webView.load(newRequest)
            decisionHandler(.cancel)
            return
        }
        
        
        if self.shouldSkip((navigationAction.request.url?.absoluteString)!) {
            
            HzzLog(message: "webrequest =========  \(navigationAction.request)")
            decisionHandler(.allow)
            HzzLog(message: "allow")
            
        }else {
            
            decisionHandler(.cancel)
            let detailVC = HzzWebViewController()
            detailVC.detailURL = (navigationAction.request.url?.absoluteString)!
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            self.progressView?.isHidden = webView?.estimatedProgress == 1
            self.progressView?.setProgress(Float((webView?.estimatedProgress)!), animated: true)
            return
        }
        
        if (keyPath == "url") {
            HzzLog(message: self.webView!.url?.absoluteString);
            
        }
        
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return webView
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
        
        self.showAlert(title: message, message: nil, cancelTitle: "知道了", cancelBlock: nil, queryTitle: nil, queryBlock: nil)
        
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        self.showAlert(title: message, message: nil, cancelTitle: "取消", cancelBlock: {action in  completionHandler(false) }, queryTitle: "确认", queryBlock: {action in  completionHandler(true) })
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        completionHandler("aaaaaaaaaaaaaaa")
    }
    
    // 这个是注入js名称，在js端通过window.webkit.messageHandlers.{InjectedName}.postMessage()方法来发送消息到native。我们需要遵守此协议，然后实现其代理方法，就可以收到消息，并做相应处理。这个协议只有一个方法：
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        self.handleJSMessage(message)
    
    }
    
    
    override func leftBtnClick() {
        super.leftBtnClick()
    }
    
    
    override func rightBtnClick() {
        self.webView?.evaluateJavaScript("rbtnclick()", completionHandler: { [weak self] (result, error) in
            HzzLog(message: result)
            
            if result is String {
                self?.rightBtn?.setTitle(result as? String, for: .normal)
                
            }
        })
        
    }
    
    
    func cleanCash()  {
        if #available(iOS 9.0, *) {
            let set = WKWebsiteDataStore.allWebsiteDataTypes()
            let date = Date.init(timeIntervalSince1970: 0)
            
            WKWebsiteDataStore.default().removeData(ofTypes: set, modifiedSince: date, completionHandler: {
                HzzLog(message: "clean")
            })
            
            
        } else {
            // Fallback on earlier versions
            let libraryDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
            let bundleId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
            let webkitFolderInLib = libraryDir! + "/WebKit"
            let webKitFolderInCashes = libraryDir! + "/Caches/" + bundleId + "/WebKit"
            
            do {
                
                try FileManager.default.removeItem(atPath: webkitFolderInLib)
            }
                
            catch {
                
            }
            
            do {
                
                try FileManager.default.removeItem(atPath: webKitFolderInCashes)
            }
                
            catch {
                
            }
        }
    }
    
    func shouldSkip(_ urlStr:String) -> Bool {
        let prefix1 = urlStr.prefix(upTo: urlStr.index(of: "?")!)
        let prefix2 = self.webView!.url?.absoluteString.prefix(upTo: (self.webView!.url?.absoluteString.index(of: "?")!)!)
        
        if prefix1 != prefix2 {
            return false
        }
        
        return true
    }
    
    @objc func backToRoot() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func removeScriptMessageHandlers()  {
        for method in self.jsMethods() {
            self.userContent!.removeScriptMessageHandler(forName: method)
        }
    }
    
    func addScriptMessageHandlers()  {
        for method in self.jsMethods() {
            self.userContent!.add(self, name:method)
        }
    }
    
    // MARK:处理js发送过来的消息 override
    func handleJSMessage(_ message:WKScriptMessage) {
        if message.name == "logout" {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kHzzLoginTimeOut), object: nil)
    
        }
    }
    
    deinit {
        // push 被拦截了，页面渲染完成前被销毁
        if self.webView == nil {
            return
        }
        
        self.webView!.removeObserver(self, forKeyPath: "estimatedProgress", context: nil)
        self.webView!.removeObserver(self, forKeyPath: "url", context: nil)
        self.webView!.navigationDelegate = nil
        self.webView!.uiDelegate = nil
        
        SVProgressHUD.dismiss()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        self.cleanCash()
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

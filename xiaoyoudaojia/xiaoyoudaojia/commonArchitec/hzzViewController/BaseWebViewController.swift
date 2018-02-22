//
//  JJGWebViewController.swift
//  JiaJuGe
//
//  Created by 罗心恺 on 2018/1/23.
//  Copyright © 2018年 罗心恺. All rights reserved.
//

import UIKit

class BaseWebViewController: BaseViewController,UIWebViewDelegate {
    open var fileName:String?
    private var webView:UIWebView!
    private let indicator:UIActivityIndicatorView = {
        return UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.fileName == nil {
            return
        }
        
        self.webView = UIWebView.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight - kNavHeight))
        
        let path = Bundle.main.path(forResource:self.fileName!, ofType:"html")
        self.webView.loadRequest(URLRequest.init(url: URL.init(string: path!)!))
        self.webView.delegate = self
        self.indicator.center = self.view.center
        self.view.addSubview(self.webView)
        self.view.addSubview(self.indicator)
        
        self.indicator.startAnimating()
        // Do any additional setup after loading the view.
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.indicator.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        HzzLog(message: error)
        
    }
    
    deinit {
        self.webView.delegate = nil
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

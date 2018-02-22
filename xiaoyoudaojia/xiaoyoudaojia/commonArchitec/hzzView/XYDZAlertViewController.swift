//
//  XYDZAlertViewController.swift
//  xiaoyoudaojia
//
//  Created by 罗心恺 on 2018/2/3.
//  Copyright © 2018年 罗心恺. All rights reserved.
//

import UIKit

enum XYDZTransitionTpe:Int {
    case present = 0;
    case dismiss = 1;
}

class XYDZPresentTransition:NSObject, UIViewControllerAnimatedTransitioning {
    var type:XYDZTransitionTpe = .present
    
    init(_ type:XYDZTransitionTpe) {
        super.init()
        self.type = type
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.type == .present {
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            
            
            let containerView = transitionContext.containerView
            containerView.addSubview((toVC?.view)!)
            toVC?.view.frame = containerView.bounds
            toVC?.view.alpha = 0
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                toVC?.view.alpha = 1
                
            }, completion: { (finish) in
                if finish {
                    transitionContext.completeTransition(true)
                    
                }
            })
            
        
            
        }else {
             let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            
            let containerView = transitionContext.containerView
            containerView.addSubview((fromVC?.view)!)
            fromVC?.view.frame = containerView.bounds
            fromVC?.view.alpha = 1
            
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                fromVC?.view.alpha = 0
                
            }, completion: { (finish) in
                if finish {
                    transitionContext.completeTransition(true)
                    
                }
            })
            
        }
    }

}


class XYDZAlertViewController: UIViewController, UIViewControllerTransitioningDelegate {

    private var cancelBlock:((UIAlertAction) -> Void)?
    private var queryBlock:((UIAlertAction) -> Void)?
    private var message:String?
    private var alertViewTitle:String?
    private var cancelTitle:String?
    private var queryTitle:String?

    @IBOutlet weak var alertTitle: UILabel!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var queryBtn: UIButton!
    
    @IBOutlet weak var seeDetailView: UIView!
    
    
   convenience init(title:String?, message:String?, cancelAction:((UIAlertAction) -> Void)?, cancelTitle:String = "否", queryTitle:String = "是",
                    queryAction:((UIAlertAction) -> Void)?) {
        
        self.init(nibName: "XYDZAlertViewController", bundle: nil)
    
        self.message = message
        self.alertViewTitle = title
        self.cancelTitle = cancelTitle
        self.queryTitle = queryTitle
        self.cancelBlock = cancelAction
        self.queryBlock = queryAction
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return XYDZPresentTransition.init(.present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return XYDZPresentTransition.init(.dismiss)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if message == nil || alertViewTitle == nil{
            if message != nil {
                self.alertTitle.text = message
            }
            
            if alertViewTitle != nil {
                self.alertTitle.text = alertViewTitle
            }
        }else {
            let complete = alertViewTitle! + "\n" + message!
            let attributeString = NSMutableAttributedString.init(string: complete)
            
            let paragraph = NSMutableParagraphStyle.init()
            paragraph.lineSpacing = 10
            paragraph.alignment = .center
            attributeString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraph, range: NSMakeRange(0, complete.count))
            
            let messageRange = complete.range(of: message!)
            attributeString.addAttribute(NSAttributedStringKey.foregroundColor, value: RGBCOLOR(r: 255, 150, 28), range: NSRange(messageRange!, in: complete))
            
            self.alertTitle.attributedText = attributeString
            
        }
        
        if self.queryBlock != nil {
            self.seeDetailView.isHidden = true
        }
        
        self.cancelBtn.setTitle(cancelTitle, for: .normal)
        self.queryBtn.setTitle(queryTitle, for: .normal)

        // Do any additional setup after loading the view.
    }

    @IBAction func cancelAction(_ sender: UIButton) {
        if self.cancelBlock != nil {
            let cancelAction:UIAlertAction = UIAlertAction.init(title: self.cancelBtn.title(for: .normal), style: .cancel, handler: cancelBlock)
            self.cancelBlock!(cancelAction)
        }
        self.disappear()
    }
    
    
    @IBAction func queryAction(_ sender: Any) {
        if self.queryBlock != nil {
            let queryAction:UIAlertAction = UIAlertAction.init(title: self.queryBtn.title(for: .normal), style: .default, handler: queryBlock)

            self.queryBlock!(queryAction)
        }
        self.disappear()
        
    }
    
    private func disappear() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        }) { (finish) in
            if finish {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    deinit {
        HzzLog(message: "alert view deinit")
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






//
//  CommonViews.swift
//  JiaJuGe
//
//  Created by 罗心恺 on 2017/12/26.
//  Copyright © 2017年 罗心恺. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC
import ObjectMapper

// key 是 c指针
private var key:Void?

extension UIView {
    var touchCallback:((UIView)-> Void)? {
        get {
            return objc_getAssociatedObject(self, &key) as? ((UIView)-> Void)
        }
        set {
            if self is UIControl || newValue == nil {
                return
            }
            objc_setAssociatedObject(self, &key, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
            let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(UIView.touchView(_:)))
            self.isUserInteractionEnabled = true
            self.addGestureRecognizer(tapGesture)
        }
    }
    
    //  带参数加上 @objc 前缀
    @objc func touchView(_:UITapGestureRecognizer)  {
        let callBack = self.touchCallback
        if callBack != nil {
           callBack!(self)
        }
    }
    
    // 渐变色
    func setGradient(fromColor:UIColor, toColor:UIColor)  {
        // 自动布局
        if self.superview?.constraints != nil {
            if self.superview! is JJGObserveView {
               let superView = self.superview as! JJGObserveView
                superView.finishLayoutClosure = { [weak self] (frame) in
                    let gradientLayer = CAGradientLayer.init()
                    gradientLayer.frame = CGRect(x:0,y:0,width:frame.size.width,height:frame.size.height)
                    gradientLayer.colors = [fromColor.cgColor, toColor.cgColor]
                    self?.layer.insertSublayer(gradientLayer, below: self?.layer)
                }
            }else {
                return
            }
            return
        }
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [fromColor.cgColor, toColor.cgColor]
        self.layer.insertSublayer(gradientLayer, below: self.layer)
    }
    
    // 虚线边框
    func addDashLine()  {
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.strokeColor = UIColor.lightGray.cgColor;
        shapeLayer.fillColor = nil;
        shapeLayer.path = UIBezierPath.init(rect: self.bounds).cgPath;
        
        shapeLayer.frame = self.bounds;
        
        shapeLayer.lineWidth = 1.0;
        
        shapeLayer.lineCap = "square";
        shapeLayer.lineDashPattern = [4, 2];
        self.layer.addSublayer(shapeLayer)
    }
    
    // 虚线
    func addSingleDashLine(_ lineHeight:CGFloat = 2, _ startPoint:CGPoint, _ width:CGFloat) {
        let shapeLayer = CAShapeLayer.init()
          shapeLayer.frame = CGRect.init(x: startPoint.x, y: startPoint.y, width: width, height: lineHeight)
        shapeLayer.strokeColor = UIColor.lightGray.cgColor;
        shapeLayer.fillColor = nil
        
        let path = UIBezierPath.init()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint.init(x:shapeLayer.bounds.width,y:0))
        shapeLayer.path = path.cgPath
        
        shapeLayer.lineWidth = 1
        
        shapeLayer.lineCap = "square";
        shapeLayer.lineDashPattern = [4, 4];
        self.layer.addSublayer(shapeLayer)
        
    }
    
    // 尖角
    func addArrowView(_ location:CGFloat, _ color:UIColor) {
        let size = CGSize.init(width: 20, height: 20)
        let bezierPath = UIBezierPath.init()
        bezierPath.move(to: CGPoint.init(x: size.width/2.0, y: 0))
        bezierPath.addLine(to: CGPoint.init(x: 0, y: size.height))
        bezierPath.addLine(to: CGPoint.init(x: size.width, y: size.height))
        bezierPath.lineWidth = 1.0
        let arrowLayer = CAShapeLayer.init()
        arrowLayer.path = bezierPath.cgPath
        let arrowView = UIView.init(frame: CGRect(x:0,y:0 - size.height,width:size.width,height:size.height))
        arrowView.backgroundColor = color
        arrowView.layer.mask = arrowLayer
        arrowView.setCenterX(location * self.bounds.width)
        self.addSubview(arrowView)
    }
    
    
    // convience init
    convenience init(l:CGFloat,y:CGFloat,r:CGFloat,h:CGFloat) {
        self.init(frame: CGRect(x:l,y:y,width:kScreenWidth - l - r,height:h ))
    }
    
    func setHeight(h:CGFloat)  {
        var frame = self.frame
        frame.size.height = h
        self.frame = frame
    }
    
    func setY(y:CGFloat) {
        var frame = self.frame
        frame.origin = CGPoint.init(x: frame.origin.x, y: y)
        self.frame = frame
    }
    
    func setX(_ x:CGFloat) {
        var frame = self.frame
        frame.origin = CGPoint.init(x:x, y: frame.origin.y)
        self.frame = frame
    }
    
    func setCenterX(_ x:CGFloat) {
       self.center = CGPoint.init(x: x, y: self.center.y)
        
    }
    
    func setCenterY(_ y:CGFloat) {
        self.center = CGPoint.init(x: self.center.x, y: y)
        
    }
    
    func setHCenter() {
        if self.superview != nil {
           self.center = CGPoint.init(x: (self.superview?.bounds.midX)!, y: self.center.y)
        }
    }
    
    func setVCenter() {
        if self.superview != nil {
            self.center = CGPoint.init(x: self.center.x, y:(self.superview?.bounds.midY)!)
        }
    }
    
    func setBottom(_ y:CGFloat) {
        var newframe = self.frame
        newframe.origin = CGPoint.init(x: frame.origin.x, y: y - frame.height)
        self.frame = newframe
        
    }
    
    func setTrial(_ right:CGFloat) {
        if self.superview != nil {
            var newframe = self.frame
            newframe.origin = CGPoint.init(x: (self.superview?.bounds.width)! - self.bounds.width - right, y:newframe.origin.y)
            self.frame = newframe
        }
    }
    
    func widthToFit() {
        let height = self.bounds.height
        self.sizeToFit()
        self.setHeight(h: height)
        
    }

}

// MARK: -  +++++++++++++++++ layoutObserveView 监听自动布局完成后最新的frame
class JJGObserveView:UIView {
    var finishLayoutClosure:((CGRect) -> Void)?
    override func layoutSubviews() {
        HzzLog(message: self.frame)
        if self.finishLayoutClosure != nil {
            self.finishLayoutClosure!(self.frame)
        }
    }
}


// MARK: -  +++++++++++++++++ 阴影视图
class HzzShadowView:UIView {
    var contentView:UIView!
    init(frame: CGRect,radius:CGFloat = 0,width:CGFloat = 0,height:CGFloat = 4) {
        super.init(frame: frame)
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize.init(width: width, height: height)
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 3.0
        self.contentView = UIView.init(frame: self.bounds)
        self.addSubview(self.contentView)
        self.contentView.layer.cornerRadius = radius
        self.contentView.clipsToBounds = true
        
    }
    
    init(frame: CGRect,bezierPath:UIBezierPath,width:CGFloat = 4,height:CGFloat = 4) {
        super.init(frame: frame)
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize.init(width: width, height: height)
       
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 3.0
        self.contentView = UIView.init(frame: self.bounds)
        self.addSubview(self.contentView)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.contentView .bounds
        maskLayer.path = bezierPath.cgPath
        self.contentView.layer.mask = maskLayer
        self.contentView.clipsToBounds = true
        
    }
    
    override var backgroundColor: UIColor? {
        get {
            return self.contentView.backgroundColor
        }
        set {
            self.contentView.backgroundColor = newValue
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -   +++++++++++++++++ textfield ++++++++++++++++++++
typealias textChangeClosure = (_ tf: UITextField, _ alert:Bool) -> Void


extension String {
    mutating func isPhoneNum() ->Bool {
        if self.contains("-") {
            let index = self.index(of: "-")
            self.remove(at: index!)
        }
        
        let predicate = NSPredicate(format: " SELF MATCHES %@", InputRegexs.Mobile.rawValue)
        let predicate1 = NSPredicate(format: " SELF MATCHES %@", InputRegexs.Phone.rawValue)
        
        let validPhone =  (predicate.evaluate(with:self) || predicate1.evaluate(with: self))
        
        return validPhone
    }
    
    func isPassWord() -> Bool {
         let predicate = NSPredicate(format: " SELF MATCHES %@", InputRegexs.PassWord.rawValue)
        
         let isValid = predicate.evaluate(with: self)
         return isValid

    }
    
    func isSmsCode() -> Bool {
        let predicate = NSPredicate(format: " SELF MATCHES %@", InputRegexs.SmsCode.rawValue)
        
        let isValid = predicate.evaluate(with: self)
        return isValid
        
    }
    
    func toTimeString() -> String {
        let timeInterval = TimeInterval(self)
        if timeInterval == nil {
            return ""
        }
        
        let date = Date(timeIntervalSince1970: timeInterval!)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //自定义日期格式
        let time = dateformatter.string(from: date)
        return time
    }
    
    func saveAs(identifier:String) {
        UserDefaults.standard.set(self, forKey: identifier)
        UserDefaults.standard.synchronize()
        
    }
    
    static func getLocalStore(identifier:String) -> String {
        if UserDefaults.standard.value(forKey: identifier) == nil {
            return ""
        }
        
        return UserDefaults.standard.value(forKey: identifier) as! String
        
    }
    
}

extension NSMutableAttributedString {
    func add(attributes:[NSAttributedStringKey:Any], subString:String)  {
        
        let subRange = self.string.range(of: subString)
        if subRange == nil {
            return
        }
        self.addAttributes(attributes, range: NSRange(subRange!,in:self.string))
    }
}

class JJGTextField: UITextField {
   private var limitLength:Int?
   private var textChangedBlock:textChangeClosure?
   var RegexCondition:InputRegexs?
   var edgeInset:UIEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8)
   // 回调监听
   func setTextChanged(callback:textChangeClosure?) -> Void {
        textChangedBlock = callback
        self.addTarget(self, action: #selector(JJGTextField.textChanged(tf:)), for: .editingChanged)
   }
    
   func setText(maxLength:Int!, callback:textChangeClosure?) -> Void {
        limitLength = maxLength
        textChangedBlock = callback
        self.addTarget(self, action: #selector(JJGTextField.textChanged(tf:)), for: .editingChanged)
   }
    
    func setMaxLength(_ length:Int!) -> Void {
        limitLength = length
        self.addTarget(self, action: #selector(JJGTextField.textChanged(tf:)), for: .editingChanged)
    }
    
    // 输入验证
    func validateInput()-> Bool {
        if self.RegexCondition == nil {
           return true
        }
        
        let predicate = NSPredicate(format: " SELF MATCHES %@" , (self.RegexCondition?.rawValue)!)
        return predicate.evaluate(with:self.text)
    }
    
    @objc private func textChanged(tf:JJGTextField!) -> Void {
        // 无输入字数限制
        if limitLength == nil {
            if textChangedBlock != nil {
                textChangedBlock!(tf,false)
            }
            return
        }
        let toBeString:String? = self.text
        let language = self.textInputMode?.primaryLanguage
        print("当前文本输入法 ====== ",language ?? "" )
        var alert:Bool = false
        if language == "zh-Hans" || language == "zh-Hant" {
            //简体中文，繁体中文
            let selectedRange:UITextRange? = self.markedTextRange
            print("selectrange == ", selectedRange as Any)
              //获取高亮部分
              var position:UITextPosition?
              if selectedRange != nil {
                 position = self.position(from: selectedRange!.start, offset: 0)
              }
              // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
               if (position == nil) {
                  if ((toBeString?.count)! > limitLength!) {
                    self.text = String(toBeString!.prefix(limitLength!))
                    // 超出限制
                    alert = true
                }
                
                // 回调
                if textChangedBlock != nil {
                    textChangedBlock!(tf,alert)
                    
                }
            }
        }
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        else{
            if ((toBeString?.count)! > limitLength!) {
                self.text = String(toBeString!.prefix(limitLength!))
                // 超出限制
                alert = true
            }
            
            // 回调
            if textChangedBlock != nil {
                textChangedBlock!(tf,alert)
                
            }
        }
        
        // test
        print(self.validateInput())
    }
    
//    override func drawText(in rect: CGRect) {
//        super.drawText(in: UIEdgeInsetsInsetRect(rect, self.edgeInset))
//    }
    
    deinit {
        print("textfiled deinit")
    }
}

// MARK: - +++++++++++++++++ tableviewCell ++++++++++++++++++++
protocol TableViewCellConfig where Self: UITableViewCell {
    associatedtype T
    @discardableResult mutating func config(data:T) -> CGFloat
}


class HzzCell:UITableViewCell, TableViewCellConfig {
    
    typealias T = Any
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func config(data: HzzCell.T) -> CGFloat {
        
        return 0
    }
}


// MARK: - +++++++++++++++++ tableviewDelegate ++++++++++++++++++++
class  JJGTableViewDelegate<T:TableViewCellConfig> :NSObject,
                                                    UITableViewDelegate,
                                                    UITableViewDataSource {
    private weak var table:UITableView?
    private let className:String = NSStringFromClass(T.self)
    private var cellSelectHandler: ((_:T, _:T.T) -> Void)?
    // 补充otherConfigs
    var otherCellConfigs:((_:T, IndexPath) -> Void)?
    private var lineSpace:CGFloat!
    private var isFooter:Bool!
    private var useXib:Bool = false
    // 动态高度
    private var dynamicCellHeight:Bool = false
    private var templateCell:T?
    
    var dataSource:[T.T] = [] {
        didSet {
            self.table?.reloadData()
        }
    }
    
    var cellHeights:[CGFloat] = []
    
    init(tableView:UITableView?,
         useXib:Bool = false,
         rowHeight:CGFloat = 50,
         selectHandler:((_:T, _:T.T) -> Void)?,
         lineSpace:CGFloat = 0.0,
         isFooter:Bool = true,
         isDynamicCellHeight:Bool = false) {
        
        super.init()
        self.lineSpace = lineSpace
        self.isFooter = isFooter
        self.dynamicCellHeight = isDynamicCellHeight
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.rowHeight = rowHeight
        tableView?.tableFooterView = UIView.init()
        self.table = tableView
        self.cellSelectHandler = selectHandler
        self.useXib = useXib
        if useXib {
            self.table?.register(UINib.init(nibName: className.components(separatedBy:".").last!, bundle: nil), forCellReuseIdentifier: className)
        }else {
            self.table?.register(T.self, forCellReuseIdentifier: className)
        }
        
        if self.dynamicCellHeight {
            self.templateCell = self.table?.dequeueReusableCell(withIdentifier: className) as? T
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.lineSpace!>CGFloat(0.0) {
            return 1
        }
        return self.dataSource.count
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.lineSpace!>CGFloat(0.0) {
            return self.dataSource.count
        }
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: self.className, for: indexPath)
        
        if self.otherCellConfigs != nil {
            self.otherCellConfigs!(newCell as! T, indexPath)
        }
        return newCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var newCell = cell as! T
        if self.lineSpace!>CGFloat(0.0) {
            newCell.config(data:self.dataSource[indexPath.section])
            return
        }
        
        newCell.config(data:self.dataSource[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.cellSelectHandler != nil {
            let cell = tableView.cellForRow(at: indexPath) as! T
            
             if self.lineSpace!>CGFloat(0.0) {
                 self.cellSelectHandler!(cell, self.dataSource[indexPath.section])
                 return
            }
            
            
            self.cellSelectHandler!(cell, self.dataSource[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.lineSpace!>CGFloat(0.0) && self.isFooter {
            let view = UIView.init(frame: CGRect(x:0,y:0,width:kScreenWidth, height:self.lineSpace!))
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.isFooter == false {
            return 0
        }
        return self.lineSpace!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.lineSpace!>CGFloat(0.0) && self.isFooter == false {
            let view = UIView.init(frame: CGRect(x:0,y:0,width:kScreenWidth, height:self.lineSpace!))
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.isFooter == true {
            return 0
        }
        return self.lineSpace!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.templateCell == nil {
            return tableView.rowHeight
        }
        
        var cellHeight:CGFloat = 0
        if self.lineSpace!>CGFloat(0.0) {
           cellHeight = self.templateCell!.config(data:self.dataSource[indexPath.section])
        }else {
           cellHeight = self.templateCell!.config(data:self.dataSource[indexPath.row])
        }
        
        if self.useXib == false {
            return cellHeight
        }
        
       let fitHeight = self.templateCell!.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
           HzzLog(message: "cellHeight ====== \(fitHeight)")
       return fitHeight + 1.0
        
    }
    
}

// MARK: - +++++++++++++++++ collectionviewCell ++++++++++++++++++++
protocol CollectionViewCellConfig where Self: UICollectionViewCell {
    associatedtype T
    mutating func config(data:T)
}

// MARK: - +++++++++++++++++ collectionviewDelegate ++++++++++++++++++++
class  JJGCollectionViewDelegate<T:CollectionViewCellConfig> :NSObject,
    UICollectionViewDelegate,
    UICollectionViewDataSource  {
    private weak var collectionView:UICollectionView?
    private let className:String = NSStringFromClass(T.self)
    private var cellSelectHandler: ((_:T, _:T.T) -> Void)?
    // 补充otherConfigs
    private var otherCellConfigs:((_:T, IndexPath) -> Void)?
    var dataSource:[T.T] = [] {
        didSet {
            self.collectionView?.reloadData()
        }
    }
    
    init(collectionView:UICollectionView?,
         useXib:Bool = false,
         selectHandler:((_:T, _:T.T) -> Void)?,
         otherConfigs:((_:T, IndexPath) -> Void)? = nil) {
        
        super.init()
        collectionView?.delegate = self
        collectionView?.dataSource = self
        self.collectionView = collectionView
        self.cellSelectHandler = selectHandler
        self.otherCellConfigs = otherConfigs
        
        if useXib {
            self.collectionView?.register(UINib.init(nibName: className.components(separatedBy:".").last!, bundle: nil), forCellWithReuseIdentifier: className)
        }else {
            self.collectionView?.register(T.self, forCellWithReuseIdentifier: className)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let newCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.className, for: indexPath)
        
        if self.otherCellConfigs != nil {
            self.otherCellConfigs!(newCell as! T, indexPath)
        }
        return newCell
    
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var newCell = cell as! T
        newCell.config(data:self.dataSource[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.cellSelectHandler != nil {
            let cell = collectionView.cellForItem(at: indexPath) as! T
            self.cellSelectHandler!(cell, self.dataSource[indexPath.row])
        }
    
    }
    
}

// MARK: - ++++++++++++++ UIColor +++++++++++++++
extension UIColor {
    class func colorWithString(hex:String,alpha:CGFloat = 1.0) -> UIColor {
        var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if cString.hasPrefix("#"){
            let index   = cString.index(cString.startIndex, offsetBy: 1)
            cString     = String(cString.prefix(upTo: index))
        }
        if cString.count != 6 {
            return UIColor.red
        }
        
        let rIndex      = cString.index(cString.startIndex, offsetBy: 2)
        let rString     = cString.prefix(upTo: rIndex)
        let otherString = cString.suffix(from: rIndex)
        let gIndex      = otherString.index(otherString.startIndex, offsetBy: 2)
        let gString     = otherString.prefix(upTo: gIndex)
        let bIndex      = cString.index(cString.endIndex, offsetBy: -2)
        let bString     = cString.suffix(from: bIndex)
        
        var r:CUnsignedInt  = 0,g:CUnsignedInt = 0 ,b:CUnsignedInt = 0
        Scanner(string: String(rString)).scanHexInt32(&r)
        Scanner(string: String(gString)).scanHexInt32(&g)
        Scanner(string: String(bString)).scanHexInt32(&b)
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
   }
    
}

// MARK: - +++++++++++++++UIImage++++++++++++++
extension UIImage {
    class func imageWithColor(color:UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor);
        context.fill(rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    
}


// MARK: - +++++++++++++SegmentView++++++++++++
class JJGSegmentView:HzzShadowView {
    var callBack: ((Int) -> Void)?
    var normalColor:UIColor!
    var selectColor:UIColor!
    var currentSeleted:Int = 0
    var titles:[String]!
    private var underLine: UIImageView!
    convenience init(frame:CGRect, titles:[String], normalColor:UIColor = UIColor.colorWithString(hex: "333333"), selectColor:UIColor = UIColor.black, callBack:@escaping ((Int) -> Void),
        initialIndex:Int = 0,
        attributeConfig:((String) -> (NSAttributedString))? = nil) {
        
        self.init(frame: frame, radius: 0, width: 0, height: 4)
        self.titles = titles
        self.selectColor = selectColor
        self.normalColor = normalColor
        self.callBack = callBack
        self.currentSeleted = initialIndex
        let itemW = frame.width/CGFloat(titles.count)
        let itemH = frame.height
        var index:CGFloat = 0
        for title in titles {
            let actionBtn:UIButton = UIButton.init(type: .custom)
            actionBtn.frame = CGRect(x:index * itemW,y:0, width:itemW, height:itemH)
            actionBtn.backgroundColor = UIColor.white
            actionBtn.addTarget(self, action: #selector(JJGSegmentView.switchSelection(sender:)), for:.touchUpInside)
            actionBtn.tag = 100 + (titles.index(of: title))!
            actionBtn.titleEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, 0)
            
            if attributeConfig == nil {
               actionBtn.setTitle(title, for: .normal)
//               actionBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            }else {
                actionBtn.titleLabel?.textAlignment = .center
                actionBtn.setAttributedTitle(attributeConfig!(title), for: .normal)
            }
            
            actionBtn.titleLabel?.numberOfLines = 0
            if title == titles[initialIndex] {
                actionBtn.setTitleColor(selectColor, for: UIControlState.normal)
                actionBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            }else {
                actionBtn.setTitleColor(normalColor, for: UIControlState.normal)
                actionBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            }
            self.addSubview(actionBtn)
            index = index + 1.0
        }
        
        self.underLine = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 2))
        self.underLine.backgroundColor = HexColor("F7921E")
        self.addSubview(self.underLine)
        self.underLine.setCenterX(CGFloat(self.currentSeleted) * itemW + 0.5 * itemW)
        self.underLine.setBottom(self.bounds.height - 10)
        
        
        if self.callBack != nil {
            self.callBack!(self.currentSeleted)
        }
        
        
    }
    
    @objc func switchSelection(sender:UIButton) {
        
        let index = sender.tag - 100
        if index == self.currentSeleted {
            return
            
        }
        
        for subView in self.subviews {
            if subView is UIButton {
                let subBtn = subView as! UIButton
                   if subBtn != sender {
                      subBtn.setTitleColor(normalColor, for: UIControlState.normal)
                      subBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                  }else {
                     subBtn.setTitleColor(selectColor, for: UIControlState.normal)
                     subBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
                }
            }
        }
    
        self.currentSeleted = index
        
         let itemW = self.frame.width/CGFloat(titles.count)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.underLine.setCenterX(CGFloat(self.currentSeleted) * itemW + 0.5 * itemW)
        }, completion: nil)
        
        if self.callBack != nil {
            self.callBack!(self.currentSeleted)
        }
    }
    
    func updateByPageindex(_ index:Int) {
        if index == self.currentSeleted {
            return
            
        }
        
        for subView in self.subviews {
            if subView is UIButton {
                let subBtn = subView as! UIButton
                if subBtn.tag - 100 != index {
                    subBtn.setTitleColor(normalColor, for: UIControlState.normal)
                    subBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                }else {
                    subBtn.setTitleColor(selectColor, for: UIControlState.normal)
                    subBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
                }
            }
        }
        
        self.currentSeleted = index
        
        let itemW = self.frame.width/CGFloat(titles.count)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.underLine.setCenterX(CGFloat(self.currentSeleted) * itemW + 0.5 * itemW)
        }, completion: nil)
    
    }
    
}

// MARK: - +++++++++++++分页加载控制++++++++++++
enum PageLoadResult:Int {
    case LoadMore = 0;
    case NoData = 1;
    case NoMore = 2;
}

class pageLoadingControll:NSObject {
    private var pageVolumn:Int
    private var callBack:((PageLoadResult) -> Void)?
    var currentPage:Int = 0
    
    init(volumn:Int = 10, loadResultHandler:((PageLoadResult) -> Void)?) {
        pageVolumn = volumn
        callBack = loadResultHandler
    }
    
    func updateWithNewPage(arr:[Any]) {
        if callBack == nil {
            return;
        }
        
        if arr.count == 0 {
            if currentPage == 0 {
                callBack!(.NoData)
                
            }else {
                callBack!(.NoMore)
            }
        }else {
            if arr.count < pageVolumn {
                callBack!(.NoMore)
            }else {
                callBack!(.LoadMore)
            }
        }
    }
}

class JJGTextView:UITextView, UITextViewDelegate {
    private var placeHolderStr:String?
    private var label:UILabel?
    private var remainTip:UILabel?
    private var limitLength:Int?
    private var textChangedBlock:((_ tv: UITextView, _ alert:Bool) -> Void)?
    
    func set(_ placeHolder:String?, showStastic:Bool = true)  {
        placeHolderStr = placeHolder
        if  self.label == nil {
            self.label = UILabel.init(frame: CGRect(x:self.textContainerInset.left,y:self.textContainerInset.top,width:200,height:20))
            self.label?.font = self.font
            self.label?.textColor = UIColor.colorWithString(hex: "999999")
            self.addSubview(self.label!)
        }
        self.label?.text = placeHolder
        self.label?.sizeToFit()
        
        if  self.remainTip == nil && showStastic == true {
            self.remainTip = UILabel.init(frame: CGRect(x:self.bounds.width - 120,y:self.bounds.height - 15,width:115,height:10))
            self.remainTip?.textAlignment = .right
            self.remainTip?.font = UIFont.systemFont(ofSize: 10)
            self.remainTip?.textColor = UIColor.colorWithString(hex: "999999")
            self.addSubview(self.remainTip!)
        }
        
    }
    
    func setText(maxLength:Int!, callback:((UITextView, Bool) -> Void)? ) {
        limitLength = maxLength
        textChangedBlock = callback
        self.delegate = self

    }
    
    func set(maxLength:Int!) {
        limitLength = maxLength
        self.delegate = self
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // 无输入字数限制
        if limitLength == nil {
            if textChangedBlock != nil {
                self.label?.isHidden = textView.text.count != 0
                self.remainTip?.text = "\(textView.text.count)/\(limitLength!)"
                textChangedBlock!(textView,false)
            }
            return
        }
        let toBeString:String? = self.text
        let language = self.textInputMode?.primaryLanguage
        print("当前文本输入法 ====== ",language ?? "" )
        var alert:Bool = false
        if language == "zh-Hans" || language == "zh-Hant" {
            //简体中文，繁体中文
            let selectedRange:UITextRange? = self.markedTextRange
            print("selectrange == ", selectedRange as Any)
            //获取高亮部分
            var position:UITextPosition?
            if selectedRange != nil {
                position = self.position(from: selectedRange!.start, offset: 0)
            }
            // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if (position == nil) {
                if ((toBeString?.count)! > limitLength!) {
                    self.text = String(toBeString!.prefix(limitLength!))
                    // 超出限制
                    alert = true
                }
                
                // 回调
                if textChangedBlock != nil {
                    textChangedBlock!(textView,alert)
                    
                }
            }
        }
            // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        else{
            if ((toBeString?.count)! > limitLength!) {
                self.text = String(toBeString!.prefix(limitLength!))
                // 超出限制
                alert = true
            }
            
            // 回调
            if textChangedBlock != nil {
                textChangedBlock!(textView,alert)
                
            }
            
        }
        
         self.label?.isHidden = textView.text.count != 0
         self.remainTip?.text = "\(textView.text.count)/\(limitLength!)"
        
        // 回调
//        if textChangedBlock != nil {
//            textChangedBlock!(textView,alert)
//
//        }
    }
    
}




protocol NineSquareDelegate:class {
    func didClickPhoto(index:Int, isAdd:Bool, view:UIView)
    func updateViewSize(withH:CGFloat, view:UIView)
}

class  JJGNineSquareView : UIView {
    weak var delegate:NineSquareDelegate?
    let MaxNum = 2
    private let itemSpace:CGFloat = 10
    private let itemSize = CGSize.init(width: (kScreenWidth - 30  - 20 - 10)/2.0, height: (kScreenWidth - 30 - 20 - 10)/2.0)
    private var viewW:CGFloat = kScreenWidth - 20 - 30
    private var innerDataSource:[UIImage]?
    private var isFull:Bool {
        get {
            return (innerDataSource?.count)! >=  MaxNum
            
        }
    }
    var dataSource:[UIImage]? {
        set {
            if newValue == nil {
                return
            }
            innerDataSource = newValue
            self.update()
        }
        get {
            return innerDataSource
        }
        
    }
    
    private func update() {
        for i in 0..<(self.isFull ? (innerDataSource!.count): (innerDataSource!.count + 1)) {
            var imageView:UIImageView? = self.viewWithTag(100 + i) as? UIImageView
            let hNum:CGFloat = (viewW + itemSpace) / (itemSpace + itemSize.width)
            
            if imageView == nil {
                imageView = UIImageView.init(frame: CGRect(
                    x: (CGFloat(i%Int(hNum)) * (itemSize.width + itemSpace)),
                    y:( CGFloat(i/Int(hNum)) * (itemSize.height + itemSpace)),
                    
                    width: itemSize.width,
                    height: itemSize.height))
                
                HzzLog(message: "frame ==== \(String(describing: imageView?.frame))")
                
                imageView?.backgroundColor = UIColor.green
                imageView?.tag = 100 + i
                imageView?.touchCallback = { [weak self] view in
                    if self?.delegate != nil {
                        self?.delegate!.didClickPhoto(index: i, isAdd: i == self?.innerDataSource?.count && self?.isFull == false, view:self!)
                        
                    }
                }
                imageView?.backgroundColor = UIColor.green
                self.addSubview(imageView!)
                
            }
            
            if i == innerDataSource!.count {
                // 加号
                imageView?.image = UIImage.init(named: "img-S")
                self.setHeight(h: (imageView?.frame.maxY)!)
                if self.delegate != nil {
                    self.delegate!.updateViewSize(withH: self.frame.height, view:self)
                }
                
            }else {
                // 普通
                imageView?.image = innerDataSource! [i]
            }
        }
    }
    
    func removePic(index:Int) {
        innerDataSource?.remove(at: index)
        self.subviews.last?.removeFromSuperview()
        self.update()
    }
    
    
    func clearAll()  {
        innerDataSource?.removeAll()
        for subView in self.subviews {
          subView.removeFromSuperview()
        }
        self.update()
    }
    
    func update(withArr:[UIImage]) {
        innerDataSource?.append(contentsOf: withArr)
        self.update()
        
    }
    
    func remainCountToChoose () -> Int {
        return MaxNum - (innerDataSource?.count)!
        
    }
    
    override func awakeFromNib() {
        //        viewW = self.frame.width
    }
}


//
//  JJGConstants.swift
//  JiaJuGe
//
//  Created by 罗心恺 on 2017/12/27.
//  Copyright © 2017年 罗心恺. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftyJSON

let kScreenHeight = UIScreen.main.bounds.size.height
let kScreenWidth = UIScreen.main.bounds.size.width
let kThemeColor =  HexColor("34A6AB")
let kTitleColor =  UIColor.black
let kContentColor = HexColor("333333")
let kTipColor = HexColor("999999")
let kThemeTitleColor = HexColor("236274")
let kNavHeight:CGFloat = (kScreenHeight == 812.0 ? 88 : 64)
let kBgColor = UIColor.init(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)

var customerService = String.getLocalStore(identifier: "customerService")
let kHzzLoginTimeOut = "HzzLoginTimeOut"
let kHzzLogout = "HzzLogout"

func RGBCOLOR(r:CGFloat,_ g:CGFloat,_ b:CGFloat,_ a:CGFloat = 1.0) -> UIColor {
    return UIColor(red: (r)/255.0, green: (g)/255.0, blue: (b)/255.0, alpha: a)
}

func HexColor(_ hex:String, _ alpha:CGFloat = 1) -> UIColor {
    var cString = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
    if cString.hasPrefix("#"){
        let index   = cString.index(cString.startIndex, offsetBy: 1)
        cString     = String(cString.prefix(upTo: index))
    }
    if cString.count != 6 {
        return UIColor.white
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

enum InputRegexs:String {
    case NumberOnly  = "[0-9]*";
    case ChineseOnly = "[\u{4e00}-\u{9fa5}]+"
    case EnglishOnlyRegex = "[A-Za-z]*"
    case LettersOrNumbers = "[a-zA-Z0-9]*"
    case Email  = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9,-]+\\.[A-Za-z]{2,6}"
    case Mobile  = "(13|14|18|15|17)\\d{9}"
    case Phone = "0(10|2[0-5789]|\\d{3})\\d{7,8}$"
    case PassWord = "[a-zA-Z0-9_]{6,20}$"
    case SmsCode = "[0-9]{6}"
}


func HzzLog<T>(message: T, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line)
{
    #if DEBUG
        // 要把路径最后的字符串截取出来
        let fName = ((fileName as NSString).pathComponents.last!)
        print("fileName ==== \(fName).functionName ===== \(methodName) lineNum ====== [\(lineNumber)]: \(message)")
    #endif
}





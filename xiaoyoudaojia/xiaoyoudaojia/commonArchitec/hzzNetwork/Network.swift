//
//  Network.swift
//  HzzApi
//
//  Created by 罗心恺 on 2017/12/25.
//  Copyright © 2017年 罗心恺. All rights reserved.
//

import Foundation
import Moya
import Alamofire
import SwiftyJSON
import ObjectMapper
import SVProgressHUD

//自签名网站地址
let selfSignedHosts = ["域名","IP地址"]
//
typealias SuccessClosure = (_ result: AnyObject) -> Void
typealias FailClosure = ((_ errorMsg: String?) -> Void)?

// api enum
enum HzzApi {
    case uploadPhoto(data:Data)
    case getSmsCode(phone:String)
    case userLogin(phone:String, password:String)
    case modifyPassword(old:String, new:String)
    case userCenter()
    
}

extension HzzApi:TargetType {
    var baseURL: URL {
        return URL(string:
            "http://xyapi.test.sclonsee.cn")!
    }
    
    var path: String {
        switch self {
          case .uploadPhoto(_):
            return "/v1/delivery/upload"
            
            // 短信验证码
          case .getSmsCode(_ ) :
             return "/v1/member/smsre"
            // 登录
          case .userLogin(_, _):
              return "/v1/member/login"
            // 修改密码
           case .modifyPassword(_, _):
              return "/v1/member/update-password"
            // 个人中心
            case .userCenter():
              return "/v1/member/info"
            
        }
    }
    
    /// The HTTP method used in the request.
    var method: Moya.Method  {
        switch self {
        case.userCenter():
            return .get
          default:
            return .get
        }
    }
        
    var sampleData: Data {
            return "Create post successfully".data(using: String.Encoding.utf8)!
    }
        
    var task: Task {
        var param:[String:Any] = [:]
        if HzzBaseUser.sharedIUser.isLogin() {
            param["accessToken"] = HzzBaseUser.sharedIUser.token
        }
        
        switch self {
          // 图片上传
         case .uploadPhoto(let data):
            let formData = Moya.MultipartFormData.init(provider: .data(data), name: "UploadForm[file]", fileName: "first.jpeg", mimeType: "image/jpeg")
        
            return .uploadMultipart([formData])
            
         // 短信验证码
         case .getSmsCode(let phone):
            param["phone"] = phone
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
            
          // 用户登录
          case .userLogin(let phone, let password):
            param["phone"] = phone
            param["password"] = password
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
          // 修改密码
          case .modifyPassword(let old, let new):
            param["oldpassword"] = old
            param["password"]  = new
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
            
          // 个人中心
          case .userCenter():
            return .requestParameters(parameters: param, encoding: URLEncoding.default)
            
        }
    }
        
    var headers: [String: String]? {
        return nil
    }
        
    var validate: Bool {
        return true
    }
    
    //  显示加载动画
    var showLoading:Bool {
        switch self {
        case .uploadPhoto(_):
            return false
         default:
            return true
        }
    }
}

// requestManager
enum RequestCode:Int {
    case success = 0
    case loginTimeout = 403
}

class HzzNetworkManager {
    static   let sharedInstance = HzzNetworkManager()
    
    fileprivate var token:String?
    
    fileprivate   var requestProvider:MoyaProvider<HzzApi>
  
    
    private init(){
        let requestTimeoutClosure = { (endpoint: Endpoint<HzzApi>, done: MoyaProvider<HzzApi>.RequestResultClosure) in
            
            do {
            
               var request = try endpoint.urlRequest()
               request.timeoutInterval = 15
    
                done(.success(request))
            }
            
            catch MoyaError.requestMapping(let url) {
                done(.failure(MoyaError.requestMapping(url)))
            } catch MoyaError.parameterEncoding(let error) {
                done(.failure(MoyaError.parameterEncoding(error)))
            } catch {
                done(.failure(MoyaError.underlying(error, nil)))
            }
            
        }
        
        self.requestProvider =  MoyaProvider<HzzApi>.init(endpointClosure: MoyaProvider.defaultEndpointMapping, requestClosure: requestTimeoutClosure, stubClosure: MoyaProvider.neverStub, callbackQueue: nil, manager: MoyaProvider<HzzApi>.defaultAlamofireManager(), plugins: [], trackInflights: false)
        
        //认证相关设置
        let manager = self.requestProvider.manager
        manager.delegate.sessionDidReceiveChallenge = { session, challenge in
            //认证服务器（这里不使用服务器证书认证，只需地址是我们定义的几个地址即可信任）
            if challenge.protectionSpace.authenticationMethod
                == NSURLAuthenticationMethodServerTrust
                && selfSignedHosts.contains(challenge.protectionSpace.host) {
                print("服务器认证！")
                let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                return (.useCredential, credential)
            }
                //认证客户端证书
            else if challenge.protectionSpace.authenticationMethod
                == NSURLAuthenticationMethodClientCertificate {
                print("客户端证书认证！")
                //获取客户端证书相关信息
                let identityAndTrust:IdentityAndTrust = self.extractIdentity();
                let urlCredential:URLCredential = URLCredential(
                    identity: identityAndTrust.identityRef,
                    certificates: identityAndTrust.certArray as? [AnyObject],
                    persistence: URLCredential.Persistence.forSession);
                
                return (.useCredential, urlCredential);
            }
                // 其它情况（不接受认证）
            else {
                print("其它情况（不接受认证）")
                return (.cancelAuthenticationChallenge, nil)
            }
        }
    }
    
    // MARK: - 业务API
    
    func requestDataWithTarget(target: HzzApi, successClosure: @escaping SuccessClosure, failClosure: FailClosure) {
        
        DispatchQueue.global().async {
            
          // 加载动画
          if target.showLoading == true {
            DispatchQueue.main.async {
                SVProgressHUD.show()
            }
          }
            
             HzzLog(message: "====== 请求数据 ======== \(target.task)\n ======== 路径 =============\(target.baseURL.absoluteString)\(target.path)")
        
            let _ = self.requestProvider.request(target, callbackQueue: DispatchQueue.main, progress: nil, completion: { (result) -> Void in
            
            if target.showLoading == true {
                SVProgressHUD.dismiss()
            }
            
            switch result {
            case .success(let response):
                let jsonDic = JSON(response.data).object
                
                HzzLog(message: "====== 接口返回数据 ======== \(jsonDic)")
                
                let info = Mapper<CommonInfo>().map(JSONObject: jsonDic)
                guard info?.result1 == RequestCode.success.rawValue else {
                    
                // 登录过期
                    if info?.result1 == RequestCode.loginTimeout.rawValue  {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kHzzLoginTimeOut), object: nil)
                        }
                        return
                    }
                    
                SVProgressHUD.showMessage(info?.msg)
                    if (info?.msg != nil) {
                       failClosure?(info?.msg)
                    }
                    return
                }
                guard let data = info?.data else {
                    failClosure?("数据为空")
                    return
                }
                successClosure(data)
                
                
            case .failure(let error):
                HzzLog(message:("网络请求失败...\(error)"))
                
                if error.response?.statusCode == 403 {
                     NotificationCenter.default.post(name: NSNotification.Name(rawValue: kHzzLoginTimeOut), object: nil)
                     return
                }
                
                SVProgressHUD.showMessage(error.localizedDescription)
                failClosure?(error.errorDescription)
                
           }
        })
       }
    }
    
    
    
    //获取客户端证书相关信息
    func extractIdentity() -> IdentityAndTrust {
        var identityAndTrust:IdentityAndTrust!
        var securityError:OSStatus = errSecSuccess
        
        let path: String = Bundle.main.path(forResource: "client", ofType: "p12")!
        let PKCS12Data = NSData(contentsOfFile:path)!
        let key : NSString = kSecImportExportPassphrase as NSString
        let options : NSDictionary = [key : "xxxxxxxx"] //客户端证书密码
        //create variable for holding security information
        //var privateKeyRef: SecKeyRef? = nil
        var items : CFArray?
        securityError = SecPKCS12Import(PKCS12Data, options, &items)
        if securityError == errSecSuccess {
            let certItems:CFArray = items as CFArray!;
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first;
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {
                // grab the identity
                let identityPointer:AnyObject? = certEntry["identity"];
                let secIdentityRef:SecIdentity = identityPointer as! SecIdentity!
                print("\(String(describing: identityPointer))  :::: \(secIdentityRef)")
                // grab the trust
                let trustPointer:AnyObject? = certEntry["trust"]
                let trustRef:SecTrust = trustPointer as! SecTrust
                print("\(String(describing: trustPointer))  :::: \(trustRef)")
                // grab the cert
                let chainPointer:AnyObject? = certEntry["chain"]
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef,
                                                    trust: trustRef, certArray:  chainPointer!)
            }
        }
        return identityAndTrust;
    }
}


class CommonInfo: Mappable {
    var data: AnyObject?
    var result1: Int?
    var msg: String?
 
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        data      <-    map["data"]
        result1      <-    map["code"]
        msg       <-    map["message"]
    }
}

extension SVProgressHUD {
    class func showMessage(_ message:String?,delay:TimeInterval = 2.0) {
        
        SVProgressHUD.showError(withStatus: message)
        SVProgressHUD.dismiss(withDelay: delay)
    }
    
}

//定义一个结构体，存储认证相关信息
struct IdentityAndTrust {
    var identityRef:SecIdentity
    var trust:SecTrust
    var certArray:AnyObject
}




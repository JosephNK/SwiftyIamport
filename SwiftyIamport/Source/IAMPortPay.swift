//
//  IAMPortPay.swift
//  SwiftIamport
//
//  Created by JosephNK on 2017. 4. 20..
//  Copyright © 2017년 JosephNK. All rights reserved.
//

import UIKit
import WebKit

public typealias IAMPortParameters = [String: Any]

public enum IAMPortPGType: String {
    case html5_inicis   = "html5_inicis"  // (이니시스웹표준)
    case inicis         = "inicis"        // (이니시스ActiveX결제창)
    case uplus          = "uplus"         // (LGU+)
    case nice           = "nice"          // (나이스페이)
    case jtnet          = "jtnet"         // (JTNet)
    case kakao          = "kakao"         // (카카오페이)
    case danal          = "danal"         // (다날휴대폰소액결제)
    case danal_tpay     = "danal_tpay"    // (다날일반결제)
    case mobilians      = "mobilians"     // (모빌리언스 휴대폰소액결제)
    case syrup          = "syrup"         // (시럽페이)
    case payco          = "payco"         // (페이코)
    case paypal         = "paypal"        // (페이팔)
    case eximbay        = "eximbay"       // (엑심베이)
}

public enum IAMPortPayMethod: String {
    case card           = "card"          // (신용카드)
    case trans          = "trans"         // (실시간계좌이체)
    case vbank          = "vbank"         // (가상계좌)
    case phone          = "phone"         // (휴대폰소액결제)
    case samsung        = "samsung"       // (삼성페이 / 이니시스 전용)
    case kpay           = "kpay"          // (KPay앱 직접호출 / 이니시스 전용)
    case cultureland    = "cultureland"   // (문화상품권 / 이니시스 전용)
    case smartculture   = "smartculture"  // (스마트문상 / 이니시스 전용)
    case happymoney     = "happymoney"    // (해피머니 / 이니시스 전용)
}

public enum IAMPortPayType {
    case bankpay
    case isp
}

public enum IAMPortPayError: Error {
    case custom(reason: String)
    public static let pgType = IAMPortPayError.custom(reason: "pg 형식이 잘못되었습니다.")
    public static let payMethodType = IAMPortPayError.custom(reason: "pay_method 형식이 잘못되었습니다.")
    public static let notSupportType = IAMPortPayError.custom(reason: "해당 결제방식은 PG사에서 제공하지 않습니다.")
    public static let jsonType = IAMPortPayError.custom(reason: "JSON 형식이 잘못되었습니다.")
    public static let parametersNone = IAMPortPayError.custom(reason: "파라미터가 없습니다.")
    public static let domLoadType = IAMPortPayError.custom(reason: "DOM Load 중 오류가 발생하였습니다.")
    public static let runJavascriptType = IAMPortPayError.custom(reason: "JavaScript 실행 중 오류가 발생하였습니다.")
}

public class IAMPortPay {
    public static let sharedInstance = IAMPortPay()
    
    fileprivate(set) var pgType: IAMPortPGType?
    fileprivate(set) var payMethod: IAMPortPayMethod?
    fileprivate(set) var m_redirect_url: String? = nil
    
    fileprivate(set) weak var webView: UIWebView?
    fileprivate(set) weak var wkWebView: WKWebView?
    
    fileprivate(set) public var appScheme: String? = nil
    fileprivate(set) public var storeIdentifier: String? = nil
    fileprivate(set) public var nicePayBankPayUrlString: String? = nil
    fileprivate(set) public var parameters: IAMPortParameters? = nil
    fileprivate(set) public var pgIdName: String? = nil
    
    fileprivate(set) var addCancelHandler: (() -> Void)?
    
    public init() {}
    
    @discardableResult
    public func configure(scheme: String?) -> IAMPortPay {
        self.clear()
        
        self.appScheme = scheme
        
        return self
    }
    
    @discardableResult
    public func configure(scheme: String?, storeIdentifier: String?) -> IAMPortPay {
        self.clear()
        
        self.appScheme = scheme
        self.storeIdentifier = storeIdentifier
        
        return self
    }
    
    public func clear() {
        self.appScheme = nil
        self.storeIdentifier = nil
        self.pgType = nil
        self.pgIdName = nil
        self.payMethod = nil
        self.webView = nil
        self.parameters = nil
        self.m_redirect_url = nil
        
        self.nicePayBankPayUrlString = nil
        self.addCancelHandler = nil
    }
    
    @discardableResult
    public func setPGType(_ pgType: IAMPortPGType?) -> IAMPortPay {
        self.pgType = pgType
        
        return self
    }
    
    @discardableResult
    public func setIdName(_ pgIdName: String?) -> IAMPortPay {
        self.pgIdName = pgIdName
        
        return self
    }
    
    @discardableResult
    public func setPayMethod(_ payMethod: IAMPortPayMethod?) -> IAMPortPay {
        self.payMethod = payMethod
        
        return self
    }
    
    @discardableResult
    public func setParameters(_ parameters: IAMPortParameters?) -> IAMPortPay {
        self.parameters = parameters
        
        return self
    }
    
    @discardableResult
    public func setWebView(_ webView: UIWebView?) -> IAMPortPay {
        self.webView = webView
        
        return self
    }
    
    @discardableResult
    public func setWKWebView(_ webView: WKWebView?) -> IAMPortPay {
        self.wkWebView = webView
        
        return self
    }
    
    @discardableResult
    public func setRedirectUrl(_ m_redirect_url: String?) -> IAMPortPay {
        self.m_redirect_url = m_redirect_url
        
        return self
    }
    
    public func commit() {
        
    }
    
    public func urlFromLocalHtmlFile() -> URL? {
        if let storeIdentifier = self.storeIdentifier {
            let url = self.fileUrlLocalFile(forResource: "IAMPortPay", withExtension: "html")
            var urlString = url?.absoluteString ?? ""
            if urlString.isEmpty {
                return nil
            }
            urlString += ("?storeIdentifier=") + storeIdentifier
            return URL(string: urlString)
        }
        return nil
    }
    
    fileprivate func fileUrlLocalFile(forResource name: String?, withExtension: String?, subdirectory subpath: String? = nil) -> URL? {
        let frameworkBundle = Bundle(for: IAMPortPay.self)
        if let fileUrl = frameworkBundle.url(forResource: name, withExtension: withExtension, subdirectory: subpath) {
            return fileUrl
        }
        return nil
    }
}

// MARK: - Application Helper
public extension IAMPortPay {
    // for iOS below 9.0
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return self.applicationOpenUrl(url: url)
    }
    
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.applicationOpenUrl(url: url)
    }
    
    fileprivate func applicationOpenUrl(url: URL) -> Bool {
        return self.applicationOpenUrlForNicePay(url: url)
    }
}

// MARK: - WebView Delegate Helper
public extension IAMPortPay {
    @available(*, deprecated, message: "Use: requestRedirectUrl method")
    public func webViewRedirectUrl(shouldStartLoadWith request: URLRequest, parser: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Any?, completion: @escaping (_ pasingData: Any?) -> Void) {
        self.requestRedirectUrl(for: request, parser: parser, completion: completion)
    }
    
    @available(*, deprecated, message: "Use: requestAction method")
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        return self.requestAction(for: request)
    }
    
    public func requestRedirectUrl(for request: URLRequest, parser: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Any?, completion: @escaping (_ pasingData: Any?) -> Void) {
        let urlString = request.url?.absoluteString ?? ""
        if let redirect_url = self.m_redirect_url {
            if urlString.hasPrefix(redirect_url) {
                let task = URLSession.shared.dataTask(with: request.url!) { data, response, error in
                    let pasingData = parser(data, response, error)
                    DispatchQueue.main.async {
                        completion(pasingData)
                    }
                }
                task.resume()
            }
        }
    }
    
    public func requestAction(for request: URLRequest) -> Bool {
        guard let url = request.url else {
            return false
        }
        
        let urlString = url.absoluteString
        
        #if DEBUG
        print("### requestAction request url: \(urlString)")
        #endif
        
        // app store URL 여부 확인
        let bAppStoreURL1 = urlString.range(of: "phobos.apple.com", options: String.CompareOptions.caseInsensitive)
        let bAppStoreURL2 = urlString.range(of: "itunes.apple.com", options: String.CompareOptions.caseInsensitive)
        if (bAppStoreURL1 != nil) || (bAppStoreURL2 != nil) {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                return false
            }
        }
        
        if !url.absoluteString.hasPrefix("http://") && !url.absoluteString.hasPrefix("https://") {
            if UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                return false
            }
        }
        
        return self.webViewRequestWithForNicePay(request: request)
    }
    
    public func requestIAMPortPayWebViewDidFinishLoad(_ webView: UIWebView, completion: @escaping (_ error: IAMPortPayError?) -> Void) {
        if webView.stringByEvaluatingJavaScript(from: "document.readyState") == "complete" {
            let url = webView.request?.url
            
            #if DEBUG
            print("### dom ready!! \(String(describing: url?.absoluteString ?? ""))")
            #endif
            
            let c = url?.absoluteString.contains("IAMPortPay.html") ?? false
            if c == false { return }
            
            let result = self.makeParameters(for: url)
            
            if let error = result.error {
                return completion(error)
            }
            
            if let param = result.param {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                    let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                    webView.stringByEvaluatingJavaScript(from: String(format: "requestIAMPortPay(%@)", jsonString))
                } catch {
                    completion(IAMPortPayError.jsonType)
                    return
                }
                
                completion(nil)
            }
        }
    }
    
    public func requestIAMPortPayWKWebViewDidFinishLoad(_ wkWebView: WKWebView, completion: @escaping (_ error: IAMPortPayError?) -> Void) {
        wkWebView.evaluateJavaScript("document.readyState == \"complete\"") { (any, error) in
            let url = wkWebView.url
            
            #if DEBUG
            print("### dom ready!! \(String(describing: url?.absoluteString ?? ""))")
            #endif
            
            let c = url?.absoluteString.contains("IAMPortPay.html") ?? false
            if c == false { return }
            
            if error != nil {
                return completion(IAMPortPayError.domLoadType)
            }
            
            let result = self.makeParameters(for: url)
            
            if let error = result.error {
                return completion(error)
            }
            
            if let param = result.param {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
                    let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                    wkWebView.evaluateJavaScript(String(format: "requestIAMPortPay(%@)", jsonString)) { (any, error) in
                        if error != nil {
                            completion(IAMPortPayError.runJavascriptType)
                            return
                        }
                        
                        completion(nil)
                    }
                } catch {
                    completion(IAMPortPayError.jsonType)
                    return
                }
            }
        }
    }
    
    public func setCancelListenerForNicePay(_ handler: (() -> Void)?) {
        self.addCancelHandler = handler
    }
    
}

fileprivate extension IAMPortPay {
    
    fileprivate func makeParameters(for url: URL?) -> (param: IAMPortParameters?, error: IAMPortPayError?) {
        if let currentURL = url?.absoluteString {
            #if DEBUG
            print("### WebView currentURL: \(currentURL)")
            #endif
            
            if currentURL.lowercased().hasPrefix("file://") {
                var param: IAMPortParameters = [:]
                
                guard let pgType = self.pgType else {
                    return (nil, IAMPortPayError.pgType)
                }
                let pgIdName = self.pgIdName ?? ""
                if pgIdName.isEmpty {
                    param["pg"] = pgType.rawValue
                }else {
                    param["pg"] = pgType.rawValue + "." + pgIdName
                }
                
                guard let payMethod = self.payMethod else {
                    return (nil, IAMPortPayError.payMethodType)
                }
                param["pay_method"] = payMethod.rawValue
                
                guard let parameters = self.parameters else {
                    return (nil, IAMPortPayError.parametersNone)
                }
                
                for (key, value) in parameters {
                    param[key] = value
                }
                
                if self.isNotSupportValidation(pgType, parameters) {
                    return (nil, IAMPortPayError.notSupportType)
                }
                
                let appScheme = self.appScheme ?? ""
                if !appScheme.isEmpty {
                    param["app_scheme"] = appScheme
                }
                
                let m_redirect_url = self.m_redirect_url ?? ""
                if !m_redirect_url.isEmpty {
                    param["m_redirect_url"] = m_redirect_url
                }
                
                #if DEBUG
                print("param: \(param)")
                #endif
                
                return (param, nil)
            }
        }
        
        return (nil, IAMPortPayError.parametersNone)
    }
    
    fileprivate func isNotSupportValidation(_ pgType: IAMPortPGType?, _ parameters: IAMPortParameters) -> Bool {
        if let pg = pgType, let pm = parameters["pay_method"] as? IAMPortPayMethod {
            var isNotSupport = false
            switch pg {
            case .html5_inicis:
                if !(pm == .card || pm == .trans || pm == .vbank || pm == .phone || pm == .samsung || pm == .kpay || pm == .cultureland || pm == .smartculture || pm == .happymoney) {
                    isNotSupport = true
                }
                break
            case .nice:
                if !(pm == .card || pm == .trans || pm == .vbank || pm == .phone) {
                    isNotSupport = true
                }
                break
            case .jtnet:
                if !(pm == .card || pm == .trans || pm == .vbank || pm == .phone) {
                    isNotSupport = true
                }
                break
            case .kakao:
                if !(pm == .card) {
                    isNotSupport = true
                }
                break
            case .danal:
                if !(pm == .phone) {
                    isNotSupport = true
                }
                break
            case .danal_tpay:
                if !(pm == .card || pm == .trans || pm == .vbank) {
                    isNotSupport = true
                }
                break
            case .mobilians:
                if !(pm == .phone) {
                    isNotSupport = true
                }
                break
            case .uplus:
                if !(pm == .card || pm == .trans || pm == .vbank || pm == .phone) {
                    isNotSupport = true
                }
                break
            case .paypal:
                if !(pm == .card) {
                    isNotSupport = true
                }
                break
            default:
                break
            }
            
            return isNotSupport
        }
        
        return false
    }
    
    fileprivate func applicationOpenUrlForNicePay(url: URL) -> Bool {
        var redirectURL = url.absoluteString
        
        #if DEBUG
        print("### redirectURL: \(String(describing: redirectURL.removingPercentEncoding!))")
        #endif
        
        let _appScheme = self.appScheme ?? ""
        if redirectURL.hasPrefix(_appScheme) {         //scheme 를 통한 호출 여부
            // 결제인증 후 복귀했을 때 후속조치를 하기 위해 각 수단별 URL을 추출하는 단계
            
            // (1) 실시간계좌이체 인증 후 추출된 주소를 통해 후속조치 함수 호출
            var range = redirectURL.range(of: "?bankpaycode")
            if range != nil {
                // 계좌이체인 경우  scheme + ? 로 리던 되어 "?" 도 함께 삭제 함.
                // iamporttest://?bankpaycode=xxxx ...." 에서 "bankpaycode=xxxx ...." 추출하기 위함
                let appSchemeAddtion = "\(_appScheme)?"
                redirectURL = String(redirectURL[appSchemeAddtion.endIndex...])
                #if DEBUG
                print("### bankpay redirectURL: \(redirectURL)")
                #endif
                
                self.requestBankPayResultForNicePay(self.webView, urlString: self.nicePayBankPayUrlString, bodyString: redirectURL)
                
                return true
            }
            
            // (2) ISP인증과정 도중 결제 취소를 선택한 경우 별도 처리
            range = redirectURL.range(of: "ISPCancel")      // ISP 취소인 경우
            if range != nil {
                
                if let handler = self.addCancelHandler {
                    handler()
                }
                
                return true
            }
            
            // (3) 추출된 주소를 통해 ISP결제 후속조치 함수 호출
            range = redirectURL.range(of: "ispResult.jsp")  // ISP 인증 후 결제 진행
            if range != nil {
                // ISP 경우 scheme + :// 로 리턴 되어 "://" 도 함께 삭제 함.
                // iamporttest://://http://web.nicepay.co.kr/smart/card/isp/ .... ispResult.jsp 에서
                // http://web.nicepay.co.kr/smart/card/isp/.... ispResult.jsp" 추출하기 위함
                let appSchemeAddtion = "\(_appScheme)://"
                redirectURL = String(redirectURL[appSchemeAddtion.endIndex...])
                #if DEBUG
                print("### isp redirectURL: \(redirectURL)")
                #endif
                
                self.requestISPPayResultForNicePay(self.webView, urlString: redirectURL)
                
                return true
            }
        }
        
        return true
    }
    
    fileprivate func webViewRequestWithForNicePay(request: URLRequest) -> Bool {
        let url = request.url
        let urlString = url?.absoluteString ?? ""
        
        // 계좌이체
        if urlString.hasPrefix("kftc-bankpay://") {
            if UIApplication.shared.canOpenURL(url!) {
                let isNiceSite = urlString.range(of: "nicepay.co.kr")
                let range = urlString.range(of: "callbackparam1=")
                if range != nil && isNiceSite != nil {
                    let _urlString = String(urlString[urlString.index(range!.lowerBound, offsetBy: "callbackparam1=".count)...])
                    
                    do {
                        let regex = try NSRegularExpression(pattern: "&(?!\\?)", options: .caseInsensitive)
                        let rangeOfFirstMatch = regex.rangeOfFirstMatch(in: _urlString,
                                                                        options: [],
                                                                        range: NSRange(location: 0, length: _urlString.count))
                        let bankPayUrlString = regex.stringByReplacingMatches(in: _urlString,
                                                                              options: [],
                                                                              range: rangeOfFirstMatch,
                                                                              withTemplate: "?")
                        self.nicePayBankPayUrlString = bankPayUrlString.removingPercentEncoding
                        #if DEBUG
                        print("nicePayBankPayUrlString: \(String(describing: self.nicePayBankPayUrlString!))")
                        #endif
                    } catch {
                        
                    }
                }
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)   //설치 되어 있을 경우 App 호출
                } else {
                    UIApplication.shared.openURL(url!)                                      //설치 되어 있을 경우 App 호출
                }
                return true
            }else {
                //설치 되어 있지 않다면 app store 연결
                return false
            }
        }
        
        return true
    }
    
    fileprivate func requestBankPayResultForNicePay(_ webView: UIWebView?, urlString: String?, bodyString: String?) {
        guard let webView = webView, let urlString = urlString, let bodyString = bodyString else {
            return
        }
        
        #if DEBUG
        print("### requestBankPayResultForNicePay call !!!")
        #endif
        
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyString.data(using: String.Encoding.utf8)
            webView.loadRequest(request)
        }
    }
    
    fileprivate func requestISPPayResultForNicePay(_ webView: UIWebView?, urlString: String?) {
        guard let webView = webView, let urlString = urlString else {
            return
        }
        
        #if DEBUG
        print("### requestISPPayResultForNicePay call !!!")
        #endif
        
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            webView.loadRequest(request)
        }
    }
    
}

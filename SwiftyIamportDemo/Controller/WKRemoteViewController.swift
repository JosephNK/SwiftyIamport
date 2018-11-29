//
//  WKRemoteViewController.swift
//  SwiftyIamportDemo
//
//  Created by JosephNK on 29/11/2018.
//  Copyright © 2018 JosephNK. All rights reserved.
//

import UIKit
import SwiftyIamport
import WebKit

class WKRemoteViewController: UIViewController {

    lazy var wkWebView: WKWebView = {
        var view = WKWebView()
        view.backgroundColor = UIColor.clear
        view.navigationDelegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(wkWebView)
        self.wkWebView.frame = self.view.bounds
        
        // 결제 환경 설정
        IAMPortPay.sharedInstance.configure(scheme: "iamporttest")  // info.plist에 설정한 scheme
        
        IAMPortPay.sharedInstance
            .setWKWebView(self.wkWebView)   // 현재 Controller에 있는 WebView 지정
            .setRedirectUrl(nil)            // m_redirect_url 주소
        
        // ISP 취소시 이벤트 (NicePay만 가능)
        IAMPortPay.sharedInstance.setCancelListenerForNicePay { [weak self]  in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: nil, message: "ISP 결제 취소", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
        
        // 결제 웹페이지(Remote) 호출
        if let url = URL(string: "http://www.iamport.kr/demo") {
            let request = URLRequest(url: url)
            self.wkWebView.load(request)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension WKRemoteViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        
        IAMPortPay.sharedInstance.requestRedirectUrl(for: request, parser: { (data, response, error) -> Any? in
            // Background Thread 처리
            var resultData: [String: Any]?
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                switch statusCode {
                case 200:
                    resultData = [
                        "isSuccess": "OK"
                    ]
                    break
                default:
                    break
                }
            }
            return resultData
        }) { (pasingData) in
            // Main Thread 처리
        }
        
        let result = IAMPortPay.sharedInstance.requestAction(for: request)
        decisionHandler(result ? .allow : .cancel)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 결제 환경으로 설정에 의한 웹페이지(Local) 호출 결과
        IAMPortPay.sharedInstance.requestIAMPortPayWKWebViewDidFinishLoad(webView) { (error) in
            if error != nil {
                switch error! {
                case .custom(let reason):
                    print("error: \(reason)")
                    break
                }
            }else {
                print("OK")
            }
        }
    }
    
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation \(error.localizedDescription)")
    }
    
}

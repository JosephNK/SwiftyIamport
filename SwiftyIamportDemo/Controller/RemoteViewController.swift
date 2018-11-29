//
//  RemoteViewController.swift
//  SwiftIamport
//
//  Created by JosephNK on 2017. 4. 21..
//  Copyright © 2017년 JosephNK. All rights reserved.
//

import UIKit
import SwiftyIamport

class RemoteViewController: UIViewController {

    lazy var webView: UIWebView = {
        var view = UIWebView()
        view.backgroundColor = UIColor.clear
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(webView)
        self.webView.frame = self.view.bounds
        
        // 결제 환경 설정
        IAMPortPay.sharedInstance.configure(scheme: "iamporttest")  // info.plist에 설정한 scheme
        
        IAMPortPay.sharedInstance
            .setWebView(self.webView)   // 현재 Controller에 있는 WebView 지정
            .setRedirectUrl(nil)        // m_redirect_url 주소
        
        // ISP 취소시 이벤트 (NicePay만 가능)
        IAMPortPay.sharedInstance.setCancelListenerForNicePay { [weak self] _ in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: nil, message: "ISP 결제 취소", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
        
        // 결제 웹페이지(Remote) 호출
        if let url = URL(string: "http://www.iamport.kr/demo") {
            let request = URLRequest(url: url)
            self.webView.loadRequest(request)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension RemoteViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        // 해당 함수는 redirecURL의 결과를 직접 처리하고 할 때 사용하는 함수 (IAMPortPay.sharedInstance.configure m_redirect_url 값을 설정해야함.)
        IAMPortPay.sharedInstance.requestRedirectUrl(for: request, parser: { (data, response, error) -> Any? in
            // Background Thread
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
            // Main Thread
        }
        
        return IAMPortPay.sharedInstance.requestAction(for: request)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // 직접 구현..
    }
}

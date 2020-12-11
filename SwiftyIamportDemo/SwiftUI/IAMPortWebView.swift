//
//  IAMPortWebView.swift
//  SwiftyIamportDemo
//
//  Created by Aaron Lee on 2020/12/08.
//  Copyright © 2020 Aaron Lee. All rights reserved.
//

import SwiftUI
import UIKit
import SwiftyIamport
import WebKit

@available(iOS 13.0, *)
struct IAMPortWebView: UIViewControllerRepresentable {
    
    @Binding var isPresented: Bool      // 모달, 풀스크린 시트에 이용할 수 있습니다.
    let paymentMethod: PaymentMethod    // 커스텀 열거형을 선언하여 동적으로 활용할 수 있습니다.
    
    /// 뷰 생성
    func makeUIViewController(context: Context) -> some UIViewController {
        let view = WKHtml5InicisViewControllerSwiftUI(isPresented: $isPresented, paymentMethod: paymentMethod)
        return view
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

@available(iOS 13.0, *)
class WKHtml5InicisViewControllerSwiftUI: UIViewController {
    
    @Binding var isPresented: Bool
    var paymentMethod: PaymentMethod
    
    var pgType: IAMPortPGType   // paymentMethod를 이용하여 PG사를 유동적으로 사용할 수 있습니다.
    
    init(isPresented: Binding<Bool>, paymentMethod: PaymentMethod) {
        self._isPresented = isPresented
        self.paymentMethod = paymentMethod
        
        switch paymentMethod {
        case .credit:
            self.pgType = .kcp
        case .kakao:
            self.pgType = .kakao
        case .naver:
            self.pgType = .naverpay
        }
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var wkWebView: WKWebView = {
        var view = WKWebView()
        view.backgroundColor = UIColor.clear
        view.navigationDelegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(wkWebView)
        self.wkWebView.frame = self.view.frame
        
        let safeAreaInsets = view.safeAreaInsets
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.topAnchor.constraint(equalTo: view.topAnchor, constant: safeAreaInsets.top).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: safeAreaInsets.bottom).isActive = true
        wkWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        wkWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        
        // 결제 환경 설정
        IAMPortPay.sharedInstance.configure(scheme: "iamportPay",              // info.plist에 설정한 scheme
                                            storeIdentifier: "imp24420581")     // iamport 에서 부여받은 가맹점 식별코드
        
        IAMPortPay.sharedInstance
            .setPGType(self.pgType)               // PG사 타입
            .setIdName(nil)                         // 상점아이디 ({PG사명}.{상점아이디}으로 생성시 사용)
            .setPayMethod(.card)                    // 결제 형식
            .setWKWebView(self.wkWebView)           // 현재 Controller에 있는 WebView 지정
            .setRedirectUrl("https://success.pay")                    // m_redirect_url 주소
        
        // 결제 정보 데이타
        let parameters: IAMPortParameters = [
            "merchant_uid": String(format: "merchant_%@", String(Int(NSDate().timeIntervalSince1970 * 1000))),
            "name": "결제테스트",
            "amount": "1004",
            "buyer_email": "demo@demo.inc",
            "buyer_name": "테스트",
            "buyer_tel": "010-3094-9303",
            "buyer_addr": "서울특별시 강남구 역삼동",
            "buyer_postcode": "01777",
            "custom_data": ["A1": 123, "B1": "Hello"]
            //"custom_data": "24"
        ]
        IAMPortPay.sharedInstance.setParameters(parameters).commit()
        
        // 결제 웹페이지(Local) 파일 호출
        if let url = IAMPortPay.sharedInstance.urlFromLocalHtmlFile() {
            let request = URLRequest(url: url)
            self.wkWebView.load(request)
        }
    }
    
}

@available(iOS 13.0, *)
extension WKHtml5InicisViewControllerSwiftUI: WKNavigationDelegate {
    
    /// 결제 결과 핸들러
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let request = navigationAction.request
        
        // 카카오 결제 승인 검사
        if let urlString = request.url?.absoluteString {
            if urlString.hasPrefix("https://service.iamport.kr/kakaopay_payments/kakaoApproval") {
                print("APPROVED KAKAO PAY")
                DispatchQueue.main.async {
                    self.isPresented.toggle()
                }
            }
        }
        
        // 그 외
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
            // 결제 완료 후
            if let urlString = request.url?.absoluteString,
               urlString.hasPrefix("https://success.pay") {
                // 결제 승인 완료
                self.isPresented.toggle()
            }
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
            } else {
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

enum PaymentMethod: String, CaseIterable {
    case credit, kakao, naver
}

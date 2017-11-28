# SwiftyIamport For iOS (Swift 3)

[![Platform iOS](https://img.shields.io/badge/platform-iOS-blue.svg?style=flat)]()
[![License: MIT](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://raw.githubusercontent.com/JosephNK/SwiftyIamport/master/LICENSE)
[![Swift 3 compatible](https://img.shields.io/badge/swift3-compatible-4BC51D.svg?style=flat)](https://developer.apple.com/swift)

스위프트용 아임포트 결제모듈을 쉽게 연동하기 위한 모듈입니다.

- https://github.com/iamport/iamport-nice-ios
- https://github.com/iamport/iamport-inicis-ios

아임포트에서 제공해주는 Objective-C Demo 소스를 참고하여 Swift로 구현 하였습니다.

## Installation

Cocoapods

```
pod 'SwiftyIamport', '~> 3.0.0'
```

## Setup (Info.plist)

### CFBundleURLTypes
```
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>YourSchemeName</string>
    </array>
  </dict>
</array>
```

### LSApplicationQueriesSchemes 
```
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>kftc-bankpay</string>
  <string>ispmobile</string>
  <string>itms-apps</string>
  <string>hdcardappcardansimclick</string>
  <string>smhyundaiansimclick</string>
  <string>shinhan-sr-ansimclick</string>
  <string>smshinhanansimclick</string>
  <string>kb-acp</string>
  <string>mpocket.online.ansimclick</string>
  <string>ansimclickscard</string>
  <string>ansimclickipcollect</string>
  <string>vguardstart</string>
  <string>samsungpay</string>
  <string>scardcertiapp</string>
  <string>lottesmartpay</string>
  <string>lotteappcard</string>
  <string>cloudpay</string>
  <string>nhappvardansimclick</string>
  <string>nonghyupcardansimclick</string>
  <string>citispay</string>
  <string>citicardappkr</string>
  <string>citimobileapp</string>
  <string>kakaotalk</string>
  <string>payco</string>
</array>
```

### NSAppTransportSecurity 
```
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

## Usage

1. 공통

```
import SwiftyIamport
```

```
- AppDelegate 파일 설정

func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    if let scheme = url.scheme {
        if scheme.hasPrefix(IAMPortPay.sharedInstance.appScheme ?? "") {
            return IAMPortPay.sharedInstance.application(app, open: url, options: options)
        }
    }
    return true
}

// for iOS below 9.0
func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    if let scheme = url.scheme {
        if scheme.hasPrefix(IAMPortPay.sharedInstance.appScheme ?? "") {
            return IAMPortPay.sharedInstance.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        }
    }
    return true
}
```

2. 웹 요청하여 처리할 경우
```
override func viewDidLoad() {
    super.viewDidLoad()

    // 결제 환경 설정
    IAMPortPay.sharedInstance.configure(scheme: "iamporttest")  // info.plist에 설정한 scheme
    
    IAMPortPay.sharedInstance
        .setWebView(self.webView)   // 현재 Controller에 있는 WebView 지정
        .setRedirectUrl(nil)        // m_redirect_url 주소

    // ISP 취소시 이벤트 (NicePay만 가능)
    IAMPortPay.sharedInstance.setCancelListenerForNicePay { [weak self] _ in
        ... ...
    }

    // 결제 웹페이지(Remote) 호출
    if let url = URL(string: "http://www.iamport.kr/demo") {
        let request = URLRequest(url: url)
        self.webView.loadRequest(request)
    }
}

// WebView Delegate
func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    // 해당 함수는 redirecURL의 결과를 직접 처리하고 할 때 사용하는 함수 (IAMPortPay.sharedInstance.configure m_redirect_url 값을 설정해야함.)
    IAMPortPay.sharedInstance.webViewRedirectUrl(shouldStartLoadWith: request, parser: { (data, response, error) -> Any? in
        // Background Thread
        var resultData: [String: Any]?
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            switch statusCode {
            case 200:
                resultData = "파싱 및 처리 한 데이타"
                break
            default:
                break
            }
        }
        return resultData
    }) { (pasingData) in
        // Main Thread
        파싱 및 처리 된 데이타를 받아서 처리 (pasingData)
    }

    return IAMPortPay.sharedInstance.webView(webView, shouldStartLoadWith: request, navigationType: navigationType)
}

func webViewDidFinishLoad(_ webView: UIWebView) {
    // 직접 구현..
}

```

3. 모듈에 내장되어 있는 HTML 파일을 이용하여 처리할 경우
```
override func viewDidLoad() {
    super.viewDidLoad()

    // 결제 환경 설정
    IAMPortPay.sharedInstance.configure(scheme: "iamporttest",              // info.plist에 설정한 scheme
                                        storeIdentifier: "imp84043725")     // iamport 에서 부여받은 가맹점 식별코드
    
    IAMPortPay.sharedInstance
        .setPGType(.nice)               // PG사 타입
        .setIdName(nil)                 // 상점아이디 ({PG사명}.{상점아이디}으로 생성시 사용)
        .setPayMethod(.card)            // 결제 형식
        .setWebView(self.webView)       // 현재 Controller에 있는 WebView 지정
        .setRedirectUrl(nil)            // m_redirect_url 주소
    
    // 결제 정보 데이타
    let parameters: IAMPortParameters = [
        "merchant_uid": String(format: "merchant_%@", String(Int(NSDate().timeIntervalSince1970 * 1000))),
        "name": "결제테스트",
        "amount": "1004",
        "buyer_email": "iamport@siot.do",
        "buyer_name": "구매자",
        "buyer_tel": "010-1234-5678",
        "buyer_addr": "서울특별시 강남구 삼성동",
        "buyer_postcode": "123-456",
        "custom_data": ["A1": 123, "B1": "Hello"]
        //"custom_data": "24"
    ]
    IAMPortPay.sharedInstance.setParameters(parameters).commit()

    // ISP 취소시 이벤트 (NicePay만 가능)
    IAMPortPay.sharedInstance.setCancelListenerForNicePay { [weak self] _ in
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: "ISP 결제 취소", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }

    // 결제 웹페이지(Local) 파일 호출
    if let url = IAMPortPay.sharedInstance.urlFromLocalHtmlFile() {
        let request = URLRequest(url: url)
        self.webView.loadRequest(request)
    }
}

func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    // 해당 함수는 redirecURL의 결과를 직접 처리하고 할 때 사용하는 함수 (IAMPortPay.sharedInstance.configure m_redirect_url 값을 설정해야함.)
    IAMPortPay.sharedInstance.webViewRedirectUrl(shouldStartLoadWith: request, parser: { (data, response, error) -> Any? in
        // Background Thread
        var resultData: [String: Any]?
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode = httpResponse.statusCode
            switch statusCode {
            case 200:
                resultData = "파싱 및 처리 한 데이타"
                break
            default:
                break
            }
        }
        return resultData
    }) { (pasingData) in
        // Main Thread
        파싱 및 처리 된 데이타를 받아서 처리 (pasingData)
    }

    return IAMPortPay.sharedInstance.webView(webView, shouldStartLoadWith: request, navigationType: navigationType)
}

func webViewDidFinishLoad(_ webView: UIWebView) {
    // 결제 환경으로 설정에 의한 웹페이지(Local) 호출 결과
    IAMPortPay.sharedInstance.requestIAMPortPayWebViewDidFinishLoad(webView) { (error) in
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
```

## More

- SwiftyIamportDemo를 참고 바랍니다.

## Requirements

- Swift 3
- iOS 8.0+

## Licence

- SwiftyIamport licensed under [MIT](https://raw.githubusercontent.com/JosephNK/SwiftyIamport/master/LICENSE)

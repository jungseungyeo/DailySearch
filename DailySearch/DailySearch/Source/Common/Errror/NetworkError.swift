//
//  NetworkError.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/13.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

enum DailySearchErrror: Int, Error, CustomStringConvertible {
    
    var code: Int {
        return self.rawValue
    }
    
    //Bad Request
    case common400 = 400
    //Unauthorized
    case coomon401 = 401
    // Not Found
    case common404 = 404
    
    // Internal Server Error
    case common500 = 500
    // Service Unavailable
    case common503 = 503
    
    // 마이너스 에러 - 네이티브 에러 - 내가 만든 Error Code
    // 데이타 set 실패
    case dataParsing996 = -996
    // JSON 파싱 실패
    case jsonParsing997 = -997
    // url 파싱 실패
    case urlParsing998 = -998
    
    case unknown = -999
    
    var description: String {
        switch self {
        case .unknown:
            return "알 수 없는 에러"
        case .common400,
             .coomon401,
             .common404:
            return "인터넷을 연결 할 수 없습니다."
        case .common500,
             .common503:
            return "서버가 불안정 합니다."
        case .dataParsing996:
            return "테이타 파싱 샐패"
        case .jsonParsing997:
            return "JSON 파싱 실패"
        case .urlParsing998:
            return "url 파싱 실패"
        }
    }
}

class NetworkError: NSObject {
    
    private struct Const {
        static let alertConfirm: String = "확인"
    }
    
    public func alert(vc: UIViewController, error: Error?, action: ((Int) -> Void)?) {
        guard let error = error, let fitpetError = DailySearchErrror(rawValue: (error as NSError).code) else {
            unknownError(vc: vc, block: action)
            return
        }
        
        customError(vc: vc, error: fitpetError, action: action)
    }
    
    private func customError(vc: UIViewController, error: DailySearchErrror, action: ((Int) -> Void)?) {
        showAlert(vc: vc,
                  title: "\(error)",
                  message: "",
                  error: error,
                  block: action)
    }
    
    private func unknownError(vc: UIViewController, block: ((Int) -> Void)?) {
        showAlert(vc: vc,
                  title: "\(DailySearchErrror.unknown)",
                  message: "",
                  error: DailySearchErrror.unknown,
                  block: block)
    }
    
    private func showAlert(vc: UIViewController, title: String?, message: String?, error: Error, block: ((Int) -> Void)?) {
        let errroAlert = UIAlertController.errorAlert(title ?? "",
                                                      message: message ?? "",
                                                      error: error,
                                                      defaultString: Const.alertConfirm,
                                                      defaultHandler: { (action) in
                                                          block?((error as NSError).code)
        })
        errroAlert.show(vc)
    }
}

fileprivate extension UIAlertController {
    @discardableResult
    static func errorAlert( _ title: String = "", message: String, error: Error, defaultString: String, defaultHandler: ((Int) -> Void)?) -> UIAlertController {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: defaultString,
                                                style: .cancel,
                                                handler: { (action) in
                                                    defaultHandler?((error as NSError).code)
        }))
        return alertController
    }
}

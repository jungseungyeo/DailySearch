//
//  Networker.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/13.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import Alamofire
import RxCocoa
import RxSwift
import SwiftyJSON

protocol Networkerable {
    var route: (method: HTTPMethod, url: URL) { get }
    var params: Parameters? { get }
    var header: HTTPHeaders? { get }
}

public enum APIResult {
    case success(JSON)
    case failure(Error)
}

public final class Networker: NSObject {

    static func request(api: Networkerable, _ parameterEncoding: ParameterEncoding? = nil) -> Single<JSON> {
        return sendRequest(api: api, parameterEncoding: parameterEncoding)
    }

    private static func sendRequest(api: Networkerable, parameterEncoding: ParameterEncoding?) -> Single<JSON> {
        let request = Single<JSON>.create { (single) -> Disposable in
            sendRequestDefault(url: api.route.url.absoluteString,
                               method: api.route.method,
                               params: api.params,
                               parameterEncoding: parameterEncoding,
                               header: api.header,
                               callback: { (HTTPStatus, result) in
                                #if DEBUG
                                    print("Http StatusCode : { \(HTTPStatus?.statusCode ?? -999) }")
                                #endif
                                switch result {
                                case .success(let json):
                                    #if DEBUG
                                        print("JSON : { \(json) }")
                                    #endif
                                    single(.success(json))
                                case .failure(let error):
                                    #if DEBUG
                                        print("ERROR: { \(error.localizedDescription) }")
                                    #endif
                                    single(.error(error))
                                }
            })
            return Disposables.create()
        }
        return request
    }

    private static func sendRequestDefault(url: String, method: HTTPMethod, params: Parameters?, parameterEncoding: ParameterEncoding?, header: HTTPHeaders?, callback: ((HTTPURLResponse?, APIResult) -> Void)?) {

        let url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

        var encoding = parameterEncoding

        if method == .post {
            encoding = JSONEncoding.default
        } else if encoding == nil {
            encoding = URLEncoding.default
        }

        var requestHeader = DailySearchService.shared.commonHeader
        
        if let addHeader = header {
            requestHeader.merge(addHeader) { (_, new) -> String in
                return new
            }
        }

        guard let urlString = url, let requestURL = URL(string: urlString) else {
            callback?(nil, .failure(DailySearchErrror.urlParsing998))
            return
        }
    
        Alamofire.request(requestURL,
                   method: method,
                   parameters: params,
                   encoding: encoding!,
                   headers: requestHeader)
            .validate(statusCode: 200 ..< 300)
            .responseJSON { (response) in
                switch response.result {
                case .success(let data):
                    if let dictionary = data as? [String: Any] {
                        let json = JSON(dictionary)
                        callback?(response.response, .success(json))
                    } else if let dictionnarys = data as? [[String: Any]] {
                        let jsonArray = JSON(dictionnarys)
                        callback?(response.response, .success(jsonArray))
                    } else {
                        if let statusCode = response.response?.statusCode, let reason = DailySearchErrror(rawValue: statusCode) {
                            callback?(response.response, .failure(reason))
                        } else {
                            callback?(response.response, .failure(DailySearchErrror.jsonParsing997))
                        }
                    }
                case .failure(let error):
                    if let statusCode = response.response?.statusCode,
                        let reason = DailySearchErrror(rawValue: statusCode) {
                        callback?(response.response, .failure(reason))
                    } else {
                        callback?(response.response, .failure(error))
                    }
                }
        }
    }
}

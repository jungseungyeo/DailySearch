//
//  BlogNetworkerTest.swift
//  DailySearchTests
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import XCTest

@testable import Alamofire
@testable import RxSwift
@testable import RxCocoa
@testable import RxBlocking
@testable import DailySearch

class BlogNetworkerTest: XCTestCase {
    
    private var blogModel: SearchModel!
    
    private var api: SearchAPI!
    
    private struct Const {
        static let blogURLString: String = "https://dapi.kakao.com/v2/search/blog"
        
        static let params: Parameters = ["query": "린생",
                                         "sort": "accuracy",
                                         "page": 1,
                                         "szie": 25]
    }

    override func setUp() {
        guard let json = TestUtil.loadJSON("BlogDemoFile") as? [String: Any] else {
            return
        }
        blogModel = SearchModel(JSON: json)
        
        api = SearchAPI.blog(query: "린생", sort: .accuracy, page: 1, size: 25)
    }
    
    func testInitial() {
        
        XCTAssertNotNil(blogModel.meta)
        XCTAssertNotNil(blogModel.documents)
        
        // Meta
        XCTAssertNil(blogModel.meta?.groupFilterGroups)
        XCTAssertEqual(blogModel.meta?.isEnd, false)
        XCTAssertEqual(blogModel.meta?.pageableCount, 799)
        XCTAssertNil(blogModel.meta?.sessionID)
        XCTAssertEqual(blogModel.meta?.totalCount, 42977)
        XCTAssertNil(blogModel.meta?.totalTime)
        
        // documents
        XCTAssertEqual(blogModel.documents?.count, 25)
        
        guard let documents = blogModel.documents else {
            XCTFail()
            return
        }
    
        for document in documents {
            XCTAssertEqual(document.searchType, .blog)
            XCTAssertNotNil(document.contents)
            XCTAssertNotNil(document.dateTime)
            XCTAssertNotNil(document.thumbnail)
            XCTAssertNotNil(document.title)
            XCTAssertNotNil(document.url)
        }
    }
    
    func testBlogAPI() {
        XCTAssertEqual(api.route.method, .get)
        XCTAssertEqual(api.route.url.absoluteString, Const.blogURLString)
        
        guard let params = api.params else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(params["query"] as? String, Const.params["query"] as? String)
        XCTAssertEqual(params["sort"] as? String, Const.params["sort"] as? String)
        XCTAssertEqual(params["page"] as? Int, Const.params["page"] as? Int)
        XCTAssertEqual(params["szie"] as? Int, Const.params["query"] as? Int)
        
        let requester = SearchNetworker.request(api: api)
        
        do {
            let response = try requester.toBlocking().first()
            
            guard let json = response, let dict = json.dictionaryObject else {
                throw DailySearchErrror.unknown
            }
            
            guard let searchModel = SearchModel(JSON: dict) else {
                throw DailySearchErrror.jsonParsing997
            }
            
            guard let meta = searchModel.meta, let documents = searchModel.documents else {
                throw DailySearchErrror.unknown
            }
            
            // meta
            XCTAssertNil(meta.groupFilterGroups)
            XCTAssertNotNil(meta.isEnd)
            XCTAssertNotNil(meta.pageableCount)
            XCTAssertNil(meta.sessionID)
            XCTAssertNotNil(meta.totalCount)
            XCTAssertNil(meta.totalTime)
            
            // document
            XCTAssertEqual(documents.count, 25)
            
            for document in documents {
                XCTAssertEqual(document.searchType, .blog)
                XCTAssertNotNil(document.contents)
                XCTAssertNotNil(document.dateTime)
                XCTAssertNotNil(document.thumbnail)
                XCTAssertNotNil(document.title)
                XCTAssertNotNil(document.url)
            }
            
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }

}

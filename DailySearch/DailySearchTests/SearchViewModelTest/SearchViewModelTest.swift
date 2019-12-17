//
//  SearchViewModelTest.swift
//  DailySearchTests
//
//  Created by saenglin on 2019/12/17.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import XCTest

@testable import DailySearch

class SearchViewModelTest: XCTestCase {
    
    private var viewModel: SearchViewModel!
    private var searchModel: SearchModel!
    
    private struct Const {
        let customDateFormat: String = "yyyy년 MM월 dd일"
    }
    
    private let const = Const()

    override func setUp() {
        viewModel = SearchViewModel()
        guard let json = TestUtil.loadJSON("BlogDemoFile") as? [String: Any] else {
            return
        }
        searchModel = SearchModel(JSON: json)
    }

    func testPresentModel() {
        let optionalPresentModels = searchModel.documents?.compactMap({ (document) -> SearchListPresentModel in
            return SearchListPresentModel(type: .blog,
                                          name: document.typeName ?? "",
                                          title: viewModel.htmlParsing(document.title ?? ""),
                                          content: viewModel.htmlParsing(document.contents ?? ""),
                                          dateTime: viewModel.dateParsing(dateString: document.dateTime ?? ""),
                                          detailDateTime: viewModel.dateParsing(dateString: document.dateTime ?? "", isDetail: true),
                                          urlString: document.url ?? "",
                                          thumbnailURLString: document.thumbnail ?? "")
        })
        
        guard let presentModels = optionalPresentModels else {
            XCTFail()
            return
        }
        
        for presentModel in presentModels {
            XCTAssertEqual(presentModel.type, .blog)
            XCTAssertTrue(presentModel.name.isNotEmpty())
            XCTAssertNotNil(presentModel.title)
            XCTAssertNotNil(presentModel.content)
            XCTAssertNotNil(presentModel.dateTime)
            XCTAssertNotNil(presentModel.detailDateTime)
            XCTAssertTrue(presentModel.urlString.isNotEmpty())
        }
    }
    
    func testCurrentDay() {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = const.customDateFormat
        let currentDayString = dateFormat.string(from: Date())
        
        XCTAssertEqual(viewModel.currentDay(), currentDayString)
    }
    
    func testYesterDay() {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = const.customDateFormat
        var date = Date()
        date.addTimeInterval(-(60 * 60 * 24))
        let yesterDayStirng = dateFormat.string(from: date)
        
        XCTAssertEqual(viewModel.yesterDay(), yesterDayStirng)
    }
    
    func testDateParsing() {
        let date = viewModel.dateParsing(dateString: "2019-12-10T20:28:26.000+09:00")
        XCTAssertEqual(date, "2019년 12월 10일")
        let detailDate = viewModel.dateParsing(dateString: "2019-12-10T20:28:26.000+09:00", isDetail: true)
        XCTAssertEqual(detailDate, "2019년 12월 10일 20:28")
    }
    
    func testDateParsingFailure() {
        let date = viewModel.dateParsing(dateString: "2019-12-10T20:28:26.000+09:00")
        XCTAssertNotEqual(date, "2019년 12월 11일 20:28")
        XCTAssertNotEqual(date, "2019년 12월 12일")
        XCTAssertNotEqual(date, "2019년 12월 14일")
        let detailDate = viewModel.dateParsing(dateString: "2019-12-10T20:28:26.000+09:00", isDetail: true)
        XCTAssertNotEqual(detailDate, "2019년 12월 11일 20:28")
        XCTAssertNotEqual(detailDate, "2019년 12월 1일 20:28")
        XCTAssertNotEqual(detailDate, "2019년 12월 15일 20:28")
    }
    
}

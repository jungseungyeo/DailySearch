//
//  SearchViewModel.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftyJSON

enum SearchListFilter: Int, CustomStringConvertible, CaseIterable {
    
    case title = 0
    case date
    
    var description: String {
        switch self {
        case .title:
            return "Title"
        case .date:
            return "Datetime"
        }
    }
    
    var apiParam: SearchSortType {
        switch self {
        case .title: return .accuracy
        case .date: return .recency
        }
    }
}

enum SearchViewState {
    case requesting
    case complete
    case error(Error?)
}

struct SearchListPresentModel {
    let type: SearchType
    let name: String
    let title: NSMutableAttributedString?
    let content: NSMutableAttributedString?
    let dateTime: String
    let detailDateTime: String
    let urlString: String
    let thumbnailURLString: String
}

final class SearchViewModel: NSObject, ReactiveViewModelable {
    
    typealias InputType = Input
    typealias OutputType = Output
    
    struct Input {
        // 검색을 통해서 들어오는 reset -> request API
        public let searchText = PublishRelay<String>()
        // 검색 requset
        fileprivate let requestAPI = PublishRelay<String>()
        
        // paging처리를 하기 위해서 들어오는 request
        public let pagingRequet = PublishRelay<Void>()
        
        public let genreFilterBtnTapped = PublishRelay<Void>()
        public let listFilterBtnTapped = PublishRelay<Void>()
        
        public let searchTypeChanged = PublishRelay<(SearchType)>()
        public let searchListTypeChanged = PublishRelay<SearchListFilter>()
        
        public let didTapped = PublishRelay<Int>()
        
        public let searchTapped = PublishRelay<Bool>()
    }
    
    struct Output {
        public let genreFilterChoiceAlertObservable: Observable<Void>
        public let listFilterChoiceAlert = PublishRelay<SearchListFilterAlertViewController>()
        
        public let state = PublishRelay<SearchViewState>()
        
        public let moveDetailView = PublishRelay<SearchDetailViewController>()
        public let isRecentShow = PublishRelay<Bool>()
    }
    
    public lazy var input: InputType = Input()
    public lazy var output: OutputType = {
        let genreFilterBtnTapped = input.genreFilterBtnTapped
            .map { _ in return }
        
        return Output(genreFilterChoiceAlertObservable: genreFilterBtnTapped)
    }()
    
    public private(set) lazy var searchgenreType: SearchType = .all
    public private(set) lazy var searchListFilterType: SearchListFilter = .title
    
    public private(set) var searchListPresentModels: [SearchListPresentModel] = []
    
    // 페이징 처리 할 때 사용되는 검색 단어 ( SearchBar Text 지우는 경우가 있어 별로로 저장 )
    private var searchingText: String = ""
    
    private var isBlogEnd: Bool = false
    private var blogPage: Int = 0
    
    private var isCafeEnd: Bool = false
    private var cafePage: Int = 0
    
    private let bag = DisposeBag()
    
    private struct Const {
        let pageSize: Int = 25
        let kakaoDateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ"
        let customDateFormat: String = "yyyy년 MM월 dd일"
        let customDetailDateFormat: String = "yyyy년 MM월 dd일 a hh:mm"
        let todayString: String = "오늘"
        let yesterDayString: String = "어제"
    }
    
    private let const = Const()
    
    public var recentListCount: Int {
        return (UserDefaultManager.recentList ?? []).count
    }
    
    override init() {
        super.init()
        
        rxBind()
    }
    
    private func reset() {
        self.isBlogEnd = false
        self.isCafeEnd = false
        self.searchListPresentModels = []
        self.blogPage = 0
        self.cafePage = 0
    }
    
    private func rxBind() {
        
        input.listFilterBtnTapped
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                let searchListFilterAlertViewController = SearchListFilterAlertViewController.intance(viewModel: SearchListAlertViewModel(filterType: self.searchListFilterType))
                self.output.listFilterChoiceAlert.accept(searchListFilterAlertViewController)
            }).disposed(by: bag)
        
        input.didTapped
            .subscribe(onNext: { [weak self] (index) in
                guard let self = self else { return }
                guard let searchListPresentModel = self.searchListPresentModels[safe: index] else { return }
                let vc = SearchDetailViewController.instance(searchViewModel: SearchDetailViewModel(model: searchListPresentModel))
                self.output.moveDetailView.accept(vc)
            }).disposed(by: bag)
        
        input.searchTapped
            .subscribe(onNext: { [weak self] (isNotShow) in
                guard let self = self else { return }
                self.output.isRecentShow.accept(!isNotShow)
            }).disposed(by: bag)
        
        requestAPIBind()
    }
    
    // Title Filter인 경우 전체 Model인 아닌 response값(25개)만 정렬
    // API 구조상 전체 List를 정렬 할 경우 1번째 index부터 정렬이 되어 사용자에게 어색하게 보여지는 이슈가 있음 -> 25개의 response의 대해서만 정렬
    private func requestAPIBind() {
        
        input.searchText
            .subscribe(onNext: { [weak self] (searchText) in
                guard let self = self else { return }
                self.reset()
                self.searchingText = searchText
                self.saveRecentList(searchText)
                self.input.requestAPI.accept(searchText)
            }).disposed(by: bag)
        
        input.pagingRequet
            .map { [weak self] _ -> String in
                guard let self = self else { return "" }
                return self.searchingText
        }.bind(to: input.requestAPI)
        .disposed(by: bag)
        
        input.searchTypeChanged
            .subscribe(onNext: { [weak self] (searchType) in
                guard let self = self else { return }
                self.searchgenreType = searchType
                guard self.searchingText.isNotEmpty() else {
                    self.output.state.accept(.complete)
                    return
                }
                self.input.searchText.accept(self.searchingText)
            }).disposed(by: bag)
        
        // date 정렬의 경우 API에서 순서를 보장 할 수 있지만 title에서 date정렬로 변경시 기존 데이타를 재 정렬시 순서를 보장 할 수 없음 따라서 정렬 기준 변경시에도 API를 다시 보냄
        input.searchListTypeChanged
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (filterType) in
                guard let self = self else { return }
                self.searchListFilterType = filterType
                guard self.searchingText.isNotEmpty() else {
                    self.output.state.accept(.complete)
                    return
                }
                self.input.searchText.accept(self.searchingText)
            }).disposed(by: bag)
        
        input.requestAPI
            .map { (_) -> SearchViewState in
                return .requesting
        }.bind(to: output.state)
        .disposed(by: bag)
        
        let blogRequester = input.requestAPI
            .filter { [weak self] (_) -> Bool in
                // Blog API는 blog상태에서는 미 호출
                guard let self = self else { return false }
                switch self.searchgenreType {
                case .cafe: return false
                default: return true
                }
        }.flatMapLatest(weak: self) { (wself, searchText) -> Observable<(JSON)> in
            wself.blogPage += 1
            let api = SearchAPI.blog(query: searchText,
                                     sort: wself.searchListFilterType.apiParam,
                                     page: wself.blogPage,
                                     size: wself.const.pageSize)
            return SearchNetworker.request(api: api).asObservable()
        }.map { [weak self] (json) -> (SearchModel?, SearchType)? in
            guard let self = self else { return nil }
            return (self.settingSearchInfo(info: json), .blog)
        }
  
        let cafeRequester = input.requestAPI
            .filter { [weak self] (_) -> Bool in
                // cafe API는 blog상태에서는 미 호출
                guard let self = self else { return false }
                switch self.searchgenreType {
                case .blog: return false
                default: return true
                }
        }.flatMapLatest(weak: self) { (wself, searchText) -> Observable<JSON> in
            wself.cafePage += 1
            let api = SearchAPI.cafe(query: searchText,
                                     sort: wself.searchListFilterType.apiParam,
                                     page: wself.cafePage,
                                     size: wself.const.pageSize)
            return SearchNetworker.request(api: api).asObservable()
        }.map { [weak self] (json) -> (SearchModel?, SearchType)? in
            guard let self = self else { return nil }
            return (self.settingSearchInfo(info: json), .cafe)
        }
        
        Observable.merge(blogRequester, cafeRequester)
            .map { (response) -> [SearchListPresentModel]? in
                guard let searchModel = response?.0 else { return nil }
                guard let searchType = response?.1 else { return nil }
                
                // api별로 isEnd 체크를 하기 위해 필요한 값
                switch searchType {
                case .blog:
                    self.isBlogEnd = searchModel.meta?.isEnd ?? true
                case .cafe:
                    self.isCafeEnd = searchModel.meta?.isEnd ?? true
                case .all: return nil
                }
                
                let presentModels = searchModel.documents?.compactMap({ (document) -> SearchListPresentModel in
                    return SearchListPresentModel(type: searchType,
                                                  name: document.typeName ?? "",
                                                  title: self.htmlParsing(document.title ?? ""),
                                                  content: self.htmlParsing(document.contents ?? ""),
                                                  dateTime: self.dateParsing(dateString: document.dateTime ?? ""),
                                                  detailDateTime: self.dateParsing(dateString: document.dateTime ?? "", isDetail: true),
                                                  urlString: document.url ?? "",
                                                  thumbnailURLString: document.thumbnail ?? "")
                })
                
                return presentModels
        }.subscribe(onNext: { [weak self] (presentmModels) in
            guard let self = self else { return }
            //searchListFilterType 가 title 기준인 경우 정렬이 필요
            let sortedSearchList = self.searchListFilterType == .title ? (self.sortedTitle(to: presentmModels ?? [])) : (presentmModels ?? [])
            self.searchListPresentModels.append(contentsOf: sortedSearchList)
            self.output.state.accept(.complete)
            
        }, onError: { [weak self] (error) in
            guard let self = self else { return }
            self.output.state.accept(.error(error))
            }).disposed(by: bag)
        
    }
    
    func isDimCell(_ index: Int) -> Bool {
        guard let clickLinks = UserDefaultManager.clicUrls else { return false }
        guard let urlString = searchListPresentModels[safe: index]?.urlString else { return false}
        return (clickLinks.filter { $0 == urlString }).count > 0
    }
    
    func recentSearchText(_ index: Int) -> String? {
        guard let recentList = UserDefaultManager.recentList else { return nil }
        return recentList[safe: index]
    }
}

private extension SearchViewModel {
    func settingSearchInfo(info: JSON) -> SearchModel? {
        guard let dict = info.dictionaryObject else { return nil }
        return SearchModel(JSON: dict)
    }
    
    func sortedTitle(to presentModel: [SearchListPresentModel]) -> [SearchListPresentModel] {
        return presentModel.sorted { (firstModel, secondeModel) -> Bool in
            return firstModel.title?.string ?? "" < secondeModel.title?.string ?? ""
        }
    }
    
    func htmlParsing(_ htmlString: String) -> NSMutableAttributedString? {
        var string = NSMutableAttributedString()
        let data = htmlString.data(using: .utf8)!
        do {
            string = try NSMutableAttributedString(data: data,
                                                   options: [.documentType: NSAttributedString.DocumentType.html,
                                                             .characterEncoding: String.Encoding.utf8.rawValue],
                                                   documentAttributes: nil)
            string.addAttribute(.foregroundColor, value: DailySearchColor.Style.label,
                                range: NSRange(location: 0, length: string.length))
        } catch {
            return nil
        }
        return string
    }
    
    func currentDay() -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = const.customDateFormat
        return dateFormat.string(from: Date())
    }
    
    func yesterDay() -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = const.customDateFormat
        var date = Date()
        date.addTimeInterval(-(60 * 60 * 24))
        return dateFormat.string(from: date)
    }
    
    func dateParsing(dateString: String, isDetail: Bool = false) -> String {
        let dateForamt = DateFormatter()
        dateForamt.dateFormat = const.kakaoDateFormat
        let date = dateForamt.date(from: dateString) ?? Date()
        dateForamt.dateFormat = isDetail ? const.customDetailDateFormat : const.customDateFormat
        let dateString = dateForamt.string(from: date)
        if dateString == currentDay() {
            return const.todayString
        }
        
        if dateString == yesterDay() {
            return const.yesterDayString
        }
        
        return dateString
    }
    
    func saveRecentList(_ searchText: String) {
        var recentList = UserDefaultManager.recentList ?? []
        guard (recentList.filter { $0 == searchText }).count == 0 else { return }
        recentList.append(searchText)
        UserDefaultManager.recentList = recentList
    }
}

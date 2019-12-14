//
//  ReactiveViewModelable.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

protocol ReactiveViewModelable {
    associatedtype InputType
    associatedtype OutputType

    var input: InputType { set get }
    var output: OutputType { get }
}

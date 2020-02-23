//
//  ParameterListViewTests.swift
//  UnitTests
//
//  Created by Anastasia Petrova on 23/02/2020.
//  Copyright © 2020 Anastasia Petrova. All rights reserved.
//

import Foundation
import UIKit
import XCTest
@testable import Snapvideo

final class ParameterListViewTests: XCTestCase {
    private typealias Parameter = ParameterListView.Parameter
    
    func test_init_assigns_parameters() {
        let expected = [
            Parameter(name: "Foo", value: "1"),
            Parameter(name: "Bar", value: "2")
        ]
        let view = ParameterListView(parameters: expected) { _ in }
        XCTAssertEqual(view.parameters, expected)
    }
    
    func test_callback() {
        let expected = Parameter(name: "Foo", value: "1")
        var actual: Parameter?
        let view = ParameterListView(parameters: []) { actual = $0 }
        view.callback(expected)
        XCTAssertEqual(expected, actual)
    }
    
    func test_translateY_boundries() {
        let view = ParameterListView(parameters: [
            Parameter(name: "", value: ""),
            Parameter(name: "", value: "")
        ]) { _ in }
        add(view, on: UIViewController())
        
        XCTAssertEqual(view.offsetY, 0)
        
        view.translateY(5)
        XCTAssertEqual(view.offsetY, 5)
        
        view.translateY(-10)
        XCTAssertEqual(view.offsetY, 0)
        
        view.translateY(10000)
        XCTAssertEqual(view.offsetY, view.stackView.frame.height)
    }
    
    func add(_ view: UIView, on vc: UIViewController) {
        view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        vc.view.layoutIfNeeded()
    }
}
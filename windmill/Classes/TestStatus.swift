//
//  TestReport.swift
//  windmill
//
//  Created by Markos Charatzas on 16/3/18.
//  Copyright © 2018 qnoid.com. All rights reserved.
//

import AppKit

enum TestStatus: String {
    
    case success = "Success"
    case failure = "Failure"
    
    var image: NSImage {
        switch self {
        case .success:
            return #imageLiteral(resourceName: "TestSuccess")
        case .failure:
            return #imageLiteral(resourceName: "TestFailure")
        }
    }
}

enum TestReport: CustomStringConvertible, Equatable {
    
    static func ==(lhs: TestReport, rhs: TestReport) -> Bool {
        switch (lhs, rhs) {
        case let (.success(l), .success(r)): return l == r
        case let (.failure(l), .failure(r)): return l == r
        default: return false
        }
    }

    case success(testsCount: Int), failure(testsFailedCount: Int)
    
    var status: TestStatus {
        switch self {
        case .success(_):
            return .success
        case .failure(_):
            return .failure
        }
    }
    
    var description: String {
        switch self {
        case .success(let testsCount):
            return String(testsCount)
        case .failure(let testsFailedCount):
            return String(testsFailedCount)
        }
    }
}
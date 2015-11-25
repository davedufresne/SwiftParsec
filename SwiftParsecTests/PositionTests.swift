//
//  PositionTests.swift
//  SwiftParsec
//
//  Created by David Dufresne on 2015-11-13.
//  Copyright © 2015 David Dufresne. All rights reserved.
//

import XCTest
@testable import SwiftParsec

class PositionTests: XCTestCase {
    
    func testComparable() {
        
        let pos1 = SourcePosition(name: "", line: 1, column: 8)
        let pos2 = SourcePosition(name: "", line: 2, column: 1)
        let pos3 = SourcePosition(name: "", line: 1, column: 4)
        
        XCTAssert(pos1 < pos2, "pos1 should be smaller than pos2.")
        XCTAssert(pos1 == pos1, "pos1 should be equal to itself.")
        XCTAssert(pos1 > pos3, "pos1 should be greater than pos3.")
        
    }

}

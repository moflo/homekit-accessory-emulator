//
//  homekit_emulatorTests.swift
//  homekit-emulatorTests
//
//  Created by moflo on 6/9/17.
//  Copyright © 2017 Mobile Flow LLC. All rights reserved.
//

import XCTest
@testable import homekit_emulator

import Nimble

//import TLV8_Bridge

class homekit_emulatorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTLV8Init() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let cppObject = newTLV8()
        
        print( cppObject.newObject() )
        
        let bytes:[UInt8] = [0x00, 0x01, 0x02];
        let data = Data(bytes: bytes);
        let dict = cppObject.parseData(data)
        
        print( dict.debugDescription )
        
        let first_key = dict!.first!.key as! Int
        let first_data = dict!.first!.value as! Data
        let first_value :Int = first_data.withUnsafeBytes { $0.pointee }
        
        expect(dict!.keys.count).to(equal(1))
        expect(first_key).notTo(beNil())
        expect(first_value).notTo(beNil())
        expect(first_value).to(equal(2))
        
        
    }
    
    func testTLV8Double() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let cppObject = newTLV8()
        
        print( cppObject.newObject() )
        
        let bytes:[UInt8] = [0x00, 0x01, 0x02, 0x01, 0x01, 0x04];
        let data = Data(bytes: bytes);
        let dict = cppObject.parseData(data)
        
        print( dict.debugDescription )
        
        expect(dict!.keys.count).to(equal(2))

        for (key, data) in dict! {
            let first_key = key as! Int
            let first_data = data as! Data
            let first_value :Int = first_data.withUnsafeBytes { $0.pointee }

            print( first_key, first_value )
            
            if (first_key == 0) {
                expect(first_value).to(equal(2))

            }
            if (first_key == 1) {
                expect(first_value).to(equal(4))
                
            }
            
        }

    }

    func testHAPContoller() {
        
        let cppObject = newHAPController()
        
        let dict = cppObject.getChallenge()
        
    }
    
    

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

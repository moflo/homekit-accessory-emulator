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

    func testTLV8Encode() {
        
        let cppObject = newTLV8()
        

        let dict = [ 1: "test".data(using: .utf8)! ]
        let data :Data = cppObject.encodeDict(dict)
        
        print( data.debugDescription )
        
        let hexBytes = data.map { String(format: "%02hhx", $0) }
        print( hexBytes.joined() )

        expect(data.count).to(equal(6))
        expect(Int(hexBytes[0])).to(equal(1))
        expect(Int(hexBytes[1])).to(equal(4))
        
    }
    
    func testHAPContoller() {
        
        let cppObject = newHAPController()
        
        let dict = cppObject.getChallenge()
        
        print( dict.debugDescription )
    }
    
    func testHomeKit() {
        
        let testObject = newHomeKit()
        
        expect(testObject).notTo(beNil())
        
    }
    
    func testHomeKitProcess() {
        
        let testObject = newHomeKit()
        
        let dataString = "POST /pair-setup HTTP/1.1\nHost: emulator._hap._tcp.local\nContent-Length: 3\nContent-Type: application/pairing+tlv8\r\n\r\n\u{00}\u{01}\u{01}\u{01}\n\r"
        
//        NSData *bytes = [dataString dataUsingEncoding:NSASCIIStringEncoding];
        let data :Data = dataString.data(using: .ascii)!

        let r = testObject.processHTTP(data)
        print( r.debugDescription )
        
        let dict = r as! Dictionary<String,Any>
        
        let code = dict["state"] as! Int
        print( code )
        
        expect(code).to(equal( 0x01 /* kTLVType_State_M1 */ ))

        let outputBuffer : Data = dict["outputBuffer"] as! Data
        print( outputBuffer.count )

        expect(outputBuffer.count).to(equal( 100 /* output byte count */ ))
        
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

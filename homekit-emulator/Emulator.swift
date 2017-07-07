//
//  Emulator.swift
//  homekit-emulator singleton class
//
//  Created by d. nye on 7/7/17.
//  Copyright © 2017 Mobile Flow LLC. All rights reserved.
//

import Foundation

class Emulator {
    class var sharedInstance : Emulator {
        struct Static {
            static let instance : Emulator = Emulator()
        }
        return Static.instance
    }

    var homeKitServer :newHomeKit? = nil
    
    
    func setup() {
        homeKitServer = newHomeKit()
    }
    
    func processData(stream :Data) {
        
        
        let r = homeKitServer?.processHTTP(stream)
        print( r.debugDescription )
        
        let dict = r as! Dictionary<String,Any>
        
        let code = dict["state"] as! Int
        print( code )
        
        
        let outputBuffer : Data = dict["outputBuffer"] as! Data
        print( outputBuffer.count )
        

        
    }
    
}

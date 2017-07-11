//
//  Emulator.swift
//  homekit-emulator singleton class
//
//  Created by d. nye on 7/7/17.
//  Copyright © 2017 Mobile Flow LLC. All rights reserved.
//

import Foundation

class Emulator {
    
    // Emulator singleton
    class var sharedInstance : Emulator {
        struct Static {
            static let instance : Emulator = Emulator()
        }
        return Static.instance
    }

    // Objective-C wrapper of C++ HomeKit object
    var homeKitServer :newHomeKit? = nil
    
    // Refence to TCP stream write callback method
    // For use within the main ViewController
    var writeCallback :((_ stream: Data ) -> ())? = nil


    // Emulator singleton initialization method
    func setup( writeCallback: @escaping (_ stream: Data ) -> () ) {
        
        homeKitServer = newHomeKit()
        
        self.writeCallback = writeCallback
        
    }
    
    
    // Main TCP packet processing method
    func processData(stream :Data) {
        
        // Process incoming data with call to C++ HomeKit object
        // Return dictionary of restuls
        let r = homeKitServer?.processHTTP(stream)
        print( r.debugDescription )
        
        let dict = r as! Dictionary<String,Any>
        
        // Current state of the HomeKit object
        let code = dict["state"] as! Int
        print( code )
        
        // HAP based response data
        let outputBuffer : Data = dict["outputBuffer"] as! Data
        print( outputBuffer.count )
        
        // TCP output callback
        self.writeCallback?( outputBuffer )
        
    }
    
}

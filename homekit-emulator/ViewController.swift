//
//  ViewController.swift
//  homekit-emulator
//
//  Created by moflo on 6/9/17.
//  Copyright © 2017 Mobile Flow LLC. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

class ViewController: NSViewController {

    let netServiceBrowser = NetServiceBrowser()
    var serverService: NetService!
    var serverAddresses = [Data]()
    var asyncSocket: GCDAsyncSocket!
    var connected: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Start Bonjour service discovery
        netServiceBrowser.delegate = self
        netServiceBrowser.searchForServices(ofType: "_hap._tcp.", inDomain: "local.")

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

extension ViewController : NetServiceBrowserDelegate {
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        print("NetServiceBrowser: didNotSearch")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("NetServiceBrowser: didFind service - ", service.name)
        
        // Start service...
        if (serverService == nil)
        {
            print("NetServiceBrowser: Resolving...")
            
            serverService = service
            
            serverService.delegate = self
        
            serverService.resolve(withTimeout: 5.0)

        }

    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("NetServiceBrowser: didRemove service - ", service.name)
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("NetServiceBrowser: didStopSearch")
    }
}

extension ViewController : NetServiceDelegate {
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        print("NetService: didNotPublish")
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("NetService: didNotResolve")
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        print("NetService: didResolve - ",sender.name)
        
        // May need to handle multiple addresses
        
        guard let addresses = sender.addresses else { return }
        
        for address in addresses {
            serverAddresses.append(address)
        }
        
        if (asyncSocket == nil) {
            
            asyncSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
         
            connectToNextAddress()
        }

    }
}

extension ViewController : GCDAsyncSocketDelegate {
    
    func connectToNextAddress() {
        // Consume serverAddresses array
        
        var done :Bool = false
        while !done && serverAddresses.count > 0 {
            
            if let address = serverAddresses.popLast() {
            
                print("Attempting connection to %@", address)
                
                do {
                    
                    // Start asyncSocket process
                    
                    try asyncSocket.connect(toAddress: address)
                
                }
                catch {
                    
                    print("Error trying to connect! ",error)
                    done = true
                }
                
            }
            
        }
        
        if (!done) {
            
            print("Unable to connect to any resolved address")
            
        }

    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectTo url: URL) {
        print("GCDAsyncSocket: didConnectTo - ", url)
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("GCDAsyncSocket: didConnectToHost - ", host)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        print("GCDAsyncSocket: didRead - ", data.debugDescription)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("GCDAsyncSocket: socketDidDisconnect - ", err.debugDescription)
    }
    
}

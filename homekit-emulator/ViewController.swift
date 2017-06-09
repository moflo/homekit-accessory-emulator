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

    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        displayString("Loading…")

        // Start Bonjour service discovery
        netServiceBrowser.delegate = self
        netServiceBrowser.searchForServices(ofType: "_hap._tcp.", inDomain: "local.")
        
        displayString("Waiting…")

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func displayString(_ info :String, _ arguments: CVarArg...) {
        let text = String(format: NSLocalizedString(info, comment: ""), arguments)
        textView.textStorage?.append(NSAttributedString(string: "\(text)\n\r"))

    }
    
}

extension ViewController : NetServiceBrowserDelegate {
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        displayString("NetServiceBrowser: didNotSearch")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("NetServiceBrowser: didFind service - ", service.name)
        
        // Start service...
        if (serverService == nil)
        {
            displayString("NetServiceBrowser: Resolving...")
            
            serverService = service
            
            serverService.delegate = self
        
            serverService.resolve(withTimeout: 5.0)

        }

    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        displayString("NetServiceBrowser: didRemove service - ", service.name)
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        displayString("NetServiceBrowser: didStopSearch")
    }
}

extension ViewController : NetServiceDelegate {
    
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        displayString("NetService: didNotPublish")
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        displayString("NetService: didNotResolve")
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        displayString("NetService: didResolve - ",sender.name)
        
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
            
                displayString("Attempting connection to %@", address.debugDescription)
                
                do {
                    
                    // Start asyncSocket process
                    
                    try asyncSocket.connect(toAddress: address)
                
                }
                catch {
                    
                    displayString("Error trying to connect! ",error.localizedDescription)
                    done = true
                }
                
            }
            
        }
        
        if (!done) {
            displayString("Unable to connect to any resolved address")
            
        }

    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectTo url: URL) {
        displayString("GCDAsyncSocket: didConnectTo - ", url.absoluteString)
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        displayString("GCDAsyncSocket: didConnectToHost - ", host)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        displayString("GCDAsyncSocket: didRead - ", data.debugDescription)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        displayString("GCDAsyncSocket: socketDidDisconnect - ", err?.localizedDescription ?? "unknown error")
    }
    
}

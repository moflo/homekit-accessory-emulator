//
//  ViewController.swift
//  homekit-emulator
//
//  Created by moflo on 6/9/17.
//  Copyright © 2017 Mobile Flow LLC. All rights reserved.
//

import Cocoa
import CocoaAsyncSocket

struct DEVICE {
    
    static let name = "emulator"
    static let device_id = "3C:33:1B:21:B3:00"
    static let isPaired = false
   
}


class ViewController: NSViewController {

    let netServiceBrowser = NetServiceBrowser()
    var serverService: NetService!
    var serverAddresses = [Data]()
    var connectedSockets = [Data]()
    var asyncSocket: GCDAsyncSocket!
    var connected: Bool = false

    @IBOutlet weak var codeView: NSTextField!
    
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        displayString("Loading…")

        // Start Bonjour service discovery
        enum ConnectionType {
            case Browser, AsyncSock, NetService
        }
        let method :ConnectionType = .AsyncSock
        
        switch method {
        case .Browser:
        
            netServiceBrowser.delegate = self
            netServiceBrowser.searchForServices(ofType: "_hap._tcp", inDomain: "")
            //            netServiceBrowser.searchForServices(ofType: "_hap._tcp.", inDomain: "local.")
            
        case .AsyncSock:
            
            asyncSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
            
            do {
                try asyncSocket.accept(onPort: 0)
            }
            catch {
                displayString("Error on acceptOnPort")
            }
            
            
            let port = Int32(asyncSocket.localPort)
            
            displayString("Starting service on port: %@", port)
            
            serverService = NetService(domain: "", type: "_hap._tcp.", name: DEVICE.name, port: port)
            serverService.startMonitoring()
//            serverService.publish(options: [.listenForConnections])
            serverService.publish()
            
            let txtDict :[String:String] = [
                "pv": "1.0", // state
                "id": DEVICE.device_id, // identifier
                "c#": "1", // version
                "s#": "1", // state
                "sf": (DEVICE.isPaired ? "0" : "1"), // discoverable
                "ff": "0", // mfi compliant
                "md": DEVICE.name, // name
                //                "ci": category.rawValue // category identifier
                "ci": "1" // category identifier
            ]
            
            //            let record = txtDict.dictionary(key: { $0.key }, value: { $0.value.data(using: .utf8)! })
            var record = [String:Data]()
            txtDict.forEach({ ( source: (key: String, value: String)) in
                record[source.key] = source.value.data(using: .utf8)!
            })
            
            
            let txtData = NetService.data(fromTXTRecord: record)
            serverService.setTXTRecord(txtData)
            
            
            serverService.delegate = self
            
        case .NetService:
            
            serverService = NetService(domain: "local.", type: "_hap._tcp.", name: DEVICE.name, port: 0)
            serverService.startMonitoring()
            serverService.publish(options: [.listenForConnections])
            
            let txtDict :[String:String] = [
                "pv": "1.0", // state
                "id": DEVICE.device_id, // identifier
                "c#": "1", // version
                "s#": "1", // state
                "sf": (DEVICE.isPaired ? "0" : "1"), // discoverable
                "ff": "0", // mfi compliant
                "md": DEVICE.name, // name
//                "ci": category.rawValue // category identifier
                "ci": "1" // category identifier
            ]

//            let record = txtDict.dictionary(key: { $0.key }, value: { $0.value.data(using: .utf8)! })
            var record = [String:Data]()
            txtDict.forEach({ ( source: (key: String, value: String)) in
                record[source.key] = source.value.data(using: .utf8)!
            })

            
            let txtData = NetService.data(fromTXTRecord: record)
            serverService.setTXTRecord(txtData)

            
            serverService.delegate = self

            
        }
        
        
        
        displayString("Waiting…")

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func displayString(_ info :String, _ arguments: CVarArg...) {
        let text = String(format: NSLocalizedString(info, comment: ""), arguments)
        textView.textStorage?.append(NSAttributedString(string: "\(text)\n"))

    }
    
}

extension ViewController : NetServiceBrowserDelegate {
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        displayString("NetServiceBrowser: didNotSearch")
    }
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        displayString("NetServiceBrowser: didFind service - %@", service.name)
        
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
        displayString("NetServiceBrowser: didRemove service - %@", service.name)
    }
    
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        displayString("NetServiceBrowser: didStopSearch")
    }
}

extension ViewController : NetServiceDelegate {
    
    func netServiceDidPublish(_ sender: NetService) {
        displayString("NetService: didPublish - port: %@", sender.port)
    }
    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        displayString("NetService: didNotPublish")
    }
    
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        displayString("NetService: didNotResolve")
    }
    
    func netServiceDidResolveAddress(_ sender: NetService) {
        displayString("NetService: didResolve - %@",sender.name)
        
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
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        displayString("GCDAsyncSocket:  Accepted new socket from %@:%hu", newSocket.connectedHost!, newSocket.connectedPort);
        
        // Start new accessory pairing
        newSocket.readData(withTimeout: -1, tag: 0)
    }
    
    func connectToNextAddress() {
        // Consume serverAddresses array
        
        var done :Bool = false
        while !done && serverAddresses.count > 0 {
            
            if let address = serverAddresses.popLast() {
            
                displayString("GCDAsyncSocket: Attempting connection to %@", address.debugDescription)
                
                do {
                    
                    // Start asyncSocket process
                    
                    try asyncSocket.connect(toAddress: address)
                
                }
                catch {
                    
                    displayString("GCDAsyncSocket: Error trying to connect via asyncSocket!")
                    done = true
                }
                
            }
            
        }
        
        if (!done) {
            displayString("GCDAsyncSocket: Unable to connect to any resolved address")
            
        }

    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectTo url: URL) {
        displayString("GCDAsyncSocket: didConnectTo - %@", url.absoluteString)
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        displayString("GCDAsyncSocket: didConnectToHost - %@", host)
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        displayString("GCDAsyncSocket: didRead - %@", data.debugDescription)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        displayString("GCDAsyncSocket: socketDidDisconnect - %@", err?.localizedDescription ?? "unknown error")
    }
    
    
}

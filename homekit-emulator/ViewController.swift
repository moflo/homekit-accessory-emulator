//
//  ViewController.swift
//  homekit-emulator
//
//  Created by moflo on 6/9/17.
//  Copyright © 2017 Mobile Flow LLC. All rights reserved.
//

import Cocoa
import Socket

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
    var asyncSocket: Socket?
    var queue: DispatchQueue!
    var connected: Bool = false

    @IBOutlet weak var codeView: NSTextField!
    
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        displayString("Loading…")

        // Emulator initialization and callback
        Emulator.sharedInstance.setup {
            (stream) in
        
            self.displayString("Write byte count: %@", stream.count)
            
            print("Write Buffer - raw")
            print(String.init(data: stream, encoding: .utf8) ?? stream.debugDescription)
            print(stream.map { b in String(format: "%02X", b) }.joined())
            print()
            
        }
        

        do {
            asyncSocket = try Socket.create(family: .inet, type: .stream, proto: .tcp)
            try asyncSocket!.listen(on: 0)
        }
        catch {
            displayString("Error on acceptOnPort")
        }
        
        
        let port = Int32(asyncSocket!.listeningPort)
        
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
        
        
        displayString("Waiting…")
        
        queue = DispatchQueue(label: "hap.socket-listener", qos: .utility, attributes: [.concurrent])

        queue.async {
            guard self.asyncSocket != nil else {
                self.displayString("Error, asyncSocket is nil")
                return
            }
            
            while self.asyncSocket!.isListening {
                do {
                    let client = try self.asyncSocket!.acceptClientConnection()
                    self.displayString("Accepted connection from %@", client.remoteHostname)
                    DispatchQueue.main.async {
                        _ = self.listen(socket: client, queue: self.queue)
                    }
                } catch {
                    self.displayString("Could not accept connections for listening socket %@", error.localizedDescription)
                    break
                }
            }
            self.asyncSocket!.close()
        }


    }
    
    func listen(socket: Socket, queue: DispatchQueue) {
        queue.async {
            while !socket.remoteConnectionClosed {
                var readBuffer = Data()
                var writeBuffer: Data? = nil
                do {
                    _ = try socket.read(into: &readBuffer)
                    
                    // Display readBuffer data
                    print("Read Buffer")
                    print(String.init(data: readBuffer, encoding: .utf8) ?? readBuffer.debugDescription)
                    print(readBuffer.map { b in String(format: "%02X", b) }.joined())
                    
                    
                    writeBuffer = Emulator.sharedInstance.processData(stream: readBuffer)

                } catch {
                    self.displayString("Error while reading from socket %@", error.localizedDescription)
                    break
                }

                if (writeBuffer != nil) {
                    do {
                        // Display writeBuffer data
                        print("Write Buffer - raw")
                        print(String.init(data: writeBuffer!, encoding: .utf8) ?? writeBuffer.debugDescription)
                        print(writeBuffer!.map { b in String(format: "%02X", b) }.joined())

                        try socket.write(from: writeBuffer!)

                    } catch {
                        self.displayString("Error while reading from socket %@", error.localizedDescription)
                        break
                    }
                }
                
            }
            
            // Socket closed
            self.displayString("Closed connection to %@", socket.remoteHostname)
            socket.close()
            self.asyncSocket = nil

        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func displayString(_ info :String, _ arguments: CVarArg...) {
        let text = String(format: NSLocalizedString(info, comment: ""), arguments)
        textView.textStorage?.append(NSAttributedString(string: "\(text)\n"))
        print( text) 

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
        
//        if (asyncSocket == nil) {
//            
//            asyncSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
//         
//            connectToNextAddress()
//        }

    }
}



# homekit-accessory-emulator
HomeKit Accessory Emulation for Particle / Arduino Development Boards. 


Using recently released HomeKit Non-commercial HAP Specification to create an embedded accessory client. Goal of this project is to test C/C++ based SHA-512 based SRP enabled HAP protocols for eventual porting to Particle.io or Arduino libraries. This project contains a Mac OS based XCode project to test embedded code available here: [https://github.com/moflo/homekit-particle](https://github.com/moflo/homekit-particle)



Motivation
----------

This project allows for the testing of embedded C/C++ code for use in Particle / Arduino boards by briding the C/C++ code with high-level Swift and Objective-C based native HomeKit APIs. This Mac OS based application acts as a HomeKit accessory, broadcasting it's presence over Bonjour to be discovered by the iOS Home app. Once discovered, the user starts the pairing process to use the Home app to establish a connection with thie emulator. This process allows for the testing of several C/C++ libraries which can then be used in the embedded device. Specifically, this emulator allows for the testing of the following libraries:

    - SRP protocol with N = 3072, g = 5 radix
    - ChaCha20_Poly1305 cypher
    - ed25519 codec
    - sha512 encoding
    - HTTP1.1 compliant router
    - TLV8 codec


Please note, the TCP and UDP code uses native Mac OS libraries as it is expected that embedded code will use native communication libraries for Particle / Arduino.


Finally, this current implementation uses the crypto library from WolfSSL / WolfCrypto for ARM compatibility. You can find our more about this library online, [https://github.com/wolfSSL/wolfssl](https://github.com/wolfSSL/wolfssl).



Architecture
------------

Mac OS based single window utility (ViewContoller.swift) calls Objective-C bridging functions (*.mm) to access C/C++ libraries contained in C++ classes.

    - HAPController : HAPContoller.mm / HAPController_Bridge.h
    - TLV8 : TLV8_Bridge.mm / TLV8_Bridge.h
    - WebClient : WebClient_Bridge.mm / WebClient_Bridge.h
    - Swift based testing : homekit-emulatorTests



Requirements
------------

* macOS 10.10+ (v1.1.2+)
* Xcode 8 with Swift 3
* Cocoapods 1.2.1+

Installation
------------

#### CocoaPods

    pod install




Testing
=======


Library Unit Tests
------------------

Using XCode unit testing with Swift Nible library and the Objective-C bridges in the `homekit-emulatorTests` target. Run individual unit tests within XCode, or via the CLI.



Bonjour Testing
---------------

Install Wireshark app, and Bonjour Browser for protocol testing. Save UDP packets on local ethernet channel using the TCPdump command line tool and open the results in Wireshark to test the validity of MDNS packets:

    sudo tcpdump -i en0 -s 0 -w ./test.dmp
    wireshark -r test.dmp -Y mdns

Use Apple supplied "HomeKit Accessory Simulator" to generate valid MDNS HomeKit packets and use the trace methods above to compare packet & response structure. This provides "blackbox" testing, you can observe valid UDP packet structure but we still need a method to compare use of custom crypto libraries (SHA512, etc.)

Likewise, run this HomeKit Emulator MacOS app to compare MDNS packet structure & reponse protocol. This emulator uses native Cocoa MDNS (ie., NetService) function calls to register a HomeKit accessory, and can be observed within the iOS Home app. Importantly, it then uses 3rd party C/C++ libraries for SRP & Crypto functions so that those libraries can be validated before embedding them in Particle / Arduino project libraries, etc.



HAP Protocol
============

HTTP1.1 based pairing process. Initial request from Home app is a POST request to start pairing process...

Text Dump:

    POST /pair-setup HTTP/1.1
    Host: emulator._hap._tcp.local
    Content-Length: 6
    Content-Type: application/pairing+tlv8

Hex Dump:

    50 4F 53 54 20 2F 70 61 69 72 2D 73 65 74 75 70 20 48 54 54 50 2F 31 2E 31 0D 0A 48 6F 73 74 3A 20 65 6D 75 6C 61 74 6F 72 2E 5F 68 61 70 2E 5F 74 63 70 2E 6C 6F 63 61 6C 0D 0A 43 6F 6E 74 65 6E 74 2D 4C 65 6E 67 74 68 3A 20 36 0D 0A 43 6F 6E 74 65 6E 74 2D 54 79 70 65 3A 20 61 70 70 6C 69 63 61 74 69 6F 6E 2F 70 61 69 72 69 6E 67 2B 74 6C 76 38 0D 0A 0D 0A 00 01 00 06 01 01 00 00


TLV8 Payload:
    00 01 00 06 01 01



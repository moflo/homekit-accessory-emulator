# homekit-accessory-emulator
HomeKit Accessory Emulation for Particle / Arduino Development Boards

Using recently released HomeKit Non-commercial HAP Specification to create an embedded accessory client. Goal of this project is to test C/C++ based SHA-512 based SRP enabled HAP protocols for eventual porting to Particle.io or Arduino libraries.



Testing
-------

Install Wireshark app, and Bonjour Browser for protocol testing. Save UDP packets on local ethernet channel using the TCPdump command line tool and open the results in Wireshark to test the validity of MDNS packets:

    sudo tcpdump -i en0 -s 0 -w ./test.dmp
    wireshark -r test.dmp -Y mdns

Use Apple supplied "HomeKit Accessory Simulator" to generate valid MDNS HomeKit packets and use the trace methods above to compare packet & response structure. This provides "blackbox" testing, you can observe valid UDP packet structure but we still need a method to compare use of custom crypto libraries (SHA512, etc.)

Likewise, run this HomeKit Emulator MacOS app to compare MDNS packet structure & reponse protocol. This emulator uses native Cocoa MDNS (ie., NetService) function calls to register a HomeKit accessory, and can be observed within the iOS Home app. Importantly, it then uses 3rd party C/C++ libraries for SRP & Crypto functions so that those libraries can be validated before embedding them in Particle / Arduino project libraries, etc.


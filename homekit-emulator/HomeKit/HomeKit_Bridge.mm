//
//  TLV8_Bridge.m
//  homekit-emulator
//
//  Created by d. nye on 7/2/17.
//  Copyright © 2017 Mobile Flow LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HomeKit_Bridge.h"
#import "homekit.h"

@implementation newHomeKit
-(int) newObject
{
    return 0;
}
-(int) testProcessHTTP:(NSString *)streeam
{
    TCPClient tcpStream;
    NSData *bytes = [streeam dataUsingEncoding:NSASCIIStringEncoding];
    uint8_t *data = (uint8_t *)[bytes bytes];
    tcpStream.stream = (char *)data;

    Homekit HK = Homekit();
    
    HK.process( tcpStream );
    
    return HK.getPairingState();
}

@end

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

NSData *outputBuffer;

void callback(char *buffer, int len)
{
    NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
    
    NSLog(@"Write %@", output);
    
//    outputBuffer = [NSData dataWithBytes:buffer length:len];

};

-(int) testProcessHTTP:(NSString *)streeam
{
    TCPClient tcpStream;
    NSData *bytes = [streeam dataUsingEncoding:NSASCIIStringEncoding];
    uint8_t *data = (uint8_t *)[bytes bytes];
    tcpStream.stream = (char *)data;
    tcpStream.callback = callback;
    

    Homekit HK = Homekit();
    
    HK.process( tcpStream );
    
    return HK.getPairingState();
}

@end

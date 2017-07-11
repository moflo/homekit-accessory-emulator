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

NSMutableData *outputBuffer;

Homekit *HK = NULL;

void callback(char *buffer, int len)
{
    NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSUTF8StringEncoding];
    
    NSLog(@"Write %@", output);
    
//    outputBuffer = [NSData dataWithBytes:buffer length:len];
    [outputBuffer appendBytes:buffer length:len];

};


-(NSDictionary *) processHTTP:(NSData *)stream
{
    
    TCPClient tcpStream;
    tcpStream.stream = (char *)[stream bytes];
    tcpStream.callback = callback;
    outputBuffer = [[NSMutableData alloc] initWithCapacity:255];
    
    if (HK == NULL)
        HK = new Homekit;
    
    HK->process( tcpStream );
    
    uint8_t state = HK->getPairingState();

    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:4];
    
    NSNumber *state_value = [NSNumber numberWithInt:state];
    [dict setObject:state_value forKey:@"state"];

    NSData *output = outputBuffer;
    [dict setObject:output forKey:@"outputBuffer"];

    return (NSDictionary *)dict;
    
}

-(void) reset
{
    // TODO: free !
    HK = new Homekit;
}

@end

//
//  TLV8_Bridge.m
//  homekit-emulator
//
//  Created by d. nye on 7/2/17.
//  Copyright © 2017 Mobile Flow LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TLV8_Bridge.h"
#import "TLV8.hpp"

@implementation newTLV8
-(int) newObject
{
    tlv_t new_tlv = tlv();
    
    return new_tlv.size;
    
}
-(NSDictionary*) parseData:(NSData*)stream
{
    
    uint8_t * data = (uint8_t *)[stream bytes];
    uint16_t length = [stream length];
    tlv_map_t map = tlv_map();
    
    TLV8Class tlv = TLV8Class();
    
    tlv_result_t r = tlv.decode(data, length, &map);

    NSLog(@"decode output: %d",r);
    
    NSInteger size = map.count;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:size];
    
    for (int i = 0; i < size; i++) {
        tlv_t tlv_object = map.object[i];
        NSNumber *key = [NSNumber numberWithInt:tlv_object.type];
        uint8_t *bytes = tlv_object.data;
        uint16_t len = tlv_object.size;
        NSData *data = [[NSData alloc] initWithBytes:bytes length:len];
        [dict setObject:data forKey:key];
    }
    
    return (NSDictionary *)dict;
    
}


@end

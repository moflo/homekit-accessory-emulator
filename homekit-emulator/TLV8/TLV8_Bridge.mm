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

-(NSData *) encodeDict:(NSDictionary *)dict
{
    NSEnumerator *enumerator = [dict keyEnumerator];
    id key;

    tlv_map_t map = tlv_map();
    
    while((key = [enumerator nextObject])) {
        NSLog(@"key=%@ value=%@", key, [dict objectForKey:key]);
        
        uint8_t type = [key intValue];
        NSData *data = (NSData *)[dict objectForKey:key];
        uint8_t *bytes = (uint8_t *)[data bytes];
        uint16_t count = [data length];
        
        tlv_t new_tlv = tlv(type, bytes, count);

        map.insert(new_tlv);
        
    }

    TLV8Class tlv = TLV8Class();

    uint8_t *encodedData = NULL;
    uint32_t encodedDataLen = 0;
    
    tlv_result_t r = tlv.encode(&map, &encodedData, &encodedDataLen);
    
    NSLog(@"encode output: %d",r);

    
    NSData *data = [[NSData alloc] initWithBytes:encodedData length:encodedDataLen];

    return data;
    
}

@end

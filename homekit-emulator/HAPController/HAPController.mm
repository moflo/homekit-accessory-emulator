//
//  TLV8_Bridge.m
//  homekit-emulator
//
//  Created by d. nye on 7/2/17.
//  Copyright © 2017 Mobile Flow LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HAPController_Bridge.h"
#import "HAPController.h"
#import "TLV8.hpp"


@implementation newHAPController
-(int) newObject
{

    return 0;

}
-(NSDictionary*) getChallenge
{
    
    uint8_t * salt = NULL;
    uint32_t salt_len = 0;
    uint8_t * key = NULL;
    uint32_t key_len = 0;
    
    HAPControllerClass hap = HAPControllerClass();
    
    hap.getChallenge(&salt, &salt_len, &key, &key_len);
    
    
    tlv_map_t map = tlv_map();
    
    TLV8Class tlv = TLV8Class();
    
    tlv_result_t r = tlv.decode(key, key_len, &map);
    
    NSLog(@"decode output: %d",r);
    
    NSInteger size = map.count;

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
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

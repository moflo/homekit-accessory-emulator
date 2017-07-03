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
    
    map.insert(tlv(0x01,key,key_len));
    
    TLV8Class tlv = TLV8Class();
    
    uint8_t *encodedData = NULL;
    uint32_t encodedDataLen = 0;
    
    tlv_result_t r = tlv.encode(&map, &encodedData, &encodedDataLen);
    
    NSLog(@"decode output: %d",r);
    

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    NSData *data = [[NSData alloc] initWithBytes:encodedData length:encodedDataLen];
    [dict setObject:data forKey:@"encodedData"];

    NSData *challenge = [[NSData alloc] initWithBytes:key length:key_len];
    [dict setObject:challenge forKey:@"challenge"];

    
    return (NSDictionary *)dict;
    
}


@end

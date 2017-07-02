//
//  TLV8_Bridge.h
//  homekit-emulator
//
//  Created by d. nye on 7/2/17.
//  Copyright © 2017 Mobile Flow LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef TLV8_Bridge_h
#define TLV8_Bridge_h

@interface newTLV8 : NSObject
-(int) newObject;
-(NSDictionary*) parseData:(NSData*)stream;
@end

#endif /* TLV8_Bridge_h */
